;;; -*- lexical-binding: t -*-
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(doc-view-continuous t)
 '(package-selected-packages
   '(auctex breadcrumb buffer-move cape consult corfu csv-mode diff-hl
            diredfl doom-modeline drag-stuff eglot emmet-mode
            exec-path-from-shell fish-mode ghostel graphviz-dot-mode
            haskell-ts-mode helpful json5-ts-mode ligature magit
            marginalia markdown-mode mips-mode modus-themes moody
            multiple-cursors orderless org-fragtog pdf-tools
            rainbow-delimiters raku-mode sed-mode surround
            uiua-ts-mode vertico vterm vue3-mode web-mode))
 '(safe-local-variable-values
   '((eglot-server-programs
      ((c-mode c++-mode) "clangd"
       "--query-driver=/usr/bin/riscv64-linux-gnu-*"))
     (eval add-hook 'eglot-managed-mode-hook
           (lambda nil (eglot-inlay-hints-mode -1)) nil t)))
 '(send-mail-function 'mailclient-send-it))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(rainbow-delimiters-depth-1-face ((((class color) (min-colors 256)) :foreground "#ddb3ff")))
 '(rainbow-delimiters-depth-2-face ((((class color) (min-colors 256)) :foreground "#6eadff")))
 '(rainbow-delimiters-depth-3-face ((((class color) (min-colors 256)) :foreground "#ffc849")))
 '(rainbow-delimiters-depth-4-face ((((class color) (min-colors 256)) :foreground "#c1dd4a")))
 '(rainbow-delimiters-depth-5-face ((((class color) (min-colors 256)) :foreground "#fe8dc0")))
 '(rainbow-delimiters-depth-6-face ((((class color) (min-colors 256)) :foreground "#88d9eb")))
 '(region ((t :extend nil))))
