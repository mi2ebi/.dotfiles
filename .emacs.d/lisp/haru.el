;;; haru.el --- haru palettes for modus-themes -*- lexical-binding: t -*-

(require 'cl-lib)
(require 'color)

(defconst haru-yoru
  '((sakura . "#ffc5da") (nadeshiko . "#ffadda") (botan . "#fe8dc0")
    (fuji . "#ddb3ff") (kikyo . "#99b2f5") (beni . "#ff8b79")
    (akane . "#ffa2b5") (kaki . "#ffbb74") (yamabuki . "#ffc849")
    (wakaba . "#c1dd4a") (tokiwa . "#7bd6b6") (sora . "#88d9eb")
    (ruri . "#60c9f3") (ai . "#6eadff") (sumi . "#e1d1e7")
    (usuzumi1 . "#cdbed3") (usuzumi0 . "#b7a8bd") (kasure2 . "#9f93a4")
    (kasure1 . "#8a7e8f") (kasure0 . "#756a7a") (nijimi2 . "#615665")
    (nijimi1 . "#4e4352") (nijimi0 . "#392e3c") (kami . "#241c26")
    (hyoshi . "#1c151f") (chitsu . "#160f18")))

(defconst haru-hiru
  '((sakura . "#aa6e89") (nadeshiko . "#d64891") (botan . "#b25d9d")
    (fuji . "#6928bd") (kikyo . "#4760c0") (beni . "#ce2700")
    (akane . "#ee3244") (kaki . "#fd5217") (yamabuki . "#bda343")
    (wakaba . "#5e8933") (tokiwa . "#009162") (sora . "#008bae")
    (ruri . "#2678af") (ai . "#1955bf") (sumi . "#584a5c")
    (usuzumi1 . "#6b5d70") (usuzumi0 . "#77697c") (kasure2 . "#877b8c")
    (kasure1 . "#998d9e") (kasure0 . "#a99cad") (nijimi2 . "#b8acbd")
    (nijimi1 . "#c8bccd") (nijimi0 . "#d9ccdd") (kami . "#f6eff8")
    (hyoshi . "#ece5ef") (chitsu . "#e2dbe5")))

(defun haru--hex (rgb)
  "RGB list (0-1 floats) -> #rrggbb."
  (apply #'color-rgb-to-hex (append rgb '(2))))

(defun haru--blend (fg bg alpha)
  "FG over BG at ALPHA, as #rrggbb."
  (haru--hex
   (cl-mapcar (lambda (f b) (+ (* alpha f) (* (- 1 alpha) b)))
              (color-name-to-rgb fg) (color-name-to-rgb bg))))

(defun haru--shift-lightness (hex delta)
  "Shift HEX's HSL lightness by DELTA."
  (pcase-let ((`(,h ,s ,l) (apply #'color-rgb-to-hsl (color-name-to-rgb hex))))
    (haru--hex (color-hsl-to-rgb h s (min 1.0 (max 0.0 (+ l delta)))))))

(defun haru-overrides (p)
  "Build a modus palette-overrides list from haru palette P."
  (let ((dark (< (apply #'+ (color-name-to-rgb (alist-get 'kami p))) 1.5)))
    (cl-labels ((c (name) (alist-get name p))
                (mix (name alpha) (haru--blend (c name) (c 'kami) alpha)))
      (append
       ;; paper
       `((bg-main ,(c 'kami))
         (bg-dim ,(c 'hyoshi))
         (bg-alt ,(c 'hyoshi))
         (bg-active ,(c 'nijimi1))
         (bg-inactive ,(c 'hyoshi))
         (bg-hover ,(c 'nijimi1))
         (border ,(c 'nijimi1))
         (fringe ,(c 'kami))
         (bg-mode-line-active ,(c 'chitsu))
         (fg-mode-line-active ,(c 'sumi))
         (border-mode-line-active ,(c 'nijimi1))
         (bg-mode-line-inactive ,(c 'hyoshi))
         (fg-mode-line-inactive ,(c 'usuzumi0))
         (border-mode-line-inactive ,(c 'nijimi0))
         (bg-tab-bar ,(c 'chitsu))
         (bg-tab-current ,(c 'kami))
         (bg-tab-other ,(c 'hyoshi)))
       ;; ink
       `((fg-main ,(c 'sumi))
         (fg-dim ,(c 'usuzumi0))
         (fg-alt ,(c 'usuzumi1))
         (fg-link ,(c 'sora))
         (fg-link-visited ,(c 'fuji))
         (err ,(c 'beni))
         (warning ,(c 'yamabuki))
         (info ,(c 'sora))
         (red ,(c 'beni)) (green ,(c 'wakaba)) (yellow ,(c 'yamabuki))
         (blue ,(c 'ai)) (magenta ,(c 'botan)) (cyan ,(c 'tokiwa)))
       ;; code
       `((keyword ,(c 'fuji))
         (builtin ,(c 'beni))
         (comment ,(c 'kasure2))
         (constant ,(c 'kaki))
         (docstring ,(c 'wakaba))
         (docmarkup ,(c 'botan))
         (fnname ,(c 'ai))
         (preprocessor ,(c 'tokiwa))
         (string ,(c 'wakaba))
         (type ,(c 'yamabuki))
         (variable ,(c 'sumi))
         (property ,(c 'ruri))
         (rx-construct ,(c 'botan))
         (rx-backslash ,(c 'botan)))
       ;; prose
       (cl-loop for i from 0 to 8
                collect (list (intern (format "fg-heading-%d" i)) (c 'fuji)))
       `((fg-prose-code ,(c 'wakaba))
         (fg-prose-verbatim ,(c 'wakaba))
         (fg-prose-macro ,(c 'tokiwa)))
       ;; editor
       `((cursor ,(c 'sakura))
         (bg-hl-line ,(mix 'nijimi0 .45))
         (bg-region ,(mix 'nijimi2 .575))
         (fg-region unspecified)
         (bg-line-number-inactive ,(c 'kami))
         (fg-line-number-inactive ,(c 'nijimi2))
         (bg-line-number-active ,(c 'kami))
         (fg-line-number-active ,(c 'fuji))
         (bg-search-current ,(mix 'kaki .35))
         (bg-search-lazy ,(mix 'kaki .18))
         (bg-paren-match ,(mix 'kasure0 .30)))
       ;; diff
       `((bg-added ,(mix 'wakaba .10))
         (bg-added-refine ,(mix 'wakaba .18))
         (fg-added ,(c 'wakaba))
         (bg-changed ,(mix 'ai .12))
         (bg-changed-refine ,(mix 'ai .28))
         (fg-changed ,(c 'ai))
         (bg-removed ,(mix 'beni .10))
         (bg-removed-refine ,(mix 'beni .18))
         (fg-removed ,(c 'beni)))
       ;; custom entries, read by haru-apply-faces
       (cl-loop for name in '(fuji ai yamabuki wakaba botan sora)
                for i from 1
                collect (list (intern (format "rainbow-%d" i)) (c name)))
       ;; terminal: (name ink bright-ink-or-nil)
       (cl-loop for (name ink bright) in '((black nijimi1 nijimi2) (red beni)
                                           (green wakaba) (yellow yamabuki)
                                           (blue ai) (magenta botan)
                                           (cyan tokiwa) (white usuzumi1 usuzumi0))
                for hex = (c ink)
                for bhex = (if bright (c bright)
                             (haru--shift-lightness hex (if dark .06 -.06)))
                append (list (list (intern (format "bg-term-%s" name)) hex)
                             (list (intern (format "fg-term-%s" name)) hex)
                             (list (intern (format "bg-term-%s-bright" name)) bhex)
                             (list (intern (format "fg-term-%s-bright" name)) bhex)))))))

(setq rainbow-delimiters-max-face-count 6)

(defun haru-apply-faces ()
  "Per-theme faces modus can't express. Run from modus-themes-after-load-theme-hook."
  (modus-themes-with-colors
    (custom-set-faces
     `(rainbow-delimiters-depth-1-face ((,c :foreground ,rainbow-1)))
     `(rainbow-delimiters-depth-2-face ((,c :foreground ,rainbow-2)))
     `(rainbow-delimiters-depth-3-face ((,c :foreground ,rainbow-3)))
     `(rainbow-delimiters-depth-4-face ((,c :foreground ,rainbow-4)))
     `(rainbow-delimiters-depth-5-face ((,c :foreground ,rainbow-5)))
     `(rainbow-delimiters-depth-6-face ((,c :foreground ,rainbow-6))))))

(provide 'haru)
;;; haru.el ends here
