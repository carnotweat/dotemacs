;; auto-indent pasted code
(dolist (func '(yank yank-pop))
  (ad-add-advice
   func
   `(,(intern (format "%s-advice" func)) nil t
     (advice . (lambda ()
                 "Auto indent on paste"
                 (maybe-indent-on-paste))))
   'after
   'last)
  (ad-activate func))

(defun maybe-indent-on-paste ()
  "Indent the region when in prog mode. Make an undo boundary to
cancel the indentation if needed."
  (when (or (derived-mode-p 'prog-mode)
            (memq major-mode '(ruby-mode
                               emacs-lisp-mode scheme-mode
                               lisp-interaction-mode sh-mode
                               lisp-mode c-mode c++-mode objc-mode
                               latex-mode plain-tex-mode
                               python-mode matlab-mode)))
    (undo-boundary)
    (indent-region (region-beginning) (region-end))))

(defun kill-region-or-backward ()
  (interactive)
  (if (region-active-p)
      (kill-region (region-beginning) (region-end))
    (kill-line 0)))

(global-set-key (kbd "C-w") 'kill-region-or-backward)

(defun save-region-or-current-line ()
  (interactive)
  (if (region-active-p)
      (kill-ring-save (region-beginning) (region-end))
    (kill-ring-save (line-beginning-position) (line-beginning-position 2))
    (message "line copied")))

(global-set-key (kbd "M-w") 'save-region-or-current-line)

(global-set-key (kbd "M-j") (lambda () (interactive) (join-line t)))

;; copy when in read only buffer
(setq kill-read-only-ok t)

(defun beginning-of-line-or-text ()
  (interactive)
  (if (bolp)
      (beginning-of-line-text)
    (beginning-of-line)))

(global-set-key (kbd "C-a") 'beginning-of-line-or-text)

;; From https://github.com/purcell/emacs.d
(defun sort-lines-random (beg end)
  "Sort lines in region randomly."
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)
      (goto-char (point-min))
      (let ;; To make `end-of-line' and etc. to ignore fields.
          ((inhibit-field-text-motion t))
        (sort-subr nil 'forward-line 'end-of-line nil nil
                   (lambda (s1 s2) (eq (random 2) 0)))))))

(provide 'init-editing)