(use-package julia-mode
  :straight (julia-mode :repo "JuliaEditorSupport/julia-emacs"
                        :fetcher github
                        :files "*.el"))

;; http://ess.r-project.org
(use-package ess-site                   ; Emacs Speaks Statistics
  :straight ess
  :bind (:map ess-r-mode-map ("_" . ess-insert-assign)
              :map inferior-ess-mode-map ("_" . ess-insert-assign))
  ;; No special behaviour of comments starting with #, ## or ###
  :custom (ess-indent-with-fancy-comments nil)
  :config
  ;; No double sharp sign when starting a comment
  (setq ess-r-customize-alist
        (append ess-r-customize-alist '((comment-add . 0))))

  (defun tidy-Rtex-chunks ()
    "Tidy all the R chunks delimited by begin.rcode/end.rcode."
    (interactive)
    (save-excursion
      (goto-char (point-min))
      (let ((re-begin-chunk "^ *\\(%+\\) *begin\\.rcode *")
            (re-end-chunk "end\\.rcode")
            (re-prefix-chunk " *%+ *")
            (prefix-chunk "% "))
        (while (re-search-forward begin-chunk nil t)
          (let* ((column (progn
                           (goto-char (match-beginning 1))
                           (current-column)))
                 (beg (progn
                        (forward-line 1)
                        (point-at-bol)))
                 (end (progn
                        (re-search-forward end-chunk nil t)
                        (forward-line -1)
                        (point-at-eol)))
                 (code (delete-and-extract-region beg end))
                 (new-code (progn
                             (with-temp-buffer
                               (insert code)
                               (goto-char (point-min))
                               (while (re-search-forward re-prefix-chunk nil t)
                                 (replace-match ""))
                               (write-file (make-temp-file "foo"))
                               (tidy-R-buffer nil nil "indent = 2, arrow = TRUE, width.cutoff = 500")
                               (goto-char (point-min))
                               (while (re-search-forward "^\\(.\\)" nil t)
                                 (replace-match (concat
                                                 (make-string column ?\ )
                                                 prefix-chunk
                                                 "\\1")))
                               (save-buffer)
                               (string-trim-right (buffer-string))))))
            (goto-char beg)
            (insert new-code)))))))

(provide 'init-ess)
