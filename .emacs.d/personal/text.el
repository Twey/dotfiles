(require 'org-bullets)
(add-hook
 'text-mode-hook
 (lambda ()
   (variable-pitch-mode 1)
   (blink-cursor-mode 0)    ;; Reduce visual noise
   (setq org-bullets-bullet-list '("◉" "○"))
   (org-bullets-mode 1)))
