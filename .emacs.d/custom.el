;;; -*- lexical-binding: t -*-
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(doc-view-continuous t)
 '(package-selected-packages
   '(auctex breadcrumb buffer-move cape consult corfu diff-hl diredfl
            drag-stuff emmet-mode exec-path-from-shell ghostel
            haskell-ts-mode helpful json5-ts-mode ligature magit
            marginalia markdown-mode mips-mode modus-themes moody
            multiple-cursors orderless org-fragtog pdf-tools
            rainbow-delimiters raku-mode surround uiua-ts-mode vertico
            vterm web-mode))
 '(safe-local-variable-values
   '((eval add-hook 'eglot-managed-mode-hook
           (lambda nil (eglot-inlay-hints-mode -1)) nil t))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(region ((t :extend nil))))
