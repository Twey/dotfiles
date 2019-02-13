(add-hook
 'rust-mode-hook
 (lambda () (add-to-list 'write-file-functions 'delete-trailing-whitespace)))
