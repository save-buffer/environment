(tool-bar-mode -1)
(menu-bar-mode -1)
(toggle-scroll-bar -1)
(split-window-horizontally)
(setq ring-bell-function 'ignore)

(selectrum-mode)
(selectrum-prescient-mode 1)
(prescient-persist-mode 1)
(ctrlf-mode 1)

(defvar sasha-cpp-other-file-alist
  '(("\\.cpp\\'" (".h" ".hpp"))
    ("\\.cc\\'" (".h" ".hpp"))
    ("\\.cu\\'" (".h" ".hpp"))
    ("\\.c\\'" (".h"))
    ("\\.h\\'" (".cpp" ".cu" ".c" ".cc"))
    ))
(setq ff-other-file-alist 'sasha-cpp-other-file-alist)
(setq ff-always-try-to-create 't)
(defun sasha-find-other-file-other-window ()
  "Find corresponding file in other window"  
  (interactive)
  (ff-find-other-file 't))
(global-set-key (kbd "C-o") 'sasha-find-other-file-other-window)
(global-set-key (kbd "M-o") 'ff-find-other-file)

(global-set-key (kbd "C-M-f") 'find-file-other-window)
(global-set-key (kbd "M-k") 'kill-buffer)
(global-set-key (kbd "M-p") 'eval-buffer)

(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)

(global-set-key (kbd "C-c n i") 'org-roam-node-insert)
(global-set-key (kbd "C-c n f") 'org-roam-node-find)
(global-set-key (kbd "C-c n c") 'org-roam-capture)
(global-set-key (kbd "C-c n b") 'org-roam-buffer-toggle)

(global-set-key (kbd "C-c n d") 'deft)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(show-paren-mode)
(display-time)
(setq-default truncate-lines t)
(global-auto-revert-mode t)
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.cu\\'" . c++-mode))
(setq-default indent-tabs-mode nil)
(setq-default c-default-style "bsd" c-basic-offset 4)

(setq
 backup-by-copying t
 backup-directory-alist '(("." . "~/.saves"))
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t)

(setq org-agenda-files '("~/org/personal.org" "~/org/work.org" "~/org/crypto.org" "~/org/buy.org"))
(setq org-capture-templates
      '(("t" "Task" entry
         (file+headline "" "Tasks")
         "* TODO %?\n %u\n %a")
        ("b" "Buy" checkitem
         (file+headline "~/org/buy.org" "Buy List")
         "%? - ([[%x][link]])")
        ("p" "Program/Tool" entry
         (file+headline "~/org/personal.org" "Tools")
         "* TODO [[%x][%?]]")
        ("r" "Reading" entry
         (file+headline "~/org/personal.org" "Reading")
         "* TODO [[%x][%?]]")
        ("c" "Crypto" item
         (file+headline "~/org/crypto.org" "Crypto")
         "[[%x][%?]]")))
(setq org-default-notes-file "~/org/refile.org")
(setq org-refile-targets '((org-agenda-files :maxlevel . 1)))
(setq org-return-follows-link t)

(setq org-roam-v2-ack t)
(setq org-roam-directory (file-truename "~/org/notes"))
(org-roam-db-autosync-mode)

(setq deft-recursive t)
(setq deft-use-filter-string-for-name t)
(setq deft-default-extension "org")
(setq deft-directory org-roam-directory)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes '(default))
 '(package-selected-packages
   '(cmake-mode org-ref org-roam-ui htmlize deft org-roam ctrlf selectrum-prescient magit rainbow-mode auto-complete)))

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(when (display-graphic-p)
  (load-theme 'voltron t))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
