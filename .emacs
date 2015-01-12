;; Melpa, Marmalade
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
(package-initialize)

;; el-get
(add-to-list 'load-path (locate-user-emacs-file "el-get/el-get"))
(setq-default el-get-dir (locate-user-emacs-file "el-get"))
(unless (require 'el-get nil 'noerror)
  (with-current-buffer
    (url-retrieve-synchronously
     "http://raw.github.com/dimitri/el-get/master/el-get-install.el")
    (let (el-get-master-branch)
      (goto-char (point-max))
      (eval-print-last-sexp))))

;; exclude info file generation from evil.rcp
(add-to-list 'el-get-sources '(:name evil :build (("make" "all")) :info nil))

;; install evil
(el-get 'sync 'evil)

;; enable evil
(require 'evil)
(evil-mode 1)

;; ProofGeneral
(load-file "$HOME/lib/ProofGeneral-4.2/generic/proof-site.el")
(add-hook 'proof-mode-hook '(lambda ()
                              (global-set-key "\C-c\C-g" 'proof-goto-point)))

;; ssreflect
(load-file "$HOME/etc/ssreflect-1.5/pg-ssr.el")

;; auto-complete
(require 'auto-complete-config)
(ac-config-default)

;; theme
(load-theme 'wombat t)
(enable-theme 'wombat)

;; backup file
(setq make-backup-files nil)
(setq auto-save-default nil)
