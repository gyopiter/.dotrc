;; Editing
(setq-default indent-tabs-mode nil) ; Use spaces instead of tabs
(setq-default tab-width 4)          ; Set default indentation size to 4 spaces

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

;; Font
(set-face-attribute 'default nil :family "HackGen Console NF" :height 120)
(dolist (target '(japanese-jisx0208 japanese-jisx0212
                  japanese-jisx0213-1 japanese-jisx0213-2))
  (set-fontset-font t target (font-spec :family "HackGen Console NF")))
