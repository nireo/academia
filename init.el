;; Initialize package manager
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;;; use-package
;; a macro to simplify package management in emacs.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(setq initial-major-mode 'org-mode
      initial-scratch-message nil)

(push '(menu-bar-lines . 0)   default-frame-alist)
(push '(tool-bar-lines . 0)   default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

(fringe-mode 0)
(setq menu-bar-mode nil
      tool-bar-mode nil
      scroll-bar-mode nil)

(setq default-input-method nil)
(setq-default fill-column 80)


;; Show startup time.
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs loaded in %s with %d garbage collections."
                     (format "%.4fs" (float-time (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; Read process is set to a really low value.
;; Setting it to a higher value increases performance especially for LSP-mode.
(setq read-process-output-max (* 3 1024 1024)) ;; 3mb

;; Change the garbage collector on startup
(add-hook 'emacs-startup-hook
  (lambda ()
    (setq gc-cons-threshold 31457280 ; 32mb
          gc-cons-percentage 0.1)))


;; This is copied from doom emacs and it increases performance.
(defun nro/defer-garbage-collection-h ()
  "Set the garbage collection threshold to 'most-positive-fixnum'."
  (setq gc-cons-threshold most-positive-fixnum))

;; Defer it so that commands launched immediately after will enjoy the
;; benefits.
(defun nro/restore-garbage-collection-h ()
  "Restore the garbage collection threshold back to a normal number."
  (run-at-time
   1 nil (lambda () (setq gc-cons-threshold 31457280))))

(add-hook 'minibuffer-setup-hook #'nro/defer-garbage-collection-h)
(add-hook 'minibuffer-exit-hook #'nro/restore-garbage-collection-h)

;; Change indentation
(setq-default tab-width 2)
(setq-default standard-indent 2)
(setq-default electric-indent-inhibit t)
(setq-default indent-tabs-mode nil) ;; Don't use tabs

(set-face-attribute 'default nil
                    :family "Menlo"
                    :height 160)

(blink-cursor-mode -1) ;; Disable cursor blinking

;; Custom settings
(setq scroll-margin 0 ;; better scrolling
      scroll-conservatively 101 ;;-
      scroll-preserve-screen-position t ;;-
      scroll-down-aggressively 0.01 ;;-
      scroll-up-aggressively 0.01 ;;-
      fast-but-imprecise-scrolling t
      jit-lock-defer-time 0 ;; fontification is deferred when input is loading
      highlight-nonselected-windows nil
      echo-keystrokes 0.02
      require-final-newline t ;; newline at the end of files
      select-enable-clipboard t ;; make cutting and pasting use the clipboard
      ring-bell-function 'ignore ;; ignore
      large-file-warning-threshold 100000000 ;; increase the file warning threshold
      help-window-select t ;; automatically select help windows, so that they can be deleted.
      confirm-kill-processes nil ;; don't confirm when killing processes
      inhibit-compacting-font-caches t ;; don't trigger GC when loading larger fonts
      make-backup-files nil ;; Stop saving backups since they're quite useless in the modern age
      create-lockfiles nil ;; Don't create lock files.
      auto-save-default nil ;; Stop auto saving files, since they're not needed
      delete-old-versions t ;; Delete excess backups silently
      x-stretch-cursor t ;; Make the cursor the size of the underlying character.
      frame-resize-pixelwise t ;; Fix the window not being fullscreen and leaving a gap
      frame-title-format "%b - academia" ;; change window title
      vc-follow-symlinks t ;; When opening a file, always follow symlinks
      vc-handled-backends nil
      auto-window-vscroll nil ;; Speed up line movement
      blink-matching-paren nil
      use-dialog-box nil
      undo-limit 100000000 ;; Increase undo limit

      ;; Make numbers relative such that evil navigation is easier
      display-line-numbers-type 'relative
      display-line-numbers-width 3
      display-line-numbers-widen t)

(global-auto-revert-mode 1) ;; Update a buffer if a file changes on disk.
;; Cleanup whitespaces
(add-hook 'before-save-hook 'whitespace-cleanup)
(setq-default sentence-end-double-space nil)

;; Shorten answers
(if (boundp 'use-short-answers)
    (setq use-short-answers t))

(global-subword-mode) ;; Make it so that 'w' in evil moves to the next camel case word
(global-visual-line-mode 1) ;; Add line wrapping

(global-subword-mode) ;; Make it so that 'w' in evil moves to the next camel case word


;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(setq show-paren-delay 0.0) ;; Remove delay to display matching parenthesy
(show-paren-mode 1) ;; Show matching parenthesies

(load-theme 'modus-operandi)

;;; evil
;; key bindings from vim in emacs.
(use-package evil
  :ensure t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (evil-mode 1)
  :config

  ;; Set leader key to space
  (evil-set-leader 'normal (kbd "SPC"))

  ;; Define different splits
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)

  ;; Such that there is no need to use the ESC-key.
  (define-key evil-insert-state-map (kbd "C-j") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-f") 'evil-normal-state)

  ;; Better marking keywords using the custom functions below.
  (evil-define-key 'normal 'global (kbd "<leader>n") 'nro/mark-word)
  (evil-define-key 'normal 'global (kbd "<leader>m") 'nro/mark-construct-dwim)

  ;; Some keybindings for better window navigation
  (evil-define-key 'normal 'global (kbd "<leader>wj") 'evil-window-bottom)
  (evil-define-key 'normal 'global (kbd "<leader>wh") 'evil-window-left)
  (evil-define-key 'normal 'global (kbd "<leader>wl") 'evil-window-right)
  (evil-define-key 'normal 'global (kbd "<leader>wk") 'evil-window-up)

  ;; Other leader keybindings
  (evil-define-key 'normal 'global (kbd "<leader>p") 'find-file)
  (evil-define-key 'normal 'global (kbd "<leader>d") 'dired)
  (evil-define-key 'normal 'global (kbd "<leader>k") 'kill-this-buffer)

  ;; Save a file.
  (evil-define-key 'normal 'global (kbd "<leader>s") 'save-buffer)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  ;; (setq evil-insert-state-cursor 'hbar)

  (evil-set-initial-state 'messages-buffer-mode 'normal))

;;; evil-collection
;; more evil support for many different modes.
(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

;;; vertico
;; a minimal completion framework
(use-package vertico
  :ensure t
  :custom
  (vertico-count 14)
  (vertico-multiform-categories
   '((file flat)))
  :init
  (vertico-mode)
  (vertico-multiform-mode))

(advice-add #'vertico--format-candidate :around
            (lambda (orig cand prefix suffix index _start)
              (setq cand (funcall orig cand prefix suffix index _start))
              (concat
               (if (= vertico--index index)
                   (propertize "> " 'face 'vertico-current)
                 "  ")
               cand)))

(use-package org-modern
  :ensure t)

;; Add frame borders and window dividers
(modify-all-frames-parameters
 '((right-divider-width . 40)
   (internal-border-width . 40)))
(dolist (face '(window-divider
                window-divider-first-pixel
                window-divider-last-pixel))
  (face-spec-reset-face face)
  (set-face-foreground face (face-attribute 'default :background)))
(set-face-background 'fringe (face-attribute 'default :background))

(setq
 ;; Edit settings
 org-auto-align-tags nil
 org-tags-column 0
 org-catch-invisible-edits 'show-and-error
 org-special-ctrl-a/e t
 org-insert-heading-respect-content t

 ;; Org styling, hide markup etc.
 org-hide-emphasis-markers t
 org-pretty-entities t
 org-ellipsis "…"

 ;; Agenda styling
 org-agenda-tags-column 0
 org-agenda-block-separator ?─
 org-agenda-time-grid
 '((daily today require-timed)
   (800 1000 1200 1400 1600 1800 2000)
   " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
 org-agenda-current-time-string
 "⭠ now ─────────────────────────────────────────────────")

(global-org-modern-mode)

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (file-truename "/path/to/org-files/"))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ;; Dailies
         ("C-c n j" . org-roam-dailies-capture-today))
  :config
  ;; If you're using a vertical completion framework, you might want a more informative completion interface
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode)
  ;; If using org-roam-protocol
  (require 'org-roam-protocol))

(require 'ox-latex)
(unless (boundp 'org-latex-classes)
  (setq org-latex-classes nil))
(add-to-list 'org-latex-classes
             '("article"
               "\\documentclass{article}"
               ("\\section{%s}" . "\\section*{%s}")))

;; Load custom variables from a custom.el file, such that they don't clutter up
;; main init.el file.
(setq custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))
