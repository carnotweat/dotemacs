;; shortcut for reverting a buffer
(global-set-key (kbd "C-x C-r") 'revert-buffer)

(global-set-key (kbd "<C-kp-6>") 'enlarge-window-horizontally)
(global-set-key (kbd "<C-kp-4>") 'shrink-window-horizontally)
(global-set-key (kbd "<C-kp-2>") 'enlarge-window)
(global-set-key (kbd "<C-kp-8>") 'shrink-window)

(global-set-key (kbd "M-p") 'backward-paragraph)
(global-set-key (kbd "M-n") 'forward-paragraph)

(global-set-key (kbd "C-z") 'shell)

;; move between windows with meta-arrows
;; (windmove-default-keybindings 'meta)
(global-set-key (kbd "s-b") 'windmove-left)
(global-set-key (kbd "s-f") 'windmove-right)
(global-set-key (kbd "s-p") 'windmove-up)
(global-set-key (kbd "s-n") 'windmove-down)

;; ouverture rapide avec la touche windows
(global-set-key (kbd "s-s s") ;; scratch
                (lambda () (interactive) (switch-to-buffer "*scratch*")))
(global-set-key (kbd "s-s e") ;; .emacs
                (lambda () (interactive) (find-file (file-truename "~/.emacs.d/init.el"))))
(global-set-key (kbd "s-s m") ;; messages
                (lambda () (interactive) (switch-to-buffer "*Messages*")))
(global-set-key (kbd "s-s t") ;; twittering-mode
                (lambda () (interactive) (switch-to-buffer ":home")))

(global-set-key (kbd "C-x à") 'delete-other-windows)
(global-set-key (kbd "C-x C-à") 'delete-other-windows)
(global-set-key (kbd "C-,") 'other-window)

(global-set-key (kbd "C-c t") 'toggle-transparency)

;; automatically indent wherever I am
(global-set-key (kbd "RET") 'newline-and-indent)

(global-set-key [\C-home] 'beginning-of-buffer)
(global-set-key [\C-end] 'end-of-buffer)

;; fuck occur and word isearch
(global-set-key (kbd "M-s") 'backward-kill-word)

(global-set-key [(control tab)] 'other-window)

;; split screen and switch to it!
(global-set-key (kbd "C-x 3")
                (lambda nil
                  (interactive)
                  (split-window-horizontally)
                  (other-window 1)))

(global-set-key (kbd "C-x 2")
                (lambda nil
                  (interactive)
                  (split-window-vertically)
                  (other-window 1)))

;; replace-string and replace-regexp need a key binding
(global-set-key (kbd "C-c s") 'replace-string)
(global-set-key (kbd "C-c r") 'replace-regexp)

(defmacro create-flash-binding (key)
  "Make key `key' boundable to a complex command. Select the
complex command by typing C-`key'. Useful for example to repeat
an eval from M-:. Reuses the code from `repeat-complex-command'."
  `(global-set-key
    (kbd ,(concat "C-" key))
    (lambda ()
      (interactive)
      (lexical-let ((elt (nth 0 command-history))
                    newcmd)
        (if elt
            (progn
              (setq newcmd
                    (let ((print-level nil)
                          (minibuffer-history-position 0)
                          (minibuffer-history-sexp-flag (1+ (minibuffer-depth))))
                      (unwind-protect
                          (read-from-minibuffer
                           "Redo: " (prin1-to-string elt) read-expression-map t
                           (cons 'command-history 0))

                        ;; If command was added to command-history as a
                        ;; string, get rid of that.  We want only
                        ;; evaluable expressions there.
                        (if (stringp (car command-history))
                            (setq command-history (cdr command-history))))))

              ;; If command to be redone does not match front of history,
              ;; add it to the history.
              (or (equal newcmd (car command-history))
                  (setq command-history (cons newcmd command-history)))
              (global-set-key
               (kbd ,key)
               (lambda ()
                 (interactive)
                 (eval newcmd))))
          (if command-history
              (error "Argument %d is beyond length of command history" 0)
            (error "There are no previous complex commands to repeat")))))))

(create-flash-binding "<f9>")
(create-flash-binding "<f10>")
(create-flash-binding "<f11>")
(create-flash-binding "<f12>")

(provide 'init-bindings)