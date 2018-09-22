
					;Sasha's .emacs file
					;Sasha Krassovsky
					;December 14 2017

;;          KEYBINDINGS:
;;
;;  Ctrl+f = Go forward 1 character
;;  Ctrl+b = Go backwards 1 character
;;  Ctrl+p = Go up 1 line
;;  Ctrl+n = Go down 1 line
;;  Alt+f = Go forward 1 word
;;  Alt+b = Go backwards 1 word
;;  Ctrl+v = Go down 1 screen
;;  Alt+v = Go up 1 screen
;;  Ctrl+l = Center the cursor on the screen
;;  Ctrl+x+s = Save
;;  Ctrl+Alt+f = Open a file in the other window
;;  Ctrl+x+f = Open a file in this window
;;  Alt+k = Kill a buffer
;;  Ctrl+k = Kill the current line
;;  Ctrl+Shift+s = Switch to a buffer
;;  Ctrl+Shift+d = Switch to buffer in the other window
;;  Alt+s = Switch 2 lines
;;  Alt+n = Compile the code (it searches for a file called build.bat)
;;  Alt+p = Evaluate the current buffer as emacs lisp code
;;  Tab = Autocomplete (recursively searches all included files to help in the autocomplete)
;;  Ctrl+tab = Indent the selected region
;;  Ctrl+space = Set the mark
;;  Ctrl+w = Cut
;;  Alt+w = Copy
;;  Ctrl+y = Paste
;;  Alt+o = Open the corresponding file (like if foo.cpp is open, open foo.h) in this window
;;  Ctrl+o = Open the corresponding file (like if foo.cpp is open, open foo.h) in the other window
;;  Ctrl+x+c = Close emacs

(setq ring-bell-function 'ignore)
(tool-bar-mode 0)
(menu-bar-mode 0)
					;Libraries
(load-library "view")
(require 'cc-mode)
(require 'ido)
(require 'compile)
(ido-mode t)

					;Keymaps
(define-key global-map (kbd "C-M-f") 'find-file-other-window)
(define-key global-map (kbd "M-k") 'kill-buffer)
(define-key global-map (kbd "M-b") 'backward-word)
(define-key global-map (kbd "C-S-s") 'switch-to-buffer)
(define-key global-map (kbd "C-S-d") 'switch-to-buffer-other-window)
(define-key global-map (kbd "M-s") 'transpose-lines)
(define-key global-map (kbd "RET") 'newline-and-indent)

					;Windows
(defun sasha-ediff-setup-windows (buffer-A buffer-B buffer-C control-buffer)
  (ediff-setup-windows-plain buffer-A buffer-B buffer-C control-buffer))
(setq ediff-window-setup-function 'sasha-ediff-setup-windows)
(setq ediff-split-window-function 'split-window-horizontally)

(defun shell-other-window ()
  "Open a shell in the other window"
  (interactive)
  (let ((buf (shell)))
    (switch-to-buffer (other-window buf))
    (switch-to-buffer-other-window buf)))

(defun sasha-codeforces-setup ()
  "Setup when working on codeforces"
;(shell-other-window))
  (if (eq default-directory "codeforces")
      (sasha-codeforces-setup)))

(setq-default indent-tabs-mode nil)
(add-hook 'find-file-hook 'sasha-codeforces-setup)
(display-time)
(show-paren-mode)

(setq next-line-add-newlines nil)
(setq-default truncate-lines t)
(setq truncate-partial-width-windows nil)
(split-window-horizontally)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-save-default nil)
 '(auto-save-interval 0)
 '(auto-save-list-file-prefix nil)
 '(auto-save-timeout 0)
 '(auto-show-mode t t)
 '(custom-safe-themes
   (quote
    ("84d2f9eeb3f82d619ca4bfffe5f157282f4779732f48a5ac1484d94d5ff5b279" "a27c00821ccfd5a78b01e4f35dc056706dd9ede09a8b90c6955ae6a390eb1c1e" default)))
 '(delete-auto-save-files nil)
 '(delete-old-versions (quote other))
 '(imenu-auto-rescan t)
 '(imenu-auto-rescan-maxout 500000)
 '(kept-new-versions 5)
 '(kept-old-versions 5)
 '(make-backup-file-name-function (quote ignore))
 '(make-backup-files nil)
 '(mouse-wheel-follow-mouse nil)
 '(mouse-wheel-progressive-speed nil)
 '(mouse-wheel-scroll-amount (quote (15)))
 '(version-control nil))

(setq undo-limit 2000000)
(setq undo-strong-limit 4000000)

(setq fixme-modes '(c++-mode c-mode emacs-lisp-mode))
(make-face 'font-lock-fixme-face)
(make-face 'font-lock-note-face)
(make-face 'font-lock-important-face)
(make-face 'font-lock-optimize-face)

(mapc (lambda (mode)
	(font-lock-add-keywords
	 mode
	 '(("\\<\\(TODO\\)" 1 'font-lock-fixme-face t)
	   ("\\<\\(OPTIMIZE\\)" 1 'font-lock-optimize-face t)
	   ("\\<\\(IMPORTANT\\)" 1 'font-lock-important-face t)
	   ("\\<\\(NOTE\\)" 1 'font-lock-note-face t))))      
      fixme-modes)
(modify-face 'font-lock-fixme-face "Red" nil nil t nil t nil nil)
(modify-face 'font-lock-note-face "Dark Green" nil nil t nil t nil nil)
(modify-face 'font-lock-important-face "Yellow" nil nil t nil t nil nil)
(modify-face 'font-lock-optimize-face "Green" nil nil t nil t nil nil)

(define-key global-map [C-tab] 'indent-region)
(global-set-key "\M-p" 'eval-buffer)


					;Autocomplete that parses header files
(require 'cl)
(defvar cdsb-include-re "^\\s-*#\\s-*\\(?:include\\|import\\)\\s-*\\([\"<]\\)\\([^\">]+\\)[\">]\\s-*$")
(defun cdsb-extract-includes-in-buffer (buffer)
  (with-current-buffer buffer
    (save-excursion
      (goto-char (point-min))
      (loop while (re-search-forward cdsb-include-re nil t)
            collect (cons (match-string-no-properties 2) (not (string-equal (match-string-no-properties 1) "\"")))))))
(defun cdsb-acc-buffers (buffer non-system-files buffer-list)
  (loop with new-buffer-list = nil
        for (name . system-include-p) in (cdsb-extract-includes-in-buffer buffer)
        do (let* ((file (if system-include-p
                            (ffap-c-mode name)
                          (let ((name-re (concat "/" (regexp-quote name) "$")))
                            (loop for file in non-system-files
                                  if (string-match name-re file)
                                  return file))))
                  (buf (and file (find-file-noselect file t))))
             ;; (message "check %s => %s" name file)
             (and buf
                  (not (position buf buffer-list))
                  (setq buffer-list (cdsb-acc-buffers buf non-system-files (cons buf buffer-list)))))
        finally return buffer-list))
(defun c-dabbrev--select-buffers ()
  (if (memq major-mode '(c-mode c++-mode objc-mode))
      (save-excursion
        (require 'ffap)
        (let ((top (project-top-directory))
              (cur (current-buffer)))
          (nreverse
           (cdr
            (nreverse
             (cdsb-acc-buffers cur (and top (project-source-files top)) (list cur)))))))
    (dabbrev--select-buffers)))

(add-hook 'c-mode-common-hook
	  (lambda () 
	    (set (make-variable-buffer-local 'dabbrev-select-buffers-function) 'c-dabbrev--select-buffers)
	    (local-set-key [tab] 'dabbrev-expand)))
(add-hook 'cpp-mode-common-hook
	  (lambda ()
	    (set (make-variable-buffer-local 'dabbrev-select-buffers-function) 'c-dabbrev--select-buffers)))

(global-set-key (kbd "<tab>") 'dabbrev-expand)
(define-key minibuffer-local-map (kbd "<tab>") 'dabbrev-expand)

					;Compilation
(defun sasha-compilation-hook ()
  (make-local-variable 'truncate-lines)
  (setq truncate-lines nil))

(add-hook 'compilation-mode-hook 'sasha-compilation-hook)

(if (eq system-type 'gnu/linux)
    (setq sasha-make-script "./build")
  (setq sasha-make-script "build.bat"))

(if (eq system-type 'gnu/linux)
    (setq sasha-run-script "./run")
  (setq sasha-run-script "run.bat"))

(defun find-project-directory-recursive ()
  "Recursively search for a makefile."
  (interactive)
  (if (file-exists-p sasha-make-script) t
    (cd "../")
    (find-project-directory-recursive)))

(setq compilation-directory-locked nil)
(defun lock-compilation-directory ()
  "The compilation process does not hunt for the makefile"
  (interactive)
  (setq compilation-directory-locked t)
  (message "Compilation directory is locked."))

(defun unlock-compilation-directory ()
  "The compilation process does hunt for the makefile"
  (interactive)
  (setq compilation-directory-locked nil)
  (message "Compilation directory is roaming."))

(defun find-project-directory ()
  "Find the project directory"
  (interactive)
  (setq find-project-from-directory default-directory)
  (switch-to-buffer-other-window "*compilation*")
  (if compilation-directory-locked (cd last-compilation-directory)
    (cd find-project-from-directory)
    (find-project-directory-recursive)
    (setq last-compilation-directory default-directory)))

(defun sasha-compile ()
  "Compiles the project"
  (interactive)
  (if (find-project-directory) (compile sasha-make-script))
  (other-window 1))

(defun sasha-run ()
  "Runs the project"
  (interactive)
  (compile sasha-run-script))

(global-set-key "\M-n" 'sasha-compile)
(global-set-key "\C-\M-n" 'sasha-run)

					;More Windows
;(defun never-split-window
;    "Never split a window!!"
;  nil)
;(setq split-window-preferred-function 'never-split-window)


					;File Switching
(defun sasha-find-corresponding-file ()
  "Find the one that corresponds to this one"
  (interactive)
  (setq CorrespondingFileName nil)
  (setq BaseFileName (file-name-sans-extension buffer-file-name))
  (if (string-match "\\.c" buffer-file-name)
      (setq CorrespondingFileName (concat BaseFileName ".h")))
  (if (string-match "\\.h" buffer-file-name)
      (if (file-exists-p (concat BaseFileName ".c")) (setq CorrespondingFileName (concat BaseFileName ".c"))
	(if (file-exists-p (concat BaseFileName ".cpp")) (setq CorrespondingFileName (concat BaseFileName ".cpp"))
	  nil)))
  (if (string-match "\\.hin" buffer-file-name)
      (setq CorrespondingFileName (concat BaseFileName ".cin")))
  (if (string-match "\\.cin" buffer-file-name)
      (setq CorrespondingFileName (concat BaseFileName ".hin")))
  (if (string-match "\\.cpp" buffer-file-name)
      (setq CorrespondingFileName (concat BaseFileName ".h")))
  (if CorrespondingFileName (find-file CorrespondingFileName)
    (error "Unable to find a corresponding file")))
(defun sasha-find-corresponding-file-other-window ()
  "Finds the file that corresponds to this one and open it in the other window"
  (interactive)
  (find-file-other-window buffer-file-name)
  (sasha-find-corresponding-file)
  (other-window -1))

(define-key global-map (kbd "M-o") 'sasha-find-corresponding-file)
(define-key global-map (kbd "C-o")  'sasha-find-corresponding-file-other-window)

					;Colors
;(add-to-list 'default-frame-alist '(font . "Ubuntu Mono derivative Powerline-14"))
;(set-face-attribute 'default nil :font "Ubuntu Mono derivative Powerline-14")
;(set-frame-font "Ubuntu Mono derivative Powerline-14" nil t)
(add-to-list 'default-frame-alist '(font . "Consolas-13"))
(set-face-attribute 'default nil :font "Consolas-13")
(set-frame-font "Consolas-13" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

					;(set-face-foreground 'default "DarkGoldenrod3")
(set-face-foreground 'default "#DCDCDC")
(set-face-foreground 'highlight "#3399FF")
(set-face-foreground 'font-lock-comment-face "#57A64A")
(set-face-foreground 'font-lock-string-face "#D69D85")
(set-face-foreground 'font-lock-preprocessor-face "#BD63C5")
(set-face-foreground 'font-lock-type-face "#569CD6")
(set-face-foreground 'font-lock-variable-name-face "#C6C6C6")
(set-face-foreground 'font-lock-keyword-face "#569CD6")
(set-face-foreground 'font-lock-constant-face "#BD63C5")
(set-face-foreground 'font-lock-function-name-face "#4EC7B0")

(set-background-color "#1E1E1E")

(setq-default c-default-style "bsd"
	      c-basic-offset 4)


(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives '("gnu" . (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)

















;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; JAI MODE ;;

(require 'rx)
(require 'js)

(defconst jai-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?\" "\"" table)
    (modify-syntax-entry ?\\ "\\" table)

    ;; additional symbols
    (modify-syntax-entry ?_ "w" table)

    (modify-syntax-entry ?' "." table)
    (modify-syntax-entry ?: "." table)
    (modify-syntax-entry ?+  "." table)
    (modify-syntax-entry ?-  "." table)
    (modify-syntax-entry ?%  "." table)
    (modify-syntax-entry ?&  "." table)
    (modify-syntax-entry ?|  "." table)
    (modify-syntax-entry ?^  "." table)
    (modify-syntax-entry ?!  "." table)
    (modify-syntax-entry ?$  "/" table)
    (modify-syntax-entry ?=  "." table)
    (modify-syntax-entry ?<  "." table)
    (modify-syntax-entry ?>  "." table)
    (modify-syntax-entry ??  "." table)

    ;; Modify some syntax entries to allow nested block comments
    (modify-syntax-entry ?/ ". 124b" table)
    (modify-syntax-entry ?* ". 23n" table)
    (modify-syntax-entry ?\n "> b" table)
    (modify-syntax-entry ?\^m "> b" table)

    table))

(defconst jai-builtins
  '("cast" "it" "type_info" "size_of"))

(defconst jai-keywords
  '("if" "else" "then" "while" "for" "switch" "case" "struct" "enum"
    "return" "new" "remove" "continue" "break" "defer" "inline" "no_inline"
    "using" "SOA"))

(defconst jai-constants
  '("null" "true" "false"))

(defconst jai-typenames
  '("int" "u64" "u32" "u16" "u8"
    "s64" "s32" "s16" "s8" "float"
    "float32" "float64" "string"
    "bool"))

(defun jai-wrap-word-rx (s)
  (concat "\\<" s "\\>"))

(defun jai-keywords-rx (keywords)
  "build keyword regexp"
  (jai-wrap-word-rx (regexp-opt keywords t)))

(defconst jai-hat-type-rx (rx (group (and "^" (1+ word)))))
(defconst jai-dollar-type-rx (rx (group "$" (or (1+ word) (opt "$")))))
(defconst jai-number-rx
  (rx (and
       symbol-start
       (or (and (+ digit) (opt (and (any "eE") (opt (any "-+")) (+ digit))))
           (and "0" (any "xX") (+ hex-digit)))
       (opt (and (any "_" "A-Z" "a-z") (* (any "_" "A-Z" "a-z" "0-9"))))
       symbol-end)))

(defconst jai-font-lock-defaults
  `(
    ;; Keywords
    (,(jai-keywords-rx jai-keywords) 1 font-lock-keyword-face)

    ;; single quote characters
    ("\\('[[:word:]]\\)\\>" 1 font-lock-constant-face)

    ;; Variables
    (,(jai-keywords-rx jai-builtins) 1 font-lock-variable-name-face)

    ;; Constants
    (,(jai-keywords-rx jai-constants) 1 font-lock-constant-face)

    ;; Hash directives
    ("#\\w+" . font-lock-preprocessor-face)

    ;; At directives
    ("@\\w+" . font-lock-preprocessor-face)

    ;; Strings
    ("\\\".*\\\"" . font-lock-string-face)

    ;; Numbers
    (,(jai-wrap-word-rx jai-number-rx) . font-lock-constant-face)

    ;; Types
    (,(jai-keywords-rx jai-typenames) 1 font-lock-type-face)
    (,jai-hat-type-rx 1 font-lock-type-face)
    (,jai-dollar-type-rx 1 font-lock-type-face)

    ("---" . font-lock-constant-face)
    ))

;; add setq-local for older emacs versions
(unless (fboundp 'setq-local)
  (defmacro setq-local (var val)
    `(set (make-local-variable ',var) ,val)))

(defconst jai--defun-rx "\(.*\).*\{")

(defmacro jai-paren-level ()
  `(car (syntax-ppss)))

(defun jai-line-is-defun ()
  "return t if current line begins a procedure"
  (interactive)
  (save-excursion
    (beginning-of-line)
    (let (found)
      (while (and (not (eolp)) (not found))
        (if (looking-at jai--defun-rx)
            (setq found t)
          (forward-char 1)))
      found)))

(defun jai-beginning-of-defun (&optional count)
  "Go to line on which current function starts."
  (interactive)
  (let ((orig-level (jai-paren-level)))
    (while (and
            (not (jai-line-is-defun))
            (not (bobp))
            (> orig-level 0))
      (setq orig-level (jai-paren-level))
      (while (>= (jai-paren-level) orig-level)
        (skip-chars-backward "^{")
        (backward-char))))
  (if (jai-line-is-defun)
      (beginning-of-line)))

(defun jai-end-of-defun ()
  "Go to line on which current function ends."
  (interactive)
  (let ((orig-level (jai-paren-level)))
    (when (> orig-level 0)
      (jai-beginning-of-defun)
      (end-of-line)
      (setq orig-level (jai-paren-level))
      (skip-chars-forward "^}")
      (while (>= (jai-paren-level) orig-level)
        (skip-chars-forward "^}")
        (forward-char)))))

(defalias 'jai-parent-mode
  (if (fboundp 'prog-mode) 'prog-mode 'fundamental-mode))

;;;###autoload
(define-derived-mode jai-mode jai-parent-mode "Jai"
  :syntax-table jai-mode-syntax-table
  :group 'jai
  (setq bidi-paragraph-direction 'left-to-right)
  (setq-local require-final-newline mode-require-final-newline)
  (setq-local parse-sexp-ignore-comments t)
  (setq-local comment-start-skip "\\(//+\\|/\\*+\\)\\s *")
  (setq-local comment-start "/*")
  (setq-local comment-end "*/")
  (setq-local indent-line-function 'js-indent-line)
  (setq-local font-lock-defaults '(jai-font-lock-defaults))
  (setq-local beginning-of-defun-function 'jai-beginning-of-defun)
  (setq-local end-of-defun-function 'jai-end-of-defun)

  (font-lock-fontify-buffer))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.jai\\'" . jai-mode))
(add-to-list 'auto-mode-alist '("\\.cu\\'" . c++-mode))

(provide 'jai-mode)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
