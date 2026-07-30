;;; toaq.el --- Toaq input method for Emacs -*- lexical-binding: t -*-

(require 'quail)
(require 'ucs-normalize)
(require 'cl-lib)

(quail-define-package
 "toaq" "UTF-8" "Ꝡ" nil
 "An input method for Toaq.

Letters: w -> ꝡ, i -> ı, x -> ’
Quotes: [] -> «», {} -> ‹›

Tones can be set and removed mid- and post-raku as well as after a
word. On common toned words the tones are added for you after the word
ends (and can still be changed later).

  ' -> acute
  ; -> circumflex
  \" -> diaeresis
Previous versions of Toaq:
  : -> hook
  = -> macron
  + -> grave
  ^ -> hacek
  ~ -> tilde

v -> prefix underdot (toggles, only works on raku)
` -> undo last tone (works on both raku and words);
     if only underdot remains, undo that too
\\ -> escape next key, e.g. \\ SPC suppresses automatic tones")

(defun toaq--vowel-p (ch)
  "Return t if CH is a Toaq vowel."
  (and ch (string-match-p "[aeiıouyAEIOUY]"
                          (string (aref (ucs-normalize-NFD-string (string ch)) 0)))))
(defun toaq--final-p (ch)
  "Return t if CH is a Toaq final (m or q)."
  (and ch (string-match-p "[mqMQ]" (string ch))))
(defun toaq--tone-p (ch)
  "Return t if CH is a Toaq tone mark (not underdot)."
  (and ch (memq ch '(?\x0300 ?\x0301 ?\x0302 ?\x0303 ?\x0304 ?\x0308 ?\x0309 ?\x030c))))
(defun toaq--combining-p (ch)
  "Return t if CH is a Toaq tone mark or underdot."
  (and ch (memq ch '(?\x0300 ?\x0301 ?\x0302 ?\x0303 ?\x0304 ?\x0308 ?\x0309 ?\x030c ?\x0323))))

(defun toaq--char-extent (pos)
  "Return (START . END) of the character at POS including combining characters after it."
  (let ((end (1+ pos)))
    (save-excursion
      (goto-char end)
      (while (toaq--combining-p (char-after))
        (forward-char)
        (setq end (point))))
    (cons pos end)))

(defun toaq--find-nucleus ()
  "Scan backwards from point to find the (START . END) of a Toaq raku nucleus."
  (save-excursion
    (while (toaq--final-p (char-before))
      (backward-char))
    (while (toaq--combining-p (char-before))
      (backward-char))
    (when (toaq--vowel-p (char-before))
      (let ((end (point)))
        (while (let ((ch (char-before)))
                 (or (toaq--vowel-p ch) (toaq--combining-p ch)))
          (backward-char))
        (cons (point) end)))))

(defvar-local toaq--escape-next nil
  "When non-nil, the next key will insert literally instead of applying its normal behavior.")

(defvar-local toaq--suppress-default-tone nil
  "When non-nil, the word currently being typed will not receive its
default tone when a word boundary is reached. Set by `toaq-undo-diacritic'
and consumed by `toaq--maybe-apply-default-tone'.")

(defun toaq-escape ()
  "Set the escape flag so the next keypress will be literal."
  (interactive)
  (if toaq--escape-next
      (progn
        (setq toaq--escape-next nil)
        (insert "\\"))
    (setq toaq--escape-next t)
    (message "toaq: literal next")))

(defun toaq--clear-escape-on-unbound ()
  "Clear escape flag if a non-Toaq key is pressed."
  (when (and toaq--escape-next
             (not (lookup-key toaq-keymap (this-command-keys))))
    (setq toaq--escape-next nil)))

(defun toaq--extent-diacritics (extent)
  "Return (BASE-CHAR . DIACRITICS) for the character cluster spanning
EXTENT, where DIACRITICS is the list of combining characters (tones
and/or underdot) already applied to it, in NFD order."
  (let ((base-str (ucs-normalize-NFD-string
                    (buffer-substring (car extent) (cdr extent)))))
    (cons (aref base-str 0) (append (substring base-str 1) nil))))

(defun toaq--nucleus-has-tone-p (nucleus)
  "Return t if the first vowel of NUCLEUS already carries a tone mark
(not counting underdot)."
  (cl-some #'toaq--tone-p
           (cdr (toaq--extent-diacritics (toaq--char-extent (car nucleus))))))

(defun toaq--nucleus-has-underdot-p (nucleus)
  "Return t if the first vowel of NUCLEUS carries an underdot."
  (and (memq ?\x0323
             (cdr (toaq--extent-diacritics (toaq--char-extent (car nucleus)))))
       t))

(defun toaq--set-nucleus-tone (nucleus combining-char)
  "Apply COMBINING-CHAR as the tone on the first vowel of NUCLEUS,
replacing any existing tone mark but preserving underdot. Toggles
underdot if already present. Moves point to track its position
relative to the edit."
  (let ((target-pos (car nucleus))
        (original-pos (point)))
    (let* ((extent (toaq--char-extent target-pos))
           (diacritics (toaq--extent-diacritics extent))
           (base-char (car diacritics))
           (has-existing-v (memq ?\x0323 (cdr diacritics)))
           (existing-tones (cl-remove-if-not #'toaq--tone-p (cdr diacritics)))
           (existing-underdots (cl-remove-if-not (lambda (ch) (= ch ?\x0323))
                                                 (cdr diacritics)))
           (new-diacritics
            (cond
             ((= combining-char ?\x0323)
              (if has-existing-v
                  existing-tones
                (append existing-tones (list ?\x0323))))
             (t
              (append existing-underdots (list combining-char)))))
           (actual-base (cond
                         ((not (memq base-char '(?i ?ı))) base-char)
                         ((cl-some #'toaq--tone-p new-diacritics) ?i)
                         (t ?ı)))
           (new-str (ucs-normalize-NFC-string
                     (concat (string actual-base)
                             (apply #'string new-diacritics))))
           (deleted-len (- (cdr extent) (car extent)))
           (delta (- (length new-str) deleted-len)))
      (delete-region (car extent) (cdr extent))
      (goto-char (car extent))
      (insert new-str)
      (goto-char (if (<= target-pos original-pos)
                     (+ original-pos delta)
                   original-pos)))))

(defun toaq--strip-nucleus-tone (nucleus)
  "Remove any tone mark from the first vowel of NUCLEUS, converting it
back to its bare form (using dotless ı for bare i). If the nucleus
only has an underdot and no tone, remove the underdot too. Moves point
to track its position relative to the edit."
  (let* ((start (car nucleus))
         (extent (toaq--char-extent start))
         (diacritics (toaq--extent-diacritics extent))
         (base-char (car diacritics))
         (has-tone (cl-some #'toaq--tone-p (cdr diacritics)))
         (has-underdot (memq ?\x0323 (cdr diacritics)))
         (keep-underdot (and has-tone has-underdot))
         (new-diacritics (if keep-underdot '(?\x0323) nil))
         (new-str (ucs-normalize-NFC-string
                   (concat (string (if (= base-char ?i) ?ı base-char))
                           (apply #'string new-diacritics))))
         (delta (- (length new-str) (- (cdr extent) (car extent))))
         (orig-pos (point)))
    (delete-region (car extent) (cdr extent))
    (goto-char (car extent))
    (insert new-str)
    (goto-char (if (<= (car extent) orig-pos)
                   (+ orig-pos delta)
                 orig-pos))))

(defun toaq--word-char-p (ch)
  "Return t if CH is a letter that can appear inside a Toaq word."
  (and ch (or (toaq--vowel-p ch)
              (toaq--combining-p ch)
              (string-match-p "[bcdfghjklmnpqrstzꝡBCDFGHJKLMNPQRSTZꝠ’]"
                              (string ch)))))

(defun toaq--word-start (pos)
  "Return the buffer position where the Toaq word ending at POS began."
  (save-excursion
    (goto-char pos)
    (while (toaq--word-char-p (char-before))
      (backward-char))
    (point)))

(defun toaq--after-word-boundary-p ()
  "Return t if point is not immediately preceded by a Toaq word character."
  (not (toaq--word-char-p (char-before))))

(defun toaq--preceding-word-bounds ()
  "Return the (START . END) of the Toaq word immediately before point,
skipping back over any run of non-word characters (space, punctuation)
that ended it. Return nil if no such word is found."
  (save-excursion
    (while (and (not (bobp)) (toaq--after-word-boundary-p))
      (backward-char))
    (let ((wend (point)))
      (goto-char (toaq--word-start wend))
      (when (< (point) wend)
        (cons (point) wend)))))

(defun toaq--forward-nucleus (limit)
  "Starting at point, scan forward (bounded by LIMIT) to the next vowel
run and return its (START . END), leaving point at END. Return nil and
leave point unmoved if no vowel run is found before LIMIT."
  (let ((start (point)))
    (while (and (< (point) limit) (not (toaq--vowel-p (char-after))))
      (forward-char))
    (if (>= (point) limit)
        (progn (goto-char start) nil)
      (let ((nstart (point)))
        (while (and (< (point) limit)
                    (or (toaq--vowel-p (char-after)) (toaq--combining-p (char-after))))
          (forward-char))
        (cons nstart (point))))))

(defun toaq--word-nuclei (start end)
  "Return a list of all raku nuclei, as (START . END) conses, found in
the buffer between START and END, in left-to-right order."
  (save-excursion
    (goto-char start)
    (let (nuclei nucleus)
      (while (setq nucleus (toaq--forward-nucleus end))
        (push nucleus nuclei))
      (nreverse nuclei))))

(defun toaq--toned-nucleus (nuclei)
  "Return the last nucleus in NUCLEI whose first vowel already carries
a tone mark, or nil if none of them does."
  (let (result)
    (dolist (nucleus nuclei result)
      (when (toaq--nucleus-has-tone-p nucleus)
        (setq result nucleus)))))

(defun toaq--apply-diacritic (combining-char fallback)
  "Apply COMBINING-CHAR as a tone.
If point is mid-raku, it's applied to the current syllable. Otherwise
(point is right after a word boundary) it's applied to the preceding
word instead: replacing that word's existing tone if it has one,
otherwise landing on its first syllable. If no word is found at all,
FALLBACK is inserted literally. Underdot does not work on entire words."
  (if toaq--escape-next
      (progn
        (setq toaq--escape-next nil)
        (insert fallback))
    (let ((nucleus (toaq--find-nucleus)))
      (cond
       (nucleus
        (toaq--set-nucleus-tone nucleus combining-char)
        (setq toaq--suppress-default-tone nil))
       ((and (toaq--after-word-boundary-p)
             (not (= combining-char ?\x0323)))
        (let* ((bounds (toaq--preceding-word-bounds))
               (nuclei (and bounds (toaq--word-nuclei (car bounds) (cdr bounds))))
               (target (and nuclei (or (toaq--toned-nucleus nuclei) (car nuclei)))))
          (if target
              (toaq--set-nucleus-tone target combining-char)
            (insert fallback))))
       (t (insert fallback))))))

(defun toaq--make-inserter (literal substitution)
  "Return a command that inserts SUBSTITUTION, or LITERAL if escaped."
  (lambda ()
    (interactive)
    (if toaq--escape-next
        (progn (setq toaq--escape-next nil) (insert literal))
      (insert substitution))))

(defun toaq--make-quote-inserter (literal quote-char)
  "Return a command that maybe applies default tone, then inserts QUOTE-CHAR.
If escaped, inserts LITERAL instead."
  (lambda ()
    (interactive)
    (if toaq--escape-next
        (progn (setq toaq--escape-next nil) (insert literal))
      (toaq--maybe-apply-default-tone)
      (insert quote-char))))

(defun toaq-acute ()
  (interactive)
  (toaq--apply-diacritic ?\x0301 "'"))
(defun toaq-diaeresis ()
  (interactive)
  (toaq--apply-diacritic ?\x0308 "\""))
(defun toaq-circumflex ()
  (interactive)
  (toaq--apply-diacritic ?\x0302 ";"))
(defun toaq-hook ()
  (interactive)
  (toaq--apply-diacritic ?\x0309 ":"))
(defun toaq-dotbelow ()
  (interactive)
  (toaq--apply-diacritic ?\x0323 "v"))
(defun toaq-grave ()
  (interactive)
  (toaq--apply-diacritic ?\x0300 "+"))
(defun toaq-macron ()
  (interactive)
  (toaq--apply-diacritic ?\x0304 "="))
(defun toaq-hacek ()
  (interactive)
  (toaq--apply-diacritic ?\x030c "^"))
(defun toaq-tilde ()
  (interactive)
  (toaq--apply-diacritic ?\x0303 "~"))

(defun toaq--last-underdot-nucleus (nuclei)
  "Return the last nucleus in NUCLEI that carries an underdot, or nil."
  (let (result)
    (dolist (nucleus nuclei result)
      (when (toaq--nucleus-has-underdot-p nucleus)
        (setq result nucleus)))))

(defun toaq-undo-diacritic ()
  "Remove the tone from the current raku nucleus, if mid-raku.
Otherwise (point is right after a word boundary), remove the tone
from the preceding word, wherever it falls. If a nucleus/word only
has underdot and no tone, remove the underdot. If the escape flag is
set, insert a literal backtick instead."
  (interactive)
  (if toaq--escape-next
      (progn (setq toaq--escape-next nil) (insert "`"))
    (let ((nucleus (toaq--find-nucleus)))
      (cond
       (nucleus
        (toaq--strip-nucleus-tone nucleus)
        (setq toaq--suppress-default-tone t))
       ((toaq--after-word-boundary-p)
        (let* ((bounds (toaq--preceding-word-bounds))
               (nuclei (and bounds (toaq--word-nuclei (car bounds) (cdr bounds))))
               (toned (toaq--toned-nucleus nuclei))
               (target (or toned
                           (and (not (cl-some #'toaq--nucleus-has-tone-p nuclei))
                                (toaq--last-underdot-nucleus nuclei)))))
          (if target
              (toaq--strip-nucleus-tone target)
            (message "toaq: nothing to undo"))))
       (t (message "toaq: nothing to undo"))))))

(defvar toaq-default-tones
  '(
    ;; pronouns
    ("jı" . ?\x0301)
    ("suq" . ?\x0301)
    ("nhao" . ?\x0301)
    ("ıme" . ?\x0301)
    ("umo" . ?\x0301)
    ("suna" . ?\x0301)
    ("suho" . ?\x0301)
    ("nhana" . ?\x0301)
    ("aq" . ?\x0301)
    ("cheq" . ?\x0301)
    ("ha" . ?\x0301)
    ("hoa" . ?\x0301)
    ("ho" . ?\x0301)
    ("maq" . ?\x0301)
    ("hoq" . ?\x0301)
    ("ta" . ?\x0301)
    ("aꝡa" . ?\x0301)
    ("kom" . ?\x0301)
    ("re" . ?\x0301)
    ;; determiners
    ("sa" . ?\x0301)
    ("tu" . ?\x0301)
    ("sıa" . ?\x0301)
    ("hı" . ?\x0301)
    ("baq" . ?\x0301)
    ("tuq" . ?\x0301)
    ("tutu" . ?\x0301)
    ("tum" . ?\x0301)
    ("ke" . ?\x0301)
    ("hu" . ?\x0301)
    ("ja" . ?\x0301)
    ("lo" . ?\x0301)
    ("nı" . ?\x0301)
    ("zoq" . ?\x0301)
    ("nanı" . ?\x0301)
    ("nenı" . ?\x0301)
    ("kaga" . ?\x0301)
    ("meuq" . ?\x0301)
    ;; focus markers
    ("ku" . ?\x0301)
    ("beı" . ?\x0301)
    ("mao" . ?\x0301)
    ("to" . ?\x0301)
    ("zeı" . ?\x0301)
    ("deum" . ?\x0301)
    ("joao" . ?\x0301)
    ("shuq" . ?\x0301)
    ("keao" . ?\x0301)
    ("seu" . ?\x0301)
    ("cuom" . ?\x0301)
    ;; connectives
    ("ru" . ?\x0301)
    ("ra" . ?\x0301)
    ("rı" . ?\x0301)
    ("ro" . ?\x0301)
    ("roı" . ?\x0301)
    ("keo" . ?\x0301)
    ("tıu" . ?\x0301)
    ;; other d2 things
    ("moq" . ?\x0301)
    ("hoı" . ?\x0301)
    ("mo" . ?\x0301)
    ("shu" . ?\x0301)
    ;; d3. complementizers aren't here because a lot of them can also
    ;; be d1 and some people like using d2 on them
    ("na" . ?\x0308)
    ("bı" . ?\x0308)
    ("go" . ?\x0308)
    ("ju" . ?\x0308)
    ("ꝡe" . ?\x0308)
    ("kıo" . ?\x0308)
    ("ıe" . ?\x0308)
    ;; d4 (adjunct heads)
    ("ıuq" . ?\x0302)
    ("lu" . ?\x0302)
    ("oq" . ?\x0302)
    ("ıaı" . ?\x0302)
    ("nuao" . ?\x0302)
    ("cham" . ?\x0302)
    ("sum" . ?\x0302)
    ("suom" . ?\x0302)
    ("zuam" . ?\x0302)
    ("cıam" . ?\x0302)
    ("chuam" . ?\x0302)
    )
  "Alist mapping Toaq words to the combining tone character that should be
applied automatically when the word is finished, unless the word already
has an explicit tone somewhere, or `toaq-undo-diacritic' was used on it.")

(defun toaq--maybe-apply-default-tone ()
  "If the word ending at point is in `toaq-default-tones' and has no
tone anywhere in it yet, and hasn't been marked tone-free, apply its
default tone to its first syllable."
  (let ((wstart (toaq--word-start (point))))
    (when (< wstart (point))
      (if toaq--suppress-default-tone
          (setq toaq--suppress-default-tone nil)
        (let ((nuclei (toaq--word-nuclei wstart (point))))
          (when (and nuclei (not (toaq--toned-nucleus nuclei)))
            (let* ((word-key (downcase (buffer-substring wstart (point))))
                   (tone (cdr (assoc word-key toaq-default-tones))))
              (when tone
                (toaq--set-nucleus-tone (car nuclei) tone)))))))))

(defun toaq--make-boundary-inserter (char)
  "Return a command that maybe applies a default tone to the word just
finished, then inserts CHAR literally."
  (lambda ()
    (interactive)
    (if toaq--escape-next
        (progn (setq toaq--escape-next nil) (insert char))
      (toaq--maybe-apply-default-tone)
      (insert char))))

(defun toaq--backward-delete-cluster ()
  "Delete the active region, or the grapheme cluster before point."
  (interactive)
  (if (use-region-p)
      (delete-region (region-beginning) (region-end))
    (let ((end (point)))
      (save-excursion
        (while (toaq--combining-p (char-before))
          (backward-char))
        (if (toaq--vowel-p (char-before))
            (progn (backward-char)
                   (delete-region (point) end))
          (delete-char -1))))))

(defvar toaq-keymap
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "DEL") #'toaq--backward-delete-cluster)
    (define-key map (kbd "`")  #'toaq-undo-diacritic)
    (define-key map (kbd "\\") #'toaq-escape)
    (define-key map (kbd "'")  #'toaq-acute)
    (define-key map (kbd "\"") #'toaq-diaeresis)
    (define-key map (kbd ";")  #'toaq-circumflex)
    (define-key map (kbd ":")  #'toaq-hook)
    (define-key map (kbd "v")  #'toaq-dotbelow)
    (define-key map (kbd "+")  #'toaq-grave)
    (define-key map (kbd "=")  #'toaq-macron)
    (define-key map (kbd "^")  #'toaq-hacek)
    (define-key map (kbd "~")  #'toaq-tilde)
    (define-key map (kbd "w") (toaq--make-inserter "w" "ꝡ"))
    (define-key map (kbd "W") (toaq--make-inserter "W" "Ꝡ"))
    (define-key map (kbd "i") (toaq--make-inserter "i" "ı"))
    (define-key map (kbd "x") (toaq--make-inserter "x" "’"))
    (define-key map (kbd "[") (toaq--make-inserter "[" "«"))
    (define-key map (kbd "]") (toaq--make-quote-inserter "]" "»"))
    (define-key map (kbd "{") (toaq--make-inserter "{" "‹"))
    (define-key map (kbd "}") (toaq--make-quote-inserter "}" "›"))
    (define-key map (kbd "SPC") (toaq--make-boundary-inserter " "))
    (define-key map (kbd "RET") (toaq--make-boundary-inserter "\n"))
    (define-key map (kbd ".") (toaq--make-boundary-inserter "."))
    (define-key map (kbd ",") (toaq--make-boundary-inserter ","))
    (define-key map (kbd "!") (toaq--make-boundary-inserter "!"))
    (define-key map (kbd "?") (toaq--make-boundary-inserter "?"))
    (define-key map (kbd ")") (toaq--make-boundary-inserter ")"))
    map))

(defvar-local toaq--saved-local-map nil
  "The buffer's local keymap from before the Toaq input method was
activated, so `toaq-deactivate' can restore it.")

(defun toaq-activate ()
  (when (string= current-input-method "toaq")
    (setq toaq--saved-local-map (current-local-map))
    (let ((map (copy-keymap toaq-keymap)))
      (set-keymap-parent map toaq--saved-local-map)
      (use-local-map map))
    (add-hook 'pre-command-hook #'toaq--clear-escape-on-unbound nil t)))
(defun toaq-deactivate ()
  (when (string= current-input-method "toaq")
    (setq toaq--escape-next nil)
    (remove-hook 'pre-command-hook #'toaq--clear-escape-on-unbound t)
    (use-local-map toaq--saved-local-map)
    (setq toaq--saved-local-map nil)))

(with-eval-after-load 'quail
  (add-hook 'input-method-activate-hook #'toaq-activate)
  (add-hook 'input-method-deactivate-hook #'toaq-deactivate))

(provide 'toaq)

;;; toaq.el ends here
