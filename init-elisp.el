;; Customized Emacs Lisp mode
(require 'eldoc)
(autoload 'turn-on-eldoc-mode "eldoc" nil t)
(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)

(defun eval-region-or-buffer ()
  (interactive)
  (let ((debug-on-error t))
    (cond
     (mark-active
      (call-interactively 'eval-region)
      (message "Region evaluated!")
      (setq deactivate-mark t))
     (t
      (eval-buffer)
      (message "Buffer evaluated!")))))

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (local-set-key (kbd "C-x E") 'eval-region-or-buffer)))

(defvar electrify-return-match
  "[\]}\)\"]"
  "If this regexp matches the text after the cursor, do an \"electric\"
  return.")

(defun electrify-return-if-match (arg)
  "If the text after the cursor matches `electrify-return-match' then
  open and indent an empty line between the cursor and the text.  Move the
  cursor to the new line."
  (interactive "P")
  (let ((case-fold-search nil))
    (if (looking-at electrify-return-match)
        (save-excursion (newline-and-indent)))
    (newline arg)
    (indent-according-to-mode)))

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (local-set-key (kbd "RET") 'electrify-return-if-match)))

;; custom name for bookmark when in a defun
(defun emacs-lisp-custom-record-function ()
  (set (make-local-variable 'bookmark-make-record-function)
       (lambda (&optional no-file no-context posn)
         (let (defun record)
           (setq record (bookmark-make-record-default no-file no-context posn))
           (ignore-errors
             (save-excursion
               (end-of-defun)
               (beginning-of-defun)
               (setq defun (read (current-buffer)))))
           (if (eq (car defun) 'defun)
               (setcar record (format "%s" (cadr defun))))
           record))))

(add-hook 'emacs-lisp-mode-hook 'emacs-lisp-custom-record-function)

(add-hook 'emacs-lisp-mode-hook
          (lambda()
            (setq mode-name "ELisp")
            (linum-mode t)
            (setq lisp-indent-offset nil)
            ;;(turn-on-auto-fill)
            (require 'folding nil 'noerror)
            ;; (set (make-local-variable 'hippie-expand-try-functions-list)
            ;;      '(yas/hippie-try-expand
            ;;        try-complete-file-name-partially
            ;;        try-complete-file-name
            ;;        try-expand-dabbrev-visible
            ;;        try-expand-dabbrev
            ;;        try-complete-lisp-symbol-partially
            ;;        try-complete-lisp-symbol))
            ;;marquer les caractères au delà de 80 caractères
            (font-lock-add-keywords
             nil
             '(("^[^;\n]\\{80\\}\\(.*\\)$" 1 font-lock-warning-face prepend)))
            (font-lock-add-keywords
             nil
             '(("\\<\\(FIXME\\|TODO\\|BUG\\)"
                1 font-lock-warning-face prepend)))
            (font-lock-add-keywords
             nil
             '(("\\<\\(add-hook\\|setq\\)\\>"
                1 font-lock-keyword-face prepend)))))

(defun eval-and-replace ()
  "Replace the preceding sexp with its value."
  (interactive)
  (backward-kill-sexp)
  (condition-case nil
      (prin1 (eval (read (current-kill 0)))
             (current-buffer))
    (error (message "Invalid expression")
           (insert (current-kill 0)))))

(global-set-key (kbd "C-c e") 'eval-and-replace)

(autoload 'enable-paredit-mode "paredit"
  "Turn on pseudo-structural editing of Lisp code."
  t)
(add-hook 'emacs-lisp-mode-hook 'enable-paredit-mode)
(add-hook 'lisp-mode-hook 'enable-paredit-mode)
(add-hook 'lisp-interaction-mode-hook 'enable-paredit-mode)
(add-hook 'emacs-lisp-mode-hook 'enable-paredit-mode)

;; From https://github.com/jwiegley/dot-emacs
(eval-after-load "paredit"
  '(progn
     (defun paredit-barf-all-the-way-backward ()
       (interactive)
       (paredit-split-sexp)
       (paredit-backward-down)
       (paredit-splice-sexp))

     (defun paredit-barf-all-the-way-forward ()
       (interactive)
       (paredit-split-sexp)
       (paredit-forward-down)
       (paredit-splice-sexp)
       (if (eolp) (delete-horizontal-space)))

     (defun paredit-slurp-all-the-way-backward ()
       (interactive)
       (catch 'done
	 (while (not (bobp))
	   (save-excursion
	     (paredit-backward-up)
	     (if (eq (char-before) ?\()
		 (throw 'done t)))
	   (paredit-backward-slurp-sexp))))

     (defun paredit-slurp-all-the-way-forward ()
       (interactive)
       (catch 'done
	 (while (not (eobp))
	   (save-excursion
	     (paredit-forward-up)
	     (if (eq (char-after) ?\))
		 (throw 'done t)))
	   (paredit-forward-slurp-sexp))))

     (nconc paredit-commands
	    '("Extreme Barfage & Slurpage"
	      (("C-M-)")
	       paredit-slurp-all-the-way-forward
	       ("(foo (bar |baz) quux zot)"
		"(foo (bar |baz quux zot))")
	       ("(a b ((c| d)) e f)"
		"(a b ((c| d)) e f)"))
	      (("C-M-}")
	       paredit-barf-all-the-way-forward
	       ("(foo (bar |baz quux) zot)"
		"(foo (bar|) baz quux zot)"))
	      (("C-M-(")
	       paredit-slurp-all-the-way-backward
	       ("(foo bar (baz| quux) zot)"
		"((foo bar baz| quux) zot)")
	       ("(a b ((c| d)) e f)"
		"(a b ((c| d)) e f)"))
	      (("C-M-{")
	       paredit-barf-all-the-way-backward
	       ("(foo (bar baz |quux) zot)"
		"(foo bar baz (|quux) zot)"))))

     (paredit-define-keys)
     (paredit-annotate-mode-with-examples)
     (paredit-annotate-functions-with-examples)))

(provide 'init-elisp)
  