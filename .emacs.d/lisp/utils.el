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

(global-set-key (kbd "C-a")    #'evie/beginning-of-line-dwim)
(global-set-key (kbd "<home>") #'evie/beginning-of-line-dwim)
(global-set-key (kbd "C-S-o")  #'evie/open-line-above)
(global-set-key (kbd "C-x L")  #'evie/expand-region-to-lines)

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
