;;; init.el -*- lexical-binding: t -*-

;;; package bootstrap

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("gnu-devel" . "https://elpa.gnu.org/devel/") t)
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

;;; appearance

(set-face-attribute 'default nil :family "iosevie" :height 120)
(set-face-attribute 'fixed-pitch nil :family "iosevie")
(set-face-attribute 'variable-pitch nil :family "Lato" :height 130)

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

(use-package moody
  :config
  (moody-replace-mode-line-front-space)
  (moody-replace-mode-line-buffer-identification)
  (set-face-attribute 'mode-line-active nil :box 'unspecified)
  (set-face-attribute 'mode-line-inactive nil :box 'unspecified))

(use-package breadcrumb
  :config (breadcrumb-mode 1))

(custom-set-faces '(region ((t :extend nil))))

(use-package diredfl
  :config (diredfl-global-mode 1))

(use-package ligature
  :ensure t
  :config
  (ligature-set-ligatures 't '(
                               ("-" (rx (* "-") (? ">")))         ; -- -> --- -->
                               ("=" (rx (* "=") (? ">")))         ; == => === ==>
                               ("+" (rx (+ "+")))                 ; ++ +++
                               ("_" (rx (+ "_")))                 ; __ ___
                               ("|" (rx (+ "|")))                 ; || |||
                               ("/" (rx (+ "/")))                 ; // ///
                               ("<" (rx (| (+ "<")                ; << <<<
                                           (: (+ "=") (? ">"))    ; <=> <== <==>
                                           (: (+ "-") (? ">"))))) ; <- <-> <-- <-->
                               (">" (rx (| (+ ">") "=")))         ; >> >= >>>
                               ("." (rx (+ (any ".!?:"))))        ; .. .! .? .: ...
                               (":" (rx (+ (any ".!?:"))))        ; :: :! :? :. :::
                               ("?" (rx (+ (any ".!?:"))))        ; ?! ?: ?. ??
                               ("!" (rx (+ (any ".!?:"))))        ; !: !? !. !!
                               ("," (rx (+ (any ",;"))))          ; ,, ,;
                               (";" (rx (+ (any ",;"))))          ; ;; ;,
                               ))
  (global-ligature-mode t))

;;; unicode font fallbacks

(set-fontset-font t '(#x03e2 . #x03ef) "Lato")
(set-fontset-font t '(#x0590 . #x05ff) "Noto Sans Hebrew")
(set-fontset-font t '(#x0600 . #x06ff) "Noto Sans Arabic")
(set-fontset-font t '(#x0700 . #x077f) "Noto Sans Syriac Eastern")
(set-fontset-font t '(#x0750 . #x077f) "Noto Sans Arabic")
(set-fontset-font t '(#x0780 . #x07bf) "Noto Sans Thaana")
(set-fontset-font t '(#x07c0 . #x07ff) "Noto Sans NKo")
(set-fontset-font t '(#x0800 . #x083f) "Noto Sans Samaritan")
(set-fontset-font t '(#x0840 . #x085f) "Noto Sans Mandaic")
(set-fontset-font t '(#x0860 . #x086f) "Plangothic P2")
(set-fontset-font t '(#x0870 . #x089f) "Noto Sans Arabic")
(set-fontset-font t '(#x08a0 . #x08ff) "Noto Sans Arabic")
(set-fontset-font t '(#x0900 . #x097f) "Noto Sans Devanagari")
(set-fontset-font t '(#x0980 . #x09ff) "Noto Sans Bengali")
(set-fontset-font t '(#x0a00 . #x0a7f) "Noto Sans Gurmukhi")
(set-fontset-font t '(#x0a80 . #x0aff) "Noto Sans Gujarati")
(set-fontset-font t '(#x0b00 . #x0b7f) "Noto Sans Oriya")
(set-fontset-font t '(#x0b80 . #x0bff) "Noto Sans Tamil")
(set-fontset-font t '(#x0c00 . #x0c7f) "Noto Sans Telugu")
(set-fontset-font t '(#x0c80 . #x0cff) "Noto Sans Kannada")
(set-fontset-font t '(#x0d00 . #x0d7f) "Noto Sans Malayalam")
(set-fontset-font t '(#x0d80 . #x0dff) "Noto Sans Sinhala")
(progn (set-fontset-font t '(#x0e00 . #x0e7f) "Noto Sans Thai")
       (set-fontset-font t #x0e3f "iosevie"))
(set-fontset-font t '(#x0e80 . #x0eff) "Noto Sans Lao")
(set-fontset-font t '(#x0f00 . #x0fff) "Noto Serif Tibetan") ; todo plangothic p2 ?
(set-fontset-font t '(#x1000 . #x109f) "Padauk")
(set-fontset-font t '(#x10a0 . #x10ff) "Noto Sans Georgian")
(set-fontset-font t '(#x1100 . #x11ff) "Noto Sans CJK KR")
(set-fontset-font t '(#x1200 . #x137f) "Noto Sans Ethiopic")
(set-fontset-font t '(#x1380 . #x139f) "Noto Sans Ethiopic")
(set-fontset-font t '(#x13a0 . #x13ff) "Noto Sans Cherokee")
(set-fontset-font t '(#x1400 . #x167f) "Noto Sans Canadian Aboriginal")
(set-fontset-font t '(#x1680 . #x169f) "Noto Sans Ogham")
(set-fontset-font t '(#x16a0 . #x16ff) "Noto Sans Runic")
(set-fontset-font t '(#x1700 . #x171f) "Noto Sans Tagalog")
(set-fontset-font t '(#x1720 . #x173f) "Noto Sans Hanunoo")
(set-fontset-font t '(#x1740 . #x175f) "Noto Sans Buhid")
(set-fontset-font t '(#x1760 . #x177f) "Noto Sans Tagbanwa")
(set-fontset-font t '(#x1780 . #x17ff) "Noto Sans Khmer")
(set-fontset-font t '(#x1800 . #x18af) "Noto Sans Mongolian")
(set-fontset-font t '(#x18b0 . #x18ff) "Noto Sans Canadian Aboriginal")
(set-fontset-font t '(#x1900 . #x194f) "Noto Sans Limbu")
(set-fontset-font t '(#x1950 . #x197f) "Noto Sans Tai Le")
(set-fontset-font t '(#x1980 . #x19df) "Noto Sans New Tai Lue")
(set-fontset-font t '(#x19e0 . #x19ff) "Noto Sans Khmer")
(set-fontset-font t '(#x1a00 . #x1a1f) "Noto Sans Buginese")
(set-fontset-font t '(#x1a20 . #x1aaf) "Noto Sans Tai Tham")
(progn (set-fontset-font t '(#x1ab0 . #x1aff) "Noto Sans" nil 'append)
       (set-fontset-font t '(#x1ab0 . #x1aff) "Plangothic P2" nil 'append))
(progn (set-fontset-font t '(#x1b00 . #x1b7f) "Noto Sans Balinese")
       (set-fontset-font t '(#x1b00 . #x1b7f) "Plangothic P2" nil 'append))
(set-fontset-font t '(#x1b80 . #x1bbf) "Noto Sans Sundanese")
(set-fontset-font t '(#x1bc0 . #x1bff) "Noto Sans Batak")
(set-fontset-font t '(#x1c00 . #x1c4f) "Noto Sans Lepcha")
(set-fontset-font t '(#x1c50 . #x1c7f) "Noto Sans Ol Chiki")
(set-fontset-font t '(#x1c90 . #x1cbf) "Noto Sans Georgian")
(set-fontset-font t '(#x1cc0 . #x1ccf) "Noto Sans Sundanese")
(progn (set-fontset-font t '(#x1cd0 . #x1cff) "Noto Sans Devanagari")
       (set-fontset-font t '(#x1cd0 . #x1cff) "Noto Sans Bengali" nil 'append)
       (set-fontset-font t '(#x1cd0 . #x1cff) "Plangothic P2" nil 'append))
(progn (set-fontset-font t '(#x1dc0 . #x1dff) "iosevie")
       (set-fontset-font t '(#x1dc0 . #x1dff) "Adwaita Sans" nil 'append)) ; a᷐ ?? why does it use noto serif
(progn (set-fontset-font t '(#x20a0 . #x20cf) "iosevie")
       (set-fontset-font t '(#x20a0 . #x20cf) "Lato" nil 'append)
       (set-fontset-font t '(#x20a0 . #x20cf) "Noto Sans" nil 'append)
       (set-fontset-font t '(#x20a0 . #x20cf) "Plangothic P2" nil 'append))
(progn (set-fontset-font t '(#x20d0 . #x20ff) "iosevie")
       (set-fontset-font t '(#x20d0 . #x20ff) "Noto Sans Math" nil 'append)
       (set-fontset-font t '(#x20d0 . #x20ff) "Noto Sans Symbols" nil 'append))
                                        ; these don't work either. in emacs' defense
                                        ; they are mostly very dumb characters. like
                                        ; who the fuck needs u+20e2 COMBINING SCREEN
(progn (set-fontset-font t '(#x2100 . #x214f) "iosevie")
       (set-fontset-font t '(#x2100 . #x214f) "STIX" nil 'append))

(set-fontset-font t '(#x2d20 . #x2d2f) "Noto Sans Georgian")

(set-fontset-font t '(#x11fc0 . #x11fff) "Noto Sans Tamil Supplement") ; ...why,

(set-fontset-font t '(#x2600 . #x27bf) "Noto Color Emoji" nil 'append)
(set-fontset-font t '(#x27c0 . #x2bff) "IBM Plex Math" nil 'append)
(set-fontset-font t '(#x1d000 . #x1d1ff) "Noto Music" nil 'append)
(set-fontset-font t '(#x1d400 . #x1d7ff) "IBM Plex Math" nil 'append)
(set-fontset-font t '(#x1df00 . #x1dfff) "Andika" nil 'append)
(set-fontset-font t '(#x1f000 . #x1faff) "Noto Color Emoji")
(set-fontset-font t '(#x20000 . #x2fa1f) "Plangothic P1" nil 'append)
(set-fontset-font t '(#x30000 . #x323af) "Plangothic P2" nil 'append)
;; last resort
(set-fontset-font t 'unicode "Plangothic P1" nil 'append)
(set-fontset-font t 'unicode "Plangothic P2" nil 'append)
(set-fontset-font t 'unicode "Unifont" nil 'append)
(set-fontset-font t 'unicode "Unifont Upper" nil 'append)

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

(use-package flymake
  :bind ("<left-fringe> <mouse-3>" . flymake-show-project-diagnostics))

(require 'treesit)
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode))
(add-to-list 'treesit-language-source-alist
             '(rust "https://github.com/tree-sitter/tree-sitter-rust"))
(add-to-list 'treesit-language-source-alist
             '(json5 "https://github.com/Joakker/tree-sitter-json5"))

(use-package eglot
  :bind ("C-." . eglot-code-actions)
  :hook
  (c++-ts-mode . eglot-ensure)
  (rust-ts-mode . eglot-ensure)
  (eglot-managed-mode . (lambda ()
                    (add-hook 'before-save-hook #'eglot-format-buffer nil t)))
  :config
  (setq-default
   eglot-workspace-configuration
   '(:rust-analyzer
     (:check
      (:overrideCommand ["sh" "-c"
                         "cargo xnitpick && cargo doc --no-deps --message-format=json"])
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
        TeX-view-program-selection '((output-pdf "PDF Tools"))))

(use-package markdown-mode
  :ensure t
  :config
  (setq-default markdown-command "pandoc -s"))

;;; terminal

(use-package vterm
  :config (setq vterm-set-bold-highbright t
                vterm-timer-delay 0))

(global-set-key (kbd "C-c v") #'vterm)
(global-set-key (kbd "C-c C-v") #'vterm-other-window)

;;; init.el ends here
