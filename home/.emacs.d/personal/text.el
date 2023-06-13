(require 'org-bullets)
(defface org-bullets
  '((t :family "DejaVu Sans Mono"))
  "Face used for highlighting bullets in org-bullets-mode.")

(add-hook
 'org-mode-hook
 (lambda ()
   (org-indent-mode 1)
   (org-bullets-mode 1)))

;; (add-hook
;;  'TeX-mode-hook
;;  (lambda ()
;;    (variable-pitch-mode 0)
;;    (flycheck-mode 0)))
