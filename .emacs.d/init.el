;;; init.el -*- lexical-binding: t -*-

;;; package bootstrap

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu-devel" . "https://elpa.gnu.org/devel/") t)
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/") t)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;;; custom file

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file 'noerror)

;;; defaults

(setq-default
 indent-tabs-mode nil
 tab-width 2
 standard-indent 2
 backup-directory-alist '(("." . "~/.emacs.d/backups"))
 auto-save-default nil)

(setq inhibit-startup-screen t)
(global-auto-revert-mode 1)
(delete-selection-mode 1)
(show-paren-mode 1)
(electric-pair-mode 1)
(column-number-mode 1)
(global-display-line-numbers-mode 0)

;; use utf-8 for everything
(set-language-environment "UTF-8")
(set-clipboard-coding-system 'utf-8)
(setq-default buffer-file-coding-system 'utf-8-unix)

;;; env

(setenv "PKG_CONFIG_PATH" "/usr/lib64/pkgconfig:/usr/share/pkgconfig")
(add-to-list 'exec-path (expand-file-name "~/.cargo/bin"))

;;; local lisp

(add-to-list 'load-path "~/.emacs.d/lisp")
(require 'toaq)
(require 'pacifism)
(require 'utils) 
(require 'unicode)

;;; appearance

(set-face-attribute 'default nil :family "iosevie" :height 120)
(set-face-attribute 'fixed-pitch nil :family "iosevie")
(set-face-attribute 'variable-pitch nil :family "Lato" :height 130)
(setq use-default-font-for-symbols nil)

(use-package modus-themes
  :config
  (setq
   modus-themes-bold-constructs t
   modus-themes-italic-constructs t
   modus-themes-common-palette-overrides
   '(
     (bg-region bg-magenta-subtle)
     (fg-region unspecified)
     (bg-mode-line-active bg-magenta-subtle)
     (bg-mode-line-inactive bg-magenta-nuanced)
     (fringe bg-magenta-nuanced)
     (bg-term-magenta-bright magenta-warmer)
     (fg-term-magenta-bright magenta-warmer)
     (bg-term-cyan-bright cyan-warmer)
     (fg-term-cyan-bright cyan-warmer)
     )
   modus-vivendi-tinted-palette-overrides '((bg-main "#000"))
   modus-operandi-tinted-palette-overrides '((bg-main "#fff"))
   )
  (modus-themes-load-theme 'modus-vivendi-tinted))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

(use-package breadcrumb
  :config (breadcrumb-mode 1))

(custom-set-faces '(region ((t :extend nil))))

(use-package diredfl
  :config (diredfl-global-mode 1))

;;; completion

(use-package vertico
  :init (vertico-mode))

(use-package marginalia
  :init (marginalia-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package corfu
  :init (global-corfu-mode)
  :config
  (setq corfu-auto t
        corfu-auto-delay 0.2
        corfu-auto-prefix 2))

(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

;;; navigation

(use-package consult
  :bind (("C-s"   . consult-line)
         ("C-x b" . consult-buffer)
         ("M-g i" . consult-imenu)
         ("M-y"   . consult-yank-pop)))

;;; editing

(global-set-key (kbd "C-S-d")  #'duplicate-dwim)
(global-set-key (kbd "M-u")    #'upcase-dwim)
(global-set-key (kbd "M-l")    #'downcase-dwim)
(global-set-key (kbd "M-c")    #'capitalize-dwim)
(global-set-key (kbd "M-SPC")  #'set-mark-command)
(global-set-key (kbd "M-\\")   #'cycle-spacing)
(global-set-key (kbd "M-j")    #'join-line)

(use-package surround
  :bind-keymap ("M-'" . surround-keymap))

(use-package multiple-cursors
  :bind (("M-<mouse-1>" . mc/add-cursor-on-click))
  :init
  (global-unset-key (kbd "M-<down-mouse-1>")))

(global-unset-key (kbd "M-<drag-mouse-1>"))
(global-unset-key (kbd "M-<mouse-2>"))
(global-unset-key (kbd "M-<mouse-3>"))

(use-package drag-stuff
  :config (drag-stuff-global-mode 1)
  :bind (("M-<up>"    . drag-stuff-up)
         ("M-<down>"  . drag-stuff-down)
         ("M-<left>"  . drag-stuff-left)
         ("M-<right>" . drag-stuff-right)))

;;; windows

(winner-mode 1)
(global-set-key (kbd "M-o")   #'other-window)
(global-set-key (kbd "C-x u") #'winner-undo)
(global-set-key (kbd "C-x U") #'winner-redo)

(use-package buffer-move
  :bind (("C-M-<up>"    . buf-move-up)
         ("C-M-<down>"  . buf-move-down)
         ("C-M-<left>"  . buf-move-left)
         ("C-M-<right>" . buf-move-right)))

;;; reclaim wasted keys

(global-set-key (kbd "C-z")     #'undo)
(global-set-key (kbd "C-S-z")   #'undo-redo)
(global-set-key (kbd "C-x C-b") #'ibuffer)
(global-set-key (kbd "C-x C-r") #'recentf-open)
(global-unset-key (kbd "C-x C-n"))
(global-unset-key (kbd "C-x C-d"))

(recentf-mode 1)

;;; help

(use-package which-key
  :config (which-key-mode))

(use-package helpful
  :bind
  ([remap describe-function] . helpful-callable)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key]      . helpful-key))

;;; git

(use-package magit
  :bind ("C-x g" . magit-status))

(use-package diff-hl
  :init
  (global-diff-hl-mode 1)
  (diff-hl-flydiff-mode 1)
  :config (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
  :bind (("<mouse-8>" . diff-hl-previous-hunk)
         ("<mouse-9>" . diff-hl-next-hunk)
         ("M-g r" . diff-hl-revert-hunk)))

;;; lsp / languages

(setq project-vc-extra-root-markers '("Cargo.toml"))

(use-package flymake
  :bind ("<left-fringe> <mouse-3>" . flymake-show-project-diagnostics))

(require 'treesit)
(add-to-list 'auto-mode-alist '("\\.c\\'" . c-ts-mode))
(add-to-list 'auto-mode-alist '("\\.h\\'" . c-ts-mode))
(add-to-list 'auto-mode-alist '("\\.cc\\'" . c++-ts-mode))
(add-to-list 'auto-mode-alist '("\\.cpp\\'" . c++-ts-mode))
(add-to-list 'auto-mode-alist '("\\.cxx\\'" . c++-ts-mode))
(add-to-list 'auto-mode-alist '("\\.hpp\\'" . c++-ts-mode))
(add-to-list 'auto-mode-alist '("\\.hh\\'" . c++-ts-mode))
(add-to-list 'auto-mode-alist '("\\.hxx\\'" . c++-ts-mode))
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode))
(add-to-list 'auto-mode-alist '("\\.py\\'" . python-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
(add-to-list 'treesit-language-source-alist
             '(c "https://github.com/tree-sitter/tree-sitter-c"))
(add-to-list 'treesit-language-source-alist
             '(cpp "https://github.com/tree-sitter/tree-sitter-cpp"))
(add-to-list 'treesit-language-source-alist
             '(rust "https://github.com/tree-sitter/tree-sitter-rust"))
(add-to-list 'treesit-language-source-alist
             '(json5 "https://github.com/Joakker/tree-sitter-json5"))

(use-package eglot
  :bind ("C-." . eglot-code-actions)
  :hook
  (c-ts-mode . eglot-ensure)
  (c++-ts-mode . eglot-ensure)
  (rust-ts-mode . eglot-ensure)
  (raku-mode . eglot-ensure)
  (python-mode . eglot-ensure)
  (eglot-managed-mode . (lambda ()
                          (add-hook 'before-save-hook #'eglot-format-buffer nil t)))
  :config
  (add-to-list 'eglot-server-programs
               (cons 'raku-mode
                     (list "node"
                           (expand-file-name
                            "~/.local/src/RakuNavigator/server/out/server.js")
                           "--stdio")))
  (setq-default
   eglot-workspace-configuration
   '(:rust-analyzer
     (:check
      (:overrideCommand ["sh" "-c"
                         "cargo xnitpick && cargo doc --no-deps --message-format=json --document-private-items"])
      :cargo (:features "all")
      :diagnostics
      (:experimental (:enable t) :styleLints (:enable t))
      :inlayHints
      (:closureCaptureHints
       (:enable t)
       :closureReturnTypeHints
       (:enable "always"))))))

(use-package web-mode
  :mode ("\\.html?\\'" . web-mode))

(use-package emmet-mode
  :hook (web-mode . emmet-mode))

(use-package org-fragtog
  :hook (org-mode . org-fragtog-mode))

(setq c-default-style "stroustrup" c-basic-offset 2)
(add-hook 'c-mode-common-hook (lambda () (c-set-offset 'case-label '+)))

(use-package pdf-tools
  :ensure t
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (pdf-tools-install)
  (setq pdf-view-resolution 200
        pdf-view-use-scaling t))
(use-package tex
  :ensure auctex
  :mode ("\\.tex\\'" . latex-mode)
  :config
  (setq-default TeX-engine 'xetex)
  (setq TeX-parse-self t
        TeX-auto-save 1
        TeX-view-program-selection '((output-pdf "PDF Tools"))
        font-latex-fontify-script nil))

(use-package markdown-mode
  :ensure t
  :config
  (setq-default markdown-command "pandoc -s"))

;;; terminal

(use-package ghostel
  :ensure t
  :config (setq ghostel-bold-color 'bright))

(global-set-key (kbd "C-c t") #'ghostel)

;;; init.el ends here
