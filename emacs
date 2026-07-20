;; Editing
(setq-default indent-tabs-mode nil) ; Use spaces instead of tabs
(setq-default tab-width 4)          ; Set default indentation size to 4 spaces
(setq-default cursor-type 'bar)     ; Use a vertical bar cursor
(delete-selection-mode 1)            ; Replace the active region when inserting

;; Allow commands to use the mark even if it becomes temporarily inactive.
;; The mwheel advice below keeps the region active during mouse-wheel scrolling.
(setq mark-even-if-inactive t)

;; Let the cursor move naturally with the buffer while scrolling.  The
;; mwheel advice below preserves the active region separately.
(setq scroll-preserve-screen-position nil)
(setq scroll-error-top-bottom nil)

;; mwheel-scroll deactivates mark when scrolling moves point.  Restore the
;; active region afterward so forced scrolling at a window boundary does not
;; make an existing selection disappear.
(defun dotrc-mwheel-scroll-preserve-region (orig-fun &rest args)
  (let ((buffer (current-buffer))
        (saved-mark (mark t))
        (was-active mark-active))
    (unwind-protect
        (apply orig-fun args)
      (when (and was-active saved-mark (buffer-live-p buffer))
        (with-current-buffer buffer
          (set-mark saved-mark)
          (setq mark-active t))))))
(with-eval-after-load 'mwheel
  (advice-add 'mwheel-scroll :around #'dotrc-mwheel-scroll-preserve-region))

;; Line endings
;; Detect DOS/Mac line endings when reading, but use Unix (LF) line endings
;; when saving.  Keep the file's character encoding while changing only the
;; end-of-line convention, so non-UTF-8 files are not silently rewritten.
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8-unix)
(set-default-coding-systems 'utf-8-unix)
(defun dotrc-use-unix-line-endings ()
  (when buffer-file-name
    (let ((modified (buffer-modified-p))
          (had-crlf nil))
      ;; Emacs may leave CR characters in the buffer when LF and CRLF line
      ;; endings are mixed.  Normalize only CRLF pairs; preserve lone CR
      ;; characters because they may be intentional content.
      (save-excursion
        (goto-char (point-min))
        (while (search-forward "\r\n" nil t)
          (setq had-crlf t)
          (replace-match "\n" nil nil)))
      (when (coding-system-eol-type buffer-file-coding-system)
        (set-buffer-file-coding-system
         (coding-system-change-eol-conversion
          (coding-system-base buffer-file-coding-system) 0)))
      ;; A mixed-line-ending file was changed in the buffer and must be
      ;; explicitly saved to persist the normalization.
      (set-buffer-modified-p (or modified had-crlf)))))
(add-hook 'find-file-hook #'dotrc-use-unix-line-endings)

;; Pasted text
;; Normalize CRLF pairs in yanked text without changing the kill ring itself.
;; Lone CR characters are preserved because they may be intentional content.
(defun dotrc-normalize-yanked-line-endings (text)
  (replace-regexp-in-string "\r\n" "\n" text))
(add-hook 'yank-transform-functions #'dotrc-normalize-yanked-line-endings)

;; Recovery files
;; Keep backup and auto-save files out of project directories while retaining
;; them for recovery after an accidental overwrite or Emacs crash.
(let* ((backup-dir (locate-user-emacs-file "backups/"))
       (auto-save-dir (locate-user-emacs-file "auto-save/")))
  (dolist (dir (list backup-dir auto-save-dir))
    (make-directory dir t))
  (setq backup-directory-alist `(("." . ,backup-dir)))
  (setq auto-save-file-name-transforms
        `((".*" ,auto-save-dir t))))

;; Layout
(require 'hl-line)
(global-display-line-numbers-mode 1)
(global-hl-line-mode 1)             ; Highlight the current line
(tab-bar-mode 1)

;; Create an unnamed, unsaved buffer when opening a new tab.
;; The timestamp is used as the buffer name only; it is not a file path.
(defun dotrc-new-untitled-buffer ()
  (let ((name (format "Untitled-%s"
                      (format-time-string "%Y%m%d-%H%M%S"))))
    (switch-to-buffer (generate-new-buffer name))
    (text-mode)))
(setq tab-bar-new-tab-choice #'dotrc-new-untitled-buffer)

(setq-default display-fill-column-indicator-column 80)
(global-display-fill-column-indicator-mode 1)

;; Reuse the tab that already displays BUFFER, if any.
;; Tab-bar keeps inactive tabs as window states, so inspect each tab by
;; selecting it temporarily and checking its visible windows.
(defun dotrc-select-tab-containing-buffer (buffer)
  (let* ((frame (selected-frame))
         (tabs (tab-bar-tabs frame))
         (current-tab (1+ (tab-bar--current-tab-index tabs)))
         (found-tab
          (catch 'found
            (dotimes (index (length tabs))
              (tab-bar-select-tab (1+ index))
              (when (get-buffer-window buffer frame)
                (throw 'found (1+ index))))
            nil)))
    (if found-tab
        (progn
          (tab-bar-select-tab found-tab)
          (switch-to-buffer buffer)
          t)
      (tab-bar-select-tab current-tab)
      (let ((visible-window (get-buffer-window buffer 'visible)))
        (when visible-window
          (select-frame-set-input-focus (window-frame visible-window))
          (select-window visible-window))
        (and visible-window t)))))

;; Find a visited buffer using both the caller's path and its canonical path.
;; macOS commonly exposes /tmp through /private/tmp, so either spelling may be
;; present in buffer-file-name.
(defun dotrc-existing-file-buffer (filename)
  (when (stringp filename)
    (let ((expanded-filename
           (expand-file-name filename command-line-default-directory)))
      (or (get-file-buffer expanded-filename)
          (get-file-buffer (file-truename expanded-filename))))))

;; Open each file received by emacsclient in an existing tab when possible, or
;; in a new tab while leaving the previously selected tab unchanged otherwise.
;; server-visit-hook runs once for each file in a client request.
(defun dotrc-visit-in-new-tab ()
  (let ((buffer (current-buffer)))
    (if (and (boundp 'server-existing-buffer)
             server-existing-buffer
             (dotrc-select-tab-containing-buffer buffer))
        t
      (tab-bar-new-tab)
      (switch-to-buffer buffer)
      t)))
(with-eval-after-load 'server
  ;; Remove the previous implementation when reloading this file in a running
  ;; Emacs session.
  (advice-remove 'server-visit-files #'dotrc-server-visit-files-in-tab)
  (add-hook 'server-visit-hook #'dotrc-visit-in-new-tab))

;; Handle files opened through macOS's "Open With" Apple Event as well.
(defun dotrc-ns-find-file-in-new-tab (orig-fun &rest args)
  ;; Reuse an existing tab before asking Emacs to open the file.  Otherwise,
  ;; create and select the new tab first so the previous tab remains intact.
  ;; ns-find-file receives no arguments; macOS places the path in ns-input-file.
  (let* ((filename (car ns-input-file))
         (existing-buffer (dotrc-existing-file-buffer filename))
         (ns-pop-up-frames nil))
    (if (and existing-buffer
             (dotrc-select-tab-containing-buffer existing-buffer))
        (apply orig-fun args)
      (tab-bar-new-tab)
      (apply orig-fun args))))
(with-eval-after-load 'ns-win
  (advice-add 'ns-find-file :around #'dotrc-ns-find-file-in-new-tab))

;; Font
(set-face-attribute 'default nil :family "HackGen Console NF" :height 120)
(dolist (target '(japanese-jisx0208 japanese-jisx0212
                  japanese-jisx0213-1 japanese-jisx0213-2))
  (set-fontset-font t target (font-spec :family "HackGen Console NF")))
