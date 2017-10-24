;;; init.el --- Umesh's custom Emacs initialization

;; Filename: init.el
;; Author: Umesh Telang

;;; Commentary:
;;
;; This is the initialization file used to set up Emacs
;; with my preferred defaults.
;; Some references:
;; https://martinralbrecht.wordpress.com/2014/11/03/c-development-with-emacs/
;; https://github.com/jwiegley/use-package
;; https://www.buildfunthings.com/get-started-with-clojure-in-gnu-emacs/

;;; Code:

;; Startup settings
(setq initial-buffer-choice t)
(when (window-system)
  (tool-bar-mode -1)
  (scroll-bar-mode -1))
(add-to-list 'default-frame-alist '(height . 48))
(add-to-list 'default-frame-alist '(width . 180))

(setq visible-bell nil)

(global-linum-mode t)

; Open new files in same frame as previous
(server-start)
(setq-default ns-pop-up-frames nil)


(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

;; add files from `includes` directory
(add-to-list 'load-path "~/.emacs.d/includes/")

;; store all backup and autosave files in the tmp dir
(setq backup-directory-alist `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))


;; Package Manager - Add GNU, Marmalade, MELPA repositories as desired
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa-stable" . "http://stable.melpa.org/packages/"))
(package-initialize)

;; Bootstrap 'use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Enable use-package
(eval-when-compile
  (require 'use-package))
(require 'diminish)
(require 'bind-key)

;; theme
(use-package monokai-theme
  :ensure monokai-theme
  :config (load-theme 'monokai t))


;; try before you buy (or install a package)
(use-package try
  :ensure t)

;; help on key combinations
(use-package which-key
  :ensure t
  :config
  (which-key-mode)
  (which-key-setup-side-window-right-bottom))


;; whitespace
;; activate whitespace-mode to view all whitespace characters
(use-package whitespace
  :bind (("C-c w" . whitespace-mode))
  :config (progn ;; make whitespace-mode use just basic coloring
            (setq-default whitespace-style '(face trailing tabs newline tab-mark
                                                  newline-mark lines-tail))
            (setq-default whitespace-display-mappings
                          ;; all numbers are Unicode codepoint in decimal.
                          ;; try (insert-char 182 ) to see it
                          ;; 9 TAB, 9655 WHITE RIGHT-POINTING TRIANGLE 「▷」
                          '((tab-mark 9 [9655 9] [92 9])))
            (setq-default whitespace-line-column 120)))


;; Smarter text editing
(defun smart-open-line ()
  "Insert an empty line after the current line.
Position the cursor at its beginning, according to the current mode."
  (interactive)
  (move-end-of-line nil)
  (newline-and-indent))

(global-set-key [(shift return)] 'smart-open-line)
(electric-indent-mode +1)
(electric-pair-mode +1)
(global-hl-line-mode +1)

;; Readonly for very large files
(defun my-find-file-check-make-large-file-read-only-hook ()
  "If a file is over a given size, make the buffer read only."
  (when (> (buffer-size) (* 5 1024 1024))
    (setq buffer-read-only t)
    (buffer-disable-undo)
    (fundamental-mode)))

(add-hook 'find-file-hook 'my-find-file-check-make-large-file-read-only-hook)


;; ENV variables
(when (and (window-system) (memq window-system '(mac ns)))
  (exec-path-from-shell-initialize))

;; Recent Files
(recentf-mode 1)
(setq-default recentf-max-menu-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

;; Easy window navigation / transposition operations
(global-set-key "\M-o" 'other-window)

(use-package buffer-move
  :commands (buf-move-up buf-move-down buf-move-left buf-move-right)
  :init (progn (global-set-key (kbd "<C-s-up>")     'buf-move-up)
               (global-set-key (kbd "<C-s-down>")   'buf-move-down)
               (global-set-key (kbd "<C-s-left>")   'buf-move-left)
               (global-set-key (kbd "<C-s-right>")  'buf-move-right)))


;; Install code completion and enable it globally
(use-package company
  :ensure t
  :config
  (global-company-mode))

;; neotree
(use-package neotree
  :init (setq neo-window-width 28)
  :bind ("C-c s" . neotree-toggle))

;; Flycheck
(add-hook 'after-init-hook #'global-flycheck-mode)

;; Shell colours
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)


(defun gnutls-available-p ()
  "Function redefined in order not to use built-in GnuTLS support."
  nil)                                        ;

;; All Programming languages
(use-package dash)
(add-hook 'prog-mode-hook #'hs-minor-mode)
(add-hook 'prog-mode-hook 'nlinum-mode)
(add-hook 'prog-mode-hook 'column-number-mode)
(add-hook 'prog-mode-hook 'whitespace-mode)

;; Makefile
(add-hook 'makefile-mode-hook 'indent-tabs-mode)

;; Clojure
(use-package clojure-mode
  :config (progn
            (add-hook 'clojure-mode-hook 'rainbow-delimiters-mode)
            (add-hook 'clojure-mode-hook 'nlinum-mode)
            (add-hook 'clojure-mode-hook 'column-number-mode)))

(add-to-list 'auto-mode-alist '("\\.clj\\'" . clojure-mode))
(add-to-list 'auto-mode-alist '("\\.boot\\'" . clojure-mode))

;; Install and configure Cider
(use-package cider
  :ensure t
  :config
  ;; When using Homebrew on the macOS
  (setq cider-lein-command "/usr/local/bin/lein")
  (setq cider-repl-print-length 25)
  ;; When following along with Project Trivia
  (setq cider-cljs-lein-repl "(do (use 'figwheel-sidecar.repl-api) (start-figwheel!) (cljs-repl))"))

(use-package clj-refactor
  :ensure t
  :config
  (add-hook 'clojure-mode-hook #'clj-refactor-mode))

;; Planck
;(add-hook 'clojure-mode-hook #'inf-clojure-minor-mode)
(add-hook 'clojure-mode-hook #'eldoc-mode)
(add-hook 'inf-clojure-mode-hook #'eldoc-mode)
(setq-default inf-clojure-program "planck")

;; Clojurescript
(defun cljs-node-repl ()
  (interactive)
  (run-clojure "java -cp cljs.jar clojure.main repl.clj"))

;; Install paredit, enable in elisp and Clojure modes
(use-package paredit
  :ensure t
  :config
  (add-hook 'emacs-lisp-mode-hook #'enable-paredit-mode)
  (add-hook 'clojure-mode-hook #'enable-paredit-mode)
  (add-hook 'cider-repl-mode-hook #'enable-paredit-mode))


;; Leiningen
(setq-default exec-path (append exec-path '("/usr/local/bin")))

;; Python
(use-package elpy
  :config
  (elpy-enable)
  (elpy-use-ipython))

;; Git
(use-package magit
  :ensure t)

;; Docker
(use-package dockerfile-mode
  :ensure t)

;; Org-mode
;; refs:
;; http://jonathanchu.is/posts/org-mode-and-mobileorg-installation-and-config/
;; https://emacs.cafe/emacs/orgmode/gtd/2017/06/30/orgmode-gtd.html
(use-package org
  :bind (("C-c c" . org-capture)
         ("C-c l" . org-store-link)
         ("C-c a" . org-agenda))
  :config
  (setq org-log-done t)
  (add-hook 'org-mode-hook #'visual-line-mode)
  (setq org-agenda-files (list "~/Dropbox/org/inbox.org"
                               "~/Dropbox/org/work.org"
                               "~/Dropbox/org/home.org"
                               "~/Dropbox/org/tickler.org"))
  (setq org-capture-templates '(("t" "Todo [inbox]" entry
                                 (file+headline "~/Dropbox/org/inbox.org" "Tasks")
                                 "* TODO %i%?")
                                ("T" "Tickler" entry
                                 (file+headline "~/Dropbox/org/tickler.org" "Tickler")
                                 "* %i%? \n %U")))
  (setq org-refile-targets '(("~/Dropbox/org/home.org" :maxlevel . 3)
                             ("~/Dropbox/org/work.org" :maxlevel . 3)
                             ("~/Dropbox/org/someday.org" :level . 1)
                             ("~/Dropbox/org/tickler.org" :maxlevel . 2)))
  (setq org-directory "~/Dropbox/org")
  (setq org-mobile-inbox-for-pull "~/Dropbox/org/inbox.org")
  (setq org-mobile-directory "~/Dropbox/Apps/MobileOrg")
  (setq org-mobile-files '("~/Dropbox/org"))
  ;; Settings to export code with `minted' instead of `verbatim'.
  (setq org-export-latex-listings t)
  (setq org-latex-listings 'minted
        org-latex-packages-alist '(("" "minted"))
        org-latex-pdf-process
        '("pdflatex -shell-escape -intera")))

(use-package org-bullets
  :ensure t
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))


(provide 'init)
;;; init.el ends here
