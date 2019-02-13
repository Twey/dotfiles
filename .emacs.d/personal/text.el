(require 'org-bullets)
(defface org-bullets
  '((t :family "DejaVu Sans Mono"))
  "Face used for highlighting bullets in org-bullets-mode.")
(add-hook
 'text-mode-hook
 (lambda ()
   (variable-pitch-mode 1)
   (org-bullets-mode 1)))
