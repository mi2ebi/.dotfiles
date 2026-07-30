;;; utils.el --- Personal utilities -*- lexical-binding: t -*-

;;; editing

(defun evie/beginning-of-line-dwim ()
  "Go to first non-whitespace character, or BOL if already there."
  (interactive "^")
  (let ((origin (point)))
    (back-to-indentation)
    (when (= origin (point))
      (move-beginning-of-line 1))))

(defun evie/open-line-above ()
  "Open a new line above point and move there."
  (interactive)
  (beginning-of-line)
  (open-line 1)
  (indent-according-to-mode))

(defun evie/open-line-below ()
  "Open a new line below point and move there."
  (interactive)
  (end-of-line)
  (newline)
  (indent-according-to-mode))

(defun evie/expand-region-to-lines ()
  "Expand the active region to cover whole lines, including trailing newline."
  (interactive)
  (let ((beg (save-excursion
               (goto-char (if (use-region-p) (region-beginning) (point)))
               (line-beginning-position)))
        (end (save-excursion
               (goto-char (if (use-region-p) (region-end) (point)))
               (if (and (use-region-p) (bolp)) (point) (line-beginning-position 2)))))
      (goto-char beg)
      (set-mark end)
      (setq transient-mark-mode (cons 'only transient-mark-mode))))

(defun evie/duplicate-sexp-before-point ()
  "Duplicate the sexp immediately before point, inserting the copy right after it."
  (interactive)
  (let* ((end (point))
         (start (save-excursion (backward-sexp) (point)))
         (sexp-text (buffer-substring-no-properties start end)))
    (save-excursion (insert sexp-text))))

(global-set-key (kbd "C-a")    #'evie/beginning-of-line-dwim)
(global-set-key (kbd "<home>") #'evie/beginning-of-line-dwim)
(global-set-key (kbd "C-S-o")  #'evie/open-line-above)
(global-set-key (kbd "C-o")    #'evie/open-line-below)
(global-set-key (kbd "C-x L")  #'evie/expand-region-to-lines)
(global-set-key (kbd "C-c d")  #'evie/duplicate-sexp-before-point)

(defun evie/upcase-dwim (&optional n)
  "Upcase the region if active, otherwise N characters at point (default 1)."
  (interactive "*p")
  (if (use-region-p)
      (upcase-region (region-beginning) (region-end))
    (upcase-region (point) (+ (point) n))))

(defun evie/downcase-dwim (&optional n)
  "Downcase the region if active, otherwise N characters at point (default 1)."
  (interactive "*p")
  (if (use-region-p)
      (downcase-region (region-beginning) (region-end))
    (downcase-region (point) (+ (point) n))))

(defun evie/capitalize-dwim (&optional n)
  "Capitalize the region if active, otherwise N characters at point (default 1)."
  (interactive "*p")
  (if (use-region-p)
      (capitalize-region (region-beginning) (region-end))
    (capitalize-region (point) (+ (point) n))))

(global-set-key (kbd "C-x C-u") #'evie/upcase-dwim)
(global-set-key (kbd "M-u") #'evie/upcase-dwim)
(global-set-key (kbd "C-x C-l") #'evie/downcase-dwim)
(global-set-key (kbd "M-l") #'evie/downcase-dwim)
(global-set-key (kbd "M-c") #'evie/capitalize-dwim)

;;; vterm

(defun evie/vterm-insert-unicode ()
  "Send a Unicode character to vterm by name or codepoint."
  (interactive)
  (vterm-send-string (string (read-char-by-name "Unicode char: "))))

(defun evie/vterm-compose (&optional input-method)
  "Compose text in the minibuffer (with optional INPUT-METHOD) and send it to vterm."
  (interactive (list (read-input-method-name
                      (format "Input method (default %s): "
                              (or current-input-method "none"))
                      current-input-method)))
  (let ((str (minibuffer-with-setup-hook
                 (lambda ()
                   (when (and input-method (not (string-empty-p input-method)))
                     (activate-input-method input-method)))
               (read-from-minibuffer "Compose: "))))
    (vterm-send-string str)))

(with-eval-after-load 'vterm
  (define-key vterm-mode-map (kbd "C-c 8")    #'evie/vterm-insert-unicode)
  (define-key vterm-mode-map (kbd "C-c C-\\") #'evie/vterm-compose))

(provide 'utils)

;;; utils.el ends here
