(setq rust-format-on-save nil)

(add-hook
 'rust-mode-hook
 (lambda ()
   (add-to-list 'write-file-functions #'delete-trailing-whitespace)
   (local-set-key (kbd "<f12>") #'rust-test)
   (setq rust-format-on-save nil)))
