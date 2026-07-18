;; Editing
(setq-default indent-tabs-mode nil) ; Use spaces instead of tabs
(setq-default tab-width 4)          ; Set default indentation size to 4 spaces
(setq-default cursor-type 'bar)     ; Use a vertical bar cursor

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

;; Lock files
;; Do not create .#<file> lock files in directories being edited.
(setq create-lockfiles nil)

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
(setq-default display-fill-column-indicator-column 80)
(global-display-fill-column-indicator-mode 1)

;; Open files received by emacsclient in a new tab after the first request.
;; This keeps the initial tab intact while preventing subsequent external file
;; opens from replacing the current buffer.
(defvar dotrc-server-has-visited-file nil)
(defun dotrc-visit-in-new-tab (&optional force)
  (let ((buffer (current-buffer)))
    (when (or force dotrc-server-has-visited-file)
      (tab-bar-new-tab))
    (switch-to-buffer buffer)
    (setq dotrc-server-has-visited-file t)))
(with-eval-after-load 'server
  (add-hook 'server-visit-hook #'dotrc-visit-in-new-tab))

;; Handle files opened through macOS's "Open With" Apple Event as well.
(defun dotrc-ns-find-file-in-new-tab (orig-fun &rest args)
  (let* ((existing-file-buffer (buffer-file-name))
         ;; Keep macOS file opens in the current frame; the helper below
         ;; creates a tab when an existing file buffer is already displayed.
         (ns-pop-up-frames nil)
         (result (apply orig-fun args)))
    (when (buffer-file-name)
      (dotrc-visit-in-new-tab existing-file-buffer))
    result))
(with-eval-after-load 'ns-win
  (advice-add 'ns-find-file :around #'dotrc-ns-find-file-in-new-tab))

;; Font
(set-face-attribute 'default nil :family "HackGen Console NF" :height 120)
(dolist (target '(japanese-jisx0208 japanese-jisx0212
                  japanese-jisx0213-1 japanese-jisx0213-2))
  (set-fontset-font t target (font-spec :family "HackGen Console NF")))
