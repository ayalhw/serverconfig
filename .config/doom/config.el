;;; private/amos/config.el -*- lexical-binding: t; no-byte-compile: t; -*-

(load! "+bindings")
(require 'dash)
(require 'ivy)
(require 'evil-multiedit)
(require 'company) ; it loads company-lsp which loads lsp

(use-package! speed-type
  :defer
  :config
  (map!
   :map speed-type--completed-keymap
   :ni "q" #'kill-this-buffer
   :ni "r" #'speed-type--replay
   :ni "n" #'speed-type--play-next))

(use-package! flyspell-lazy
  :config
  (add-to-list 'ispell-extra-args "--sug-mode=ultra")
  (flyspell-lazy-mode +1))

(use-package! quick-peek
  :defer)

(use-package! flycheck
  :after-call (doom-switch-buffer-hook after-find-file)
  :config
  ;; Emacs feels snappier without checks on newline
  (setq flycheck-check-syntax-automatically '(save idle-change mode-enabled))
  (after! evil
    (defun +syntax-checkers|flycheck-buffer ()
      "Flycheck buffer on ESC in normal mode."
      (when flycheck-mode
        (ignore-errors (flycheck-buffer))
        nil))
    (add-hook! 'doom-escape-hook #'+syntax-checkers|flycheck-buffer t))
  (global-flycheck-inline-mode +1)
  (global-flycheck-mode +1)

  ;; (advice-add #'flycheck-display-error-messages :override #'flycheck-inline-display-errors)
  (setq flycheck-highlighting-mode 'columns
        flycheck-check-syntax-automatically '(save mode-enabled)
        flycheck-indication-mode nil
        ;; flycheck-inline-display-function
        ;; (lambda (msg pos)
        ;;   (let* ((ov (quick-peek-overlay-ensure-at pos))
        ;;          (contents (quick-peek-overlay-contents ov)))
        ;;     (setf (quick-peek-overlay-contents ov)
        ;;           (concat contents (when contents "\n") msg))
        ;;     (quick-peek-update ov)))
        ;; flycheck-inline-clear-function #'quick-peek-hide
        flycheck-display-errors-delay 0))

(use-package! dired-open
  :after dired
  :config
  (push #'+amos/dired-open-callgrind dired-open-functions))

(use-package! dired-quick-sort
  :after dired
  :config
  (dired-quick-sort-setup))

(use-package! direnv
  :config
  (setq direnv-show-paths-in-summary nil)
  (direnv-mode +1)
  (add-hook! 'after-save-hook (if (string= (file-name-nondirectory buffer-file-name) ".envrc") (direnv-update-environment)))
  (defun +amos/direnv-reload ()
    (interactive)
    (shell-command! "direnv allow")
    (direnv-update-environment)
    (direnv-mode +1)))

(use-package! cc-playground
  :init
  (put 'cc-exec 'safe-local-variable #'stringp)
  (put 'cc-flags 'safe-local-variable #'stringp)
  (put 'cc-links 'safe-local-variable #'stringp)
  (dolist (x '(cc-playground-exec cc-playground-debug cc-playground-exec-test cc-playground-bench))
    (advice-add x :before #'evil-normal-state))
  :bind (:map cc-playground-mode-map
          ("<f8>" . cc-playground-rm) ; terminal
          ("S-RET" . cc-playground-rm) ; gui
          ("C-c r" . cc-playground-add-or-modify-tag)
          ("C-c b" . cc-playground-bench)
          ("C-c d" . cc-playground-debug)
          ("C-c t" . cc-playground-debug-test)
          ("C-c l" . cc-playground-ivy-add-library-link)
          ("C-c c" . cc-playground-change-compiler)
          ("C-c o" . cc-playground-switch-optimization-flag)
          ("C-c f" . cc-playground-add-compilation-flags))
  :config
  (add-hook! 'cc-playground-mode-hook (rmsbolt-mode +1))
  (add-hook! 'cc-playground-rm-hook
    (doom-with-advice (y-or-n-p (lambda (&rest _) t)) (ignore-errors (lsp-shutdown-workspace)))))

(use-package! sync-recentf)

(use-package! rainbow-mode
  :defer)

(use-package! google-translate
  :defer)

(use-package! kurecolor
  :init
  ;; | color    | toggle                     | meaning      |
  ;; |----------+----------------------------+--------------|
  ;; | red      |                            | persist      |
  ;; | blue     | :exit t                    | transient    |
  ;; | amaranth | :foreign-keys warn         | persist w    |
  ;; | teal     | :foreign-keys warn :exit t | transient w  |
  ;; | pink     | :foreign-keys run          | nested       |
  (defhydra +rgb@kurecolor (:color red :hint nil)
    "
Inc/Dec      _w_/_W_ brightness      _d_/_D_ saturation      _e_/_E_ hue    "
    ("w" kurecolor-decrease-brightness-by-step)
    ("W" kurecolor-increase-brightness-by-step)
    ("d" kurecolor-decrease-saturation-by-step)
    ("D" kurecolor-increase-saturation-by-step)
    ("e" kurecolor-decrease-hue-by-step)
    ("E" kurecolor-increase-hue-by-step)
    ("q" nil "cancel" :color blue))
  (advice-add #'+rgb@kurecolor/body :before (lambda (&rest _) (rainbow-mode +1)))
  :defer)

(use-package! lsp-mode
  :init
  (setq
   lsp-prefer-flymake nil
   lsp-enable-indentation nil
   lsp-enable-file-watchers nil
   lsp-auto-guess-root t)
  :defer
  :config
  (add-hook! 'kill-emacs-hook (setq lsp-restart 'ignore))
  (add-hook! 'lsp-after-open-hook #'lsp-enable-imenu))

(use-package! lsp-ui
  :init
  (setq lsp-ui-sideline-enable nil
        lsp-ui-sideline-show-diagnostics nil)
  (add-hook! 'lsp-ui-mode-hook
    (defun +amos-init-ui-flycheck-h ()
      (require 'lsp-ui-flycheck)
      (lsp-ui-flycheck-enable t)))
  :defer)

(use-package! go-playground
  :defer
  :bind (:map go-playground-mode-map
          ("<f8>" . go-playground-rm)))

(use-package! rust-playground
  :defer
  :bind (:map rust-playground-mode-map
          ("<f8>" . rust-playground-rm)))

(use-package! py-playground
  :defer
  :config
  (dolist (x '(py-playground-exec py-playground-debug))
    (advice-add x :before #'evil-normal-state))
  :bind (:map py-playground-mode-map
          ("<f8>" . py-playground-rm) ; terminal
          ("S-RET" . py-playground-rm) ; gui
          ("C-c r" . py-playground-add-or-modify-tag)
          ("C-c d" . py-playground-debug)))

(use-package! gitattributes-mode
  :defer)

(use-package! gitconfig-mode
  :defer)

(use-package! gitignore-mode
  :defer)

;; way slower
;; (use-package! magit-svn
;;   :commands turn-on-magit-svn
;;   :init (add-hook 'magit-mode-hook 'turn-on-magit-svn))

(use-package! page-break-lines
  :init
  (global-page-break-lines-mode +1))

(use-package! adoc-mode
  :mode "\\.adoc$")

(use-package! hl-line+
  :config
  (global-hl-line-mode +1))

(use-package! unfill
  :config
  (global-set-key [remap fill-paragraph] #'unfill-toggle))

(use-package! easy-hugo
  :defer
  :config
  (evil-set-initial-state 'easy-hugo-mode 'emacs)
  (add-hook! 'easy-hugo-mode-hook (setq-local amos-browse t)))

(use-package! lispyville
  :defer)

(use-package! move-text
  :defer)

(use-package! ws-butler
  :config
  (ws-butler-global-mode +1))

(use-package! syntactic-close
  :defer)

(use-package! realign-mode
  :config
  ;; (add-hook! 'realign-hooks #'recenter)
  (defun amos-special-window-p (window)
    (let* ((buffer (window-buffer window))
           (framename (frame-parameter (window-frame window) 'name))
           (buffname (string-trim (buffer-name buffer))))
      (or (equal buffname "*doom*")
          (with-current-buffer buffer server-visit-file)
          (equal buffname "*flycheck-posframe-buffer*")
          (equal buffname "*Ediff Control Panel*")
          (equal (with-current-buffer buffer major-mode) 'mu4e-view-mode)
          (equal (with-current-buffer buffer major-mode) 'mu4e-compose-mode)
          (equal (with-current-buffer buffer major-mode) 'pdf-view-mode))))
  (push #'amos-special-window-p realign-ignore-window-predicates))

(use-package! narrow-reindent
  :config
  (defun narrow-reindent-mode-maybe ()
    (if (not (minibufferp))
        (narrow-reindent-mode +1)))
  (define-global-minor-mode global-narrow-reindent-mode
    narrow-reindent-mode narrow-reindent-mode-maybe
    :group 'narrow-reindent)
  (global-narrow-reindent-mode +1))

(use-package! git-gutter
  :config
  (defface +amos:modified
    '((t (:foreground "chocolate" :weight bold :inherit default)))
    "Face of modified")

  (defface +amos:added
    '((t (:foreground "ForestGreen" :weight bold :inherit default)))
    "Face of added")

  (defface +amos:deleted
    '((t (:foreground "DarkRed" :weight bold :inherit default)))
    "Face of deleted")

  (global-git-gutter-mode +1)
  (advice-add #'git-gutter:set-window-margin :override #'ignore)
  (defun +amos-git-gutter:before-string-a (sign)
    (let* ((gutter-sep (concat " " (make-string (- (if (car (window-margins)) (car (window-margins)) 4) 2) ? ) sign))
           (face (pcase sign
                   ("=" '+amos:modified)
                   ("+" '+amos:added)
                   ("-" '+amos:deleted)))
           (ovstring (propertize gutter-sep 'face face)))
      (propertize " " 'display `((margin left-margin) ,ovstring))))

  (defun +amos-git-gutter:start-git-diff-process-a (file proc-buf)
    (let ((arg (git-gutter:git-diff-arguments file)))
      (apply #'start-file-process "git-gutter" proc-buf
             "git" "--no-pager" "-c" "diff.autorefreshindex=0"
             "diff" "--no-color" "--no-ext-diff" "--relative" "-U0" "--"
             arg)))
  (advice-add #'git-gutter:put-signs :before (lambda (&rest _) (realign-windows)))
  (advice-add #'git-gutter:before-string :override #'+amos-git-gutter:before-string-a)
  (advice-add #'git-gutter:start-git-diff-process :override #'+amos-git-gutter:start-git-diff-process-a)
  (add-hook 'window-configuration-change-hook #'git-gutter:update-all-windows))

(use-package! evil-textobj-line
  :after evil)

(use-package! chinese-yasdcv
  :defer)

(defun +amos/recenter (&rest _)
  (interactive)
  (ignore-errors
    (recenter)
    (+nav-flash/blink-cursor)))

(defvar +amos-dir (file-name-directory load-file-name))
(defvar +amos-snippets-dir (expand-file-name "snippets/" +amos-dir))
;; Don't use default snippets, use mine.
(after! yasnippet
  (add-hook! 'yas-minor-mode-hook (yas-activate-extra-mode 'fundamental-mode))
  (setq yas-snippet-dirs
        (append (list '+amos-snippets-dir '+file-templates-dir)
                (delq 'yas-installed-snippets-dir yas-snippet-dirs))))

(add-to-list 'auto-mode-alist '("/git/serverconfig/scripts/.+" . sh-mode))
(setq +file-templates-alist
      `(;; General
        ("/git/serverconfig/scripts/.+" :mode sh-mode)
        ("/git/serverconfig/.config/fish/functions/.+" :trigger "__func" :mode fish-mode)
        (gitignore-mode)
        (dockerfile-mode)
        ("/docker-compose\\.yml$" :mode yaml-mode)
        ("/Makefile$"             :mode makefile-gmake-mode)
        ;; elisp
        ("/.dir-locals.el$")
        ("/packages\\.el$" :when +file-templates-in-emacs-dirs-p
         :trigger "__doom-packages"
         :mode emacs-lisp-mode)
        ("/doctor\\.el$" :when +file-templates-in-emacs-dirs-p
         :trigger "__doom-doctor"
         :mode emacs-lisp-mode)
        ("/test/.+\\.el$" :when +file-templates-in-emacs-dirs-p
         :trigger "__doom-test"
         :mode emacs-lisp-mode)
        ("\\.el$" :when +file-templates-in-emacs-dirs-p
         :trigger "__doom-module"
         :mode emacs-lisp-mode)
        ("-test\\.el$" :mode emacs-ert-mode)
        (emacs-lisp-mode :trigger "__initfile")
        (snippet-mode)
        ;; web-mode
        ("/normalize\\.scss$" :trigger "__normalize.scss" :mode scss-mode)
        ("/master\\.scss$" :trigger "__master.scss" :mode scss-mode)
        ("\\.html$" :trigger "__.html" :mode web-mode)
        (scss-mode)
        ;; java
        ("/main\\.java$" :trigger "__main" :mode java-mode)
        ("/build\\.gradle$" :trigger "__build.gradle" :mode android-mode)
        ("/src/.+\\.java$" :mode java-mode)
        ;; javascript
        ("/package\\.json$"        :trigger "__package.json" :mode json-mode)
        ("/bower\\.json$"          :trigger "__bower.json" :mode json-mode)
        ("/gulpfile\\.js$"         :trigger "__gulpfile.js" :mode js-mode)
        ("/webpack\\.config\\.js$" :trigger "__webpack.config.js" :mode js-mode)
        ("\\.js\\(?:on\\|hintrc\\)$" :mode json-mode)
        ;; Lua
        ("/main\\.lua$" :trigger "__main.lua" :mode love-mode)
        ("/conf\\.lua$" :trigger "__conf.lua" :mode love-mode)
        ;; Markdown
        (markdown-mode)
        ;; Org
        ("/README\\.org$"
         :when +file-templates-in-emacs-dirs-p
         :trigger "__doom-readme"
         :mode org-mode)
        ("\\.org$" :trigger "__" :mode org-mode)
        ;; PHP
        ("\\.class\\.php$" :trigger "__.class.php" :mode php-mode)
        (php-mode)
        ;; Python
        ;; TODO ("tests?/test_.+\\.py$" :trigger "__" :mode nose-mode)
        ;; TODO ("/setup\\.py$" :trigger "__setup.py" :mode python-mode)
        (python-mode)
        ;; Ruby
        ("/lib/.+\\.rb$"      :trigger "__module"   :mode ruby-mode :project t)
        ("/spec_helper\\.rb$" :trigger "__helper"   :mode rspec-mode :project t)
        ("_spec\\.rb$"                              :mode rspec-mode :project t)
        ("/\\.rspec$"         :trigger "__.rspec"   :mode rspec-mode :project t)
        ("\\.gemspec$"        :trigger "__.gemspec" :mode ruby-mode :project t)
        ("/Gemfile$"          :trigger "__Gemfile"  :mode ruby-mode :project t)
        ("/Rakefile$"         :trigger "__Rakefile" :mode ruby-mode :project t)
        (ruby-mode)
        ;; Rust
        ("/Cargo.toml$" :trigger "__Cargo.toml" :mode rust-mode)
        ("/main\\.rs$" :trigger "__main.rs" :mode rust-mode)
        ;; Slim
        ("/\\(?:index\\|main\\)\\.slim$" :mode slim-mode)
        ;; Shell scripts
        ("\\.zunit$" :trigger "__zunit" :mode sh-mode)
        (fish-mode)
        (sh-mode)
        ;; Solidity
        (solidity-mode :trigger "__sol")))

(setq epa-file-encrypt-to user-mail-address
      c-tab-always-indent t
      auth-sources (list (expand-file-name ".authinfo.gpg" +amos-dir)))

(defun +amos-no-authinfo-for-tramp-a (orig-fn &rest args)
  "Don't look into .authinfo for local sudo TRAMP buffers."
  (let ((auth-sources (if (equal tramp-current-method "sudo") nil auth-sources)))
    (apply orig-fn args)))
(advice-add #'tramp-read-passwd :around #'+amos-no-authinfo-for-tramp-a)

(defmacro +amos-make-special-indent-fn! (keyword)
  `(let* ((sname (symbol-name ,keyword))
          (s (intern (concat "special-indent-fn-" sname))))
     (fset s (lambda (pos state)
               (save-excursion
                 (search-backward sname)
                 (current-column))))
     (put ,keyword 'lisp-indent-function s)))
(setq +amos-list-starters
      '(:hint
        :textDocument
        ))
(--map (+amos-make-special-indent-fn! it) +amos-list-starters)
(put :color 'lisp-indent-function 'defun)
(put :pre 'lisp-indent-function 'defun)
(put :post 'lisp-indent-function 'defun)

(after! evil-snipe (evil-snipe-mode -1))

(after! evil-multiedit
  (setq evil-multiedit-follow-matches t)
  (add-hook! 'evil-multiedit-insert-state-entry-hook
    (evil-start-undo-step)
    (setq evil-in-single-undo t))
  (add-hook! 'evil-multiedit-insert-state-exit-hook
    (setq evil-in-single-undo nil)
    (evil-end-undo-step)))

(defun sp-point-after-same-p (id action _context)
  "Return t if point is followed by ID, nil otherwise.
This predicate is only tested on \"insert\" action."
  (when (eq action 'insert)
    (save-excursion
      (backward-char 1) ; go before current inserted quote
      (sp--looking-back-p (regexp-quote id)))))

(defun +amos-sp-point-after-bol-p (id action _context)
  "Return t if point follows beginning of line and possibly white spaces, nil otherwise.
This predicate is only tested on \"insert\" action."
  (when (eq action 'insert)
    (save-excursion
      (backward-char 1) ; go before current inserted quote
      (sp--looking-back-p (concat "^\\s-*" (regexp-quote id))))))

(after! smartparens
  ;; Auto-close more conservatively
  (let ((unless-list '(sp-point-before-word-p
                       sp-point-after-word-p
                       sp-point-before-same-p
                       sp-point-after-same-p)))
    (sp-pair "'"  nil :unless unless-list)
    (sp-pair "\"" nil :unless unless-list))
  (sp-pair "{" nil :post-handlers '(("||\n[i]" "RET") ("| " " "))
           :unless '(sp-point-before-word-p sp-point-before-same-p))
  (sp-pair "(" nil :post-handlers '(("||\n[i]" "RET") ("| " " "))
           :unless '(sp-point-before-word-p sp-point-before-same-p))
  (sp-pair "[" nil :post-handlers '(("| " " "))
           :unless '(sp-point-before-word-p sp-point-before-same-p)))

(defun col-at-point (point)
  (save-excursion (goto-char point) (current-column)))

(defun evil--mc-make-cursor-at-col-append (_startcol endcol orig-line)
  (end-of-line)
  (when (> endcol (current-column))
    (insert-char ?\s (- endcol (current-column))))
  (move-to-column endcol)
  (unless (= (line-number-at-pos) orig-line)
    (evil-mc-make-cursor-here)))

(defun evil--mc-make-cursor-at-col-insert (startcol _endcol orig-line)
  (end-of-line)
  (move-to-column startcol)
  (unless (or (= (line-number-at-pos) orig-line) (> startcol (current-column)))
    (evil-mc-make-cursor-here)))

(defun evil--mc-make-vertical-cursors (beg end func)
  (evil-mc-pause-cursors)
  (apply-on-rectangle func
                      beg end (line-number-at-pos (point)))
  (evil-mc-resume-cursors)
  (evil-insert-state))

(defun evil-mc-insert-vertical-cursors (beg end)
  (interactive (list (region-beginning) (region-end)))
  (evil--mc-make-vertical-cursors beg end 'evil--mc-make-cursor-at-col-insert)
  (move-to-column (min (col-at-point beg) (col-at-point end))))

(defun evil-mc-append-vertical-cursors (beg end)
  (interactive (list (region-beginning) (region-end)))
  (when (and (evil-visual-state-p)
             (eq (evil-visual-type) 'line))
    (message "good")
    (let ((column (max (evil-column evil-visual-beginning)
                       (evil-column evil-visual-end))))
      (evil-visual-rotate 'upper-left)
      (move-to-column column t))
    )
  (evil--mc-make-vertical-cursors beg end 'evil--mc-make-cursor-at-col-append)
  (move-to-column (max (col-at-point beg) (col-at-point end))))

(after! evil-mc
  (nconc evil-mc-known-commands
         '((evil-repeat . ((:default . evil-mc-execute-default-call)))
           (+amos/smart-eol-insert . ((:default . evil-mc-execute-default-call)))
           (company-complete-common . ((:default . evil-mc-execute-default-complete)))
           (company-select-next . ((:default . evil-mc-execute-default-complete)))
           (company-select-previous . ((:default . evil-mc-execute-default-complete)))
           (+amos/delete-forward-word . ((:default . evil-mc-execute-default-call)))
           (+amos/delete-backward-word . ((:default . evil-mc-execute-default-call)))
           (+amos/delete-forward-subword . ((:default . evil-mc-execute-default-call)))
           (+amos/delete-backward-subword . ((:default . evil-mc-execute-default-call)))
           (+amos/delete-char . ((:default . evil-mc-execute-default-call)))
           (+amos/delete-backward-char . ((:default . evil-mc-execute-default-call)))
           (+amos/kill-line . ((:default . evil-mc-execute-default-call)))
           (+amos/backward-kill-to-bol-and-indent . ((:default . evil-mc-execute-default-call)))
           (+amos/replace-last-sexp . ((:default . evil-mc-execute-default-call)))
           (+amos/backward-word-insert . ((:default . evil-mc-execute-default-call-with-count) (visual . evil-mc-execute-visual-text-object)))
           (+amos/forward-word-insert . ((:default . evil-mc-execute-default-call-with-count) (visual . evil-mc-execute-visual-text-object)))
           (+amos/backward-subword-insert . ((:default . evil-mc-execute-default-call-with-count) (visual . evil-mc-execute-visual-text-object)))
           (+amos/forward-subword-insert . ((:default . evil-mc-execute-default-call-with-count) (visual . evil-mc-execute-visual-text-object)))
           (+amos/evil-backward-subword-begin . ((:default . evil-mc-execute-default-call-with-count) (visual . evil-mc-execute-visual-text-object)))
           (+amos/evil-forward-subword-begin . ((:default . evil-mc-execute-default-call-with-count) (visual . evil-mc-execute-visual-text-object)))
           (+amos/evil-forward-subword-end . ((:default . evil-mc-execute-default-call-with-count) (visual . evil-mc-execute-visual-text-object)))))

  ;; if I'm in insert mode, chances are I want cursors to resume
  (add-hook! 'evil-mc-before-cursors-created
    (add-hook 'evil-insert-state-entry-hook #'evil-mc-resume-cursors nil t))
  (add-hook! 'evil-mc-after-cursors-deleted
    (remove-hook 'evil-insert-state-entry-hook #'evil-mc-resume-cursors t)))

(after! cus-edit (evil-set-initial-state 'Custom-mode 'normal))
(after! ivy (evil-set-initial-state 'ivy-occur-grep-mode 'normal))
(after! compile (evil-set-initial-state 'compilation-mode 'normal))

(defun +amos|init-frame (&optional frame)
  (when (and frame (display-graphic-p frame))
    (with-selected-frame frame
      (dolist (charset '(kana han cjk-misc bopomofo))
        (set-fontset-font t charset
                          (font-spec :family "WenQuanYi Micro Hei" :size 14)))
      (remove-hook! 'after-make-frame-functions #'+amos|init-frame))))

(add-hook! 'after-init-hook
  (if initial-window-system
      (+amos|init-frame)
    (add-hook! 'after-make-frame-functions #'+amos|init-frame)))

(use-package osc
  :demand
  :init
  (defun +amos/other-window ()
    (interactive)
    (if (display-graphic-p)
        (i3-nav-right)
      (osc-nav-right)))
  (setq interprogram-cut-function 'osc-select-text
        browse-url-browser-function (lambda (url &optional _new-window)
                                      (if (display-graphic-p)
                                          (if _new-window
                                              (browse-url-chrome url)
                                            (browse-url-firefox url))
                                        (browse-url-osc url _new-window)))))

(defvar server-visit-file nil)

(setq recenter-redisplay nil)
(remove-hook! 'kill-emacs-query-functions #'doom-quit-p)
(remove-hook! 'doom-init-ui-hook #'blink-cursor-mode)
(remove-hook! 'doom-real-buffer-functions #'doom-dired-buffer-p)
;; (remove-hook! 'doom-init-ui-hook #'show-paren-mode)
(add-hook! 'doom-after-init-modules-hook
  (realign-mode)
  (blink-cursor-mode -1)
  (setq-default truncate-lines nil))

(let ((evil-cursors '(("normal" "#b8860b" box)
                      ("insert" "#66cd00" bar)
                      ("emacs" "#7ec0ee" box)
                      ("replace" "#cd6600" hbar)
                      ("visual" "#808080" hbar)
                      ("motion" "#cd96cd" box)
                      ("lisp" "#ff6eb4" bar)
                      ("sticky" "#B59FEA" box)
                      ("struct" "#8991EF" box)
                      ("iedit" "#ff3030" box)
                      ("multiedit" "#ff3030" box)
                      ("multiedit-insert" "#ff3030" bar)
                      ("iedit-insert" "#ff3030" bar))))
  (cl-loop for (state color cursor) in evil-cursors
           do (set (intern (format "evil-%s-state-cursor" state)) (list color cursor))))

;; may delete the real hyphens
(defadvice fill-delete-newlines (before *amos+fill-delete-newlines activate)
  "Replace -\\n with an empty string when calling `fill-paragraph'."
  (when (eq this-command 'unfill-paragraph)
    (goto-char (ad-get-arg 0))
    (while (search-forward "-\n" (ad-get-arg 1) t)
      (replace-match "")
      (ad-set-arg 1 (- (ad-get-arg 1) 2)))))

(unless window-system
  (require 'evil-terminal-cursor-changer)
  (xterm-mouse-mode +1)
  ;; enable terminal scroll
  (global-set-key (kbd "<mouse-6>")
                  (lambda ()
                    (interactive)
                    (evil-scroll-column-left 3)))
  (global-set-key (kbd "<mouse-7>")
                  (lambda ()
                    (interactive)
                    (evil-scroll-column-right 3)))
  (global-set-key (kbd "<mouse-4>")
                  (lambda ()
                    (interactive)
                    (evil-scroll-line-up 3)))
  (global-set-key (kbd "<mouse-5>")
                  (lambda ()
                    (interactive)
                    (evil-scroll-line-down 3)))
  (etcc-on))

(defun +amos/lookup-docsets (identifier &optional arg)
  (interactive (list (doom-thing-at-point-or-region)
                     current-prefix-arg))
  (let* ((search (if (string= identifier "") "" (concat "-s " identifier))))
    (when-let* ((plist (cdr (assq major-mode +amos-docsets))))
      (when-let* ((docs (s-join " " (doom-enlist (plist-get plist :docs)))))
        (let ((cmd (format "rofidoc %s %s" search docs)))
          (message cmd)
          (osc-command cmd))))))

(setq +amos-docsets nil)
(defun +amos-set-docsets (mode &rest plist)
  (push (cons mode plist) +amos-docsets))

(+amos-set-docsets 'fish-mode :docs '("fish" "Linux_Man_Pages"))
(+amos-set-docsets 'sh-mode :docs '("Bash" "Linux_Man_Pages"))
(+amos-set-docsets 'go-mode :docs "Go")
(+amos-set-docsets 'cmake-mode :docs "CMake")
(+amos-set-docsets 'java-mode :docs "Java")
(+amos-set-docsets 'rust-mode :docs "Rust")
(+amos-set-docsets 'lua-mode :docs '("Lua_5.1" "Lua_5.3"))
(+amos-set-docsets 'c-mode :docs '("C" "Linux_Man_Pages"))
(+amos-set-docsets 'c++-mode :docs '("C" "C++" "Linux_Man_Pages" "Boost"))
(+amos-set-docsets 'python-mode :docs '("Python_3" "Python_2" "NumPy" "SciPy"))
(+amos-set-docsets 'js2-mode :docs "JavaScript")
(+amos-set-docsets 'emacs-lisp-mode :docs "Emacs_Lisp")

(setq-hook! 'lua-mode-hook flycheck-highlighting-mode 'lines)

(defun +amos-browse-url-a (ofun &rest candidate)
  (if (boundp 'amos-browse)
      (apply 'browse-url-firefox candidate)
    (apply ofun candidate)))
(advice-add 'browse-url :around #'+amos-browse-url-a)

(defadvice run-skewer (around +amos*run-skewer activate)
  (setq-local amos-browse t)
  ad-do-it)

(defun my-create-newline-and-enter-sexp (&rest _ignored)
  "Open a new brace or bracket expression, with relevant newlines and indent."
  (newline)
  (indent-according-to-mode)
  (forward-line -1)
  (indent-according-to-mode))

(with-eval-after-load 'smartparens
  (sp-local-pair 'c-mode "{" nil :post-handlers
                 '((my-create-newline-and-enter-sexp "RET")))
  (sp-local-pair 'java-mode "{" nil :post-handlers
                 '((my-create-newline-and-enter-sexp "RET"))))

;; stole from https://emacs.stackexchange.com/a/16495/16662
(defmacro doom-with-advice (args &rest body)
  (declare (indent 3))
  (let ((fun-name (car args))
        (advice   (cadr args))
        (orig-sym (make-symbol "orig")))
    `(cl-letf* ((,orig-sym  (symbol-function ',fun-name))
                ((symbol-function ',fun-name)
                 (lambda (&rest args)
                   (apply ,advice ,orig-sym args))))
       ,@body)))

(defadvice edebug-pop-to-buffer (around +amos*edebug-pop-to-buffer activate)
  (doom-with-advice (split-window (lambda (orig-fun window) (funcall orig-fun window nil 'right)))
      ad-do-it))

(defadvice hl-line-mode (after +amos*hl-line-mode activate)
  (set-face-background hl-line-face "Gray13"))

(defun +amos/evil-undefine ()
  (interactive)
  (let (evil-mode-map-alist)
    (call-interactively (key-binding (this-command-keys)))))

(defun +amos-switch-buffer-matcher-a (regexp candidates)
  "Return REGEXP matching CANDIDATES.
Skip buffers that match `ivy-ignore-buffers'."
  (let ((res (ivy--re-filter regexp candidates)))
    (if (or (null ivy-use-ignore)
            (null ivy-ignore-buffers)
            (string-match "\\`\\." ivy-text))
        res
      (or (cl-remove-if
           (lambda (buf)
             (cl-find-if
              (lambda (f-or-r)
                (if (functionp f-or-r)
                    (funcall f-or-r buf)
                  (string-match-p f-or-r buf)))
              ivy-ignore-buffers))
           res)
          (and (eq ivy-use-ignore t)
               res)))))
(advice-add #'ivy--switch-buffer-matcher :override #'+amos-switch-buffer-matcher-a)

;; recenter buffer when switching windows
(defun +amos-update-window-buffer-list-h ()
  (walk-window-tree
   (lambda (window)
     (let ((old-buffer (window-parameter window 'my-last-buffer))
           (new-buffer (window-buffer window)))
       (unless (eq old-buffer new-buffer)
         ;; The buffer of a previously existing window has changed or
         ;; a new window has been added to this frame.
         ;; (+amos/recenter)
         (setf (window-parameter window 'my-last-buffer) new-buffer))))))
(add-hook! 'window-configuration-change-hook #'+amos-update-window-buffer-list-h)

(defun +amos-evil-ex-search-before-a (&rest _)
  (if (thing-at-point 'symbol) (leap-set-jump)))
(advice-add #'evil-ex-start-word-search :before #'+amos-evil-ex-search-before-a)
(advice-add #'evil-visualstar/begin-search :before #'+amos-evil-ex-search-before-a)

(defun +amos/counsel-rg-projectile ()
  (interactive)
  (unless (doom-project-p)
    (user-error "You're not in a project"))
  (counsel-rg nil (doom-project-root)))

(defun +amos/counsel-rg-cur-dir ()
  (interactive)
  (counsel-rg nil default-directory t))

(use-package! yapfify
  :after python)

;; from spacemacs
(defun +amos/rename-current-buffer-file (&optional arg)
  "Rename the current buffer and the file it is visiting.
If the buffer isn't visiting a file, ask if it should
be saved to a file, or just renamed.

If called without a prefix argument, the prompt is
initialized with the current filename."
  (interactive "P")
  (let* ((name (buffer-name))
         (filename (buffer-file-name)))
    (if (and filename (file-exists-p filename))
        ;; the buffer is visiting a file
        (let* ((dir (file-name-directory filename))
               (new-name (read-file-name "New name: " (if arg dir filename))))
          (cond ((get-buffer new-name)
                 (error "A buffer named '%s' already exists!" new-name))
                (t
                 (let ((dir (file-name-directory new-name)))
                   (when (and (not (file-exists-p dir))
                              (yes-or-no-p
                               (format "Create directory '%s'?" dir)))
                     (make-directory dir t)))
                 (rename-file filename new-name 1)
                 (rename-buffer new-name)
                 (set-visited-file-name new-name)
                 (set-buffer-modified-p nil)
                 (when (fboundp 'recentf-add-file)
                   (recentf-add-file new-name)
                   (recentf-remove-if-non-kept filename))
                 (when (and (featurep 'projectile)
                            (projectile-project-p))
                   (call-interactively #'projectile-invalidate-cache))
                 (message "File '%s' successfully renamed to '%s'"
                          name (file-name-nondirectory new-name))
                 (doom-modeline-update-buffer-file-state-icon)
                 (doom-modeline-update-buffer-file-name)
                 )))
      ;; the buffer is not visiting a file
      (let ((key))
        (while (not (memq key '(?s ?r)))
          (setq key (read-key (propertize
                               (format
                                (concat "Buffer '%s' is not visiting a file: "
                                        "[s]ave to file or [r]ename buffer?")
                                name) 'face 'minibuffer-prompt)))
          (cond ((eq key ?s)            ; save to file
                 ;; this allows for saving a new empty (unmodified) buffer
                 (unless (buffer-modified-p) (set-buffer-modified-p t))
                 (save-buffer))
                ((eq key ?r)            ; rename buffer
                 (let ((new-name (read-string "New buffer name: ")))
                   (while (get-buffer new-name)
                     ;; ask to rename again, if the new buffer name exists
                     (if (yes-or-no-p
                          (format (concat "A buffer named '%s' already exists: "
                                          "Rename again?") new-name))
                         (setq new-name (read-string "New buffer name: "))
                       (keyboard-quit)))
                   (rename-buffer new-name)
                   (message "Buffer '%s' successfully renamed to '%s'"
                            name new-name)))
                ;; ?\a = C-g, ?\e = Esc and C-[
                ((memq key '(?\a ?\e)) (keyboard-quit))))))))

;; BEGIN align functions
(defun +amos/align-repeat-left (start end regexp)
  (interactive "r\nsAlign regexp: ")
  (+amos/align-repeat start end regexp))
(defun +amos/align-repeat-right (start end regexp)
  (interactive "r\nsAlign regexp: ")
  (+amos/align-repeat start end regexp t t))
;; modified function from http://emacswiki.org/emacs/AlignCommands
(defun +amos/align-repeat (start end regexp &optional justify-right after)
  "Repeat alignment with respect to the given regular expression.
If JUSTIFY-RIGHT is non nil justify to the right instead of the
left. If AFTER is non-nil, add whitespace to the left instead of
the right."
  (let* ((ws-regexp (if (string-empty-p regexp)
                        "\\(\\s-+\\)"
                      "\\(\\s-*\\)"))
         (complete-regexp (if after
                              (concat regexp ws-regexp)
                            (concat ws-regexp regexp)))
         (group (if justify-right -1 1)))
    (unless (use-region-p)
      (save-excursion
        (while (and
                (string-match-p complete-regexp (thing-at-point 'line))
                (= 0 (forward-line -1)))
          (setq start (point-at-bol))))
      (save-excursion
        (while (and
                (string-match-p complete-regexp (thing-at-point 'line))
                (= 0 (forward-line 1)))
          (setq end (point-at-eol)))))
    (align-regexp start end complete-regexp group 1 t)))

(defun +amos/dos2unix ()
  "Converts the current buffer to UNIX file format."
  (interactive)
  (set-buffer-file-coding-system 'undecided-unix nil))

(defun +amos/unix2dos ()
  "Converts the current buffer to DOS file format."
  (interactive)
  (set-buffer-file-coding-system 'undecided-dos nil))

;; from https://www.emacswiki.org/emacs/CopyingWholeLines
(defun +amos/duplicate-line-or-region (&optional n)
  "Duplicate current line, or region if active.
With argument N, make N copies.
With negative N, comment out original line and use the absolute value."
  (interactive "*p")
  (let ((use-region (use-region-p)))
    (save-excursion
      (let ((text (if use-region        ; Get region if active, otherwise line
                      (buffer-substring (region-beginning) (region-end))
                    (prog1 (thing-at-point 'line)
                      (end-of-line)
                      (if (< 0 (forward-line 1)) ; Go to beginning of next line, or make a new one
                          (newline))))))
        (dotimes (i (abs (or n 1)))     ; Insert N times, or once if not specified
          (insert text))))
    (if use-region nil                  ; Only if we're working with a line (not a region)
      (let ((pos (- (point) (line-beginning-position)))) ; Save column
        (if (> 0 n)                             ; Comment out original with negative arg
            (comment-region (line-beginning-position) (line-end-position)))
        (forward-line 1)
        (forward-char pos)))))

(defun +amos/uniquify-lines ()
  "Remove duplicate adjacent lines in a region or the current buffer"
  (interactive)
  (save-excursion
    (save-restriction
      (let* ((region-active (or (region-active-p) (evil-visual-state-p)))
             (beg (if region-active (region-beginning) (point-min)))
             (end (if region-active (region-end) (point-max))))
        (goto-char beg)
        (while (re-search-forward "^\\(.*\n\\)\\1+" end t)
          (replace-match "\\1"))))))

(defun +amos/sort-lines (&optional reverse)
  "Sort lines in a region or the current buffer.
A non-nil argument sorts in reverse order."
  (interactive "P")
  (let* ((region-active (or (region-active-p) (evil-visual-state-p)))
         (beg (if region-active (region-beginning) (point-min)))
         (end (if region-active (region-end) (point-max))))
    (sort-lines reverse beg end)))

(defun +amos/sort-lines-reverse ()
  "Sort lines in reverse order, in a region or the current buffer."
  (interactive)
  (+amos/sort-lines -1))

(defun +amos/sort-lines-by-column (&optional reverse)
  "Sort lines by the selected column,
using a visual block/rectangle selection.
A non-nil argument sorts in REVERSE order."
  (interactive "P")
  (if (and
       ;; is there an active selection
       (or (region-active-p) (evil-visual-state-p))
       ;; is it a block or rectangle selection
       (or (eq evil-visual-selection 'block) (eq rectangle-mark-mode t))
       ;; is the selection height 2 or more lines
       (>= (1+ (- (line-number-at-pos (region-end))
                  (line-number-at-pos (region-beginning)))) 2))
      (sort-columns reverse (region-beginning) (region-end))
    (error "Sorting by column requires a block/rect selection on 2 or more lines.")))

(defun +amos/sort-lines-by-column-reverse ()
  "Sort lines by the selected column in reverse order,
using a visual block/rectangle selection."
  (interactive)
  (+amos/sort-lines-by-column -1))

(defun swap-args (fun)
  (if (not (equal (interactive-form fun)
                  '(interactive "P")))
      (error "Unexpected")
    (advice-add
     fun
     :around
     (lambda (x &rest args)
       "Swap the meaning the universal prefix argument"
       (if (called-interactively-p 'any)
           (apply x (cons (not (car args)) (cdr args)))
         (apply x args))))))

(after! evil-surround
  (setq-default evil-surround-pairs-alist (append '((?` . ("`" . "`")) (?~ . ("~" . "~"))) evil-surround-pairs-alist)))

(defun +amos-ivy-rich-switch-buffer-pad-a (str len &optional left)
  "Improved version of `ivy-rich-switch-buffer-pad' that truncates long inputs."
  (let ((real-len (length str)))
    (cond
     ((< real-len len) (if left
                           (concat (make-string (- len real-len) ? ) str)
                         (concat str (make-string (- len real-len) ? ))))
     ((= len real-len) str)
     ((< len 1) str)
     (t (concat (substring str 0 (- len 1)) "…")))))

;; Override the original function using advice
(advice-add 'ivy-rich-switch-buffer-pad :override #'+amos-ivy-rich-switch-buffer-pad-a)

(evil-define-motion +amos-evil-beginning-of-line-a ()
  "Move the cursor to the beginning of the current line."
  :type exclusive
  (if (bolp)
      (back-to-indentation)
    (let ((p (point)))
      (back-to-indentation)
      (if (<= p (point))
          (beginning-of-line)))))
(advice-add 'evil-beginning-of-line :override #'+amos-evil-beginning-of-line-a)

(defun +amos/save-buffer-without-dtw ()
  (interactive)
  (let ((b (current-buffer)))   ; memorize the buffer
    (with-temp-buffer ; new temp buffer to bind the global value of before-save-hook
      (let ((before-save-hook (remove 'ws-butler-before-save before-save-hook)))
        (with-current-buffer b  ; go back to the current buffer, before-save-hook is now buffer-local
          (let ((before-save-hook (remove 'ws-butler-before-save before-save-hook)))
            (save-buffer)))))))

(defun +amos/counsel-projectile-switch-project ()
  (interactive)
  (require 'counsel-projectile)
  (ivy-read (projectile-prepend-project-name "Switch to project: ")
            projectile-known-projects
            :preselect (and (projectile-project-p)
                            (abbreviate-file-name (projectile-project-root)))
            :action #'+amos/find-file
            :require-match t
            :caller #'+amos/counsel-projectile-switch-project))

(defun +amos/projectile-current-project-files ()
  "Return a list of files for the current project."
  (let* ((directory (projectile-project-root))
         (files (and projectile-enable-caching
                     (gethash directory projectile-projects-cache))))
    ;; nothing is cached
    (unless files
      (when projectile-enable-caching
        (message "Empty cache. Projectile is initializing cache..."))
      (setq files
            (projectile-adjust-files
             directory
             (projectile-project-vcs directory)
             (split-string
              (shell-command-to-string
               (concat "cd " (projectile-project-root) "; fd --hidden -E '.git'")) "\n")))
      ;; cache the resulting list of files
      (when projectile-enable-caching
        (projectile-cache-project (projectile-project-root) files)))
    files))

(defun +amos/projectile-find-file (&optional arg)
  "Jump to a file in the current project.

With a prefix ARG, invalidate the cache first."
  (interactive "P")
  (require 'counsel-projectile)
  (projectile-maybe-invalidate-cache arg)
  (ivy-read (projectile-prepend-project-name "Find file: ")
            (+amos/projectile-current-project-files)
            ;; (projectile-current-project-files)
            ;; :matcher counsel-projectile-find-file-matcher
            :require-match t
            :sort t
            :action counsel-projectile-find-file-action
            :caller #'+amos/projectile-find-file))

(advice-add #'projectile-cache-files-find-file-hook :override #'ignore)
(after! projectile
  (advice-remove 'delete-file #'delete-file-projectile-remove-from-cache))

(defvar switch-buffer-functions
  nil
  "A list of functions to be called when the current buffer has been changed.
Each is passed two arguments, the previous buffer and the current buffer.")

(defvar switch-buffer-functions--last-buffer
  nil
  "The last current buffer.")

(defvar switch-buffer-functions--running-p
  nil
  "Non-nil if currently inside of run `switch-buffer-functions-run'.")

(defun switch-buffer-functions-run ()
  "Run `switch-buffer-functions' if needed.
This function checks the result of `current-buffer', and run
`switch-buffer-functions' when it has been changed from
the last buffer.
This function should be hooked to `buffer-list-update-hook'."
  (unless switch-buffer-functions--running-p
    (let ((switch-buffer-functions--running-p t)
          (current (current-buffer))
          (previous switch-buffer-functions--last-buffer))
      (unless (eq previous
                  current)
        (run-hook-with-args 'switch-buffer-functions
                            previous
                            current)
        (setq switch-buffer-functions--last-buffer
              (current-buffer))))))

(add-hook! 'buffer-list-update-hook #'switch-buffer-functions-run)

(defun endless/sharp ()
  "Insert #' unless in a string or comment."
  (interactive)
  (call-interactively #'self-insert-command)
  (let ((ppss (syntax-ppss)))
    (unless (or (elt ppss 3)
                (elt ppss 4)
                (eq (char-after) ?'))
      (insert "'"))))

(add-hook! 'after-save-hook #'executable-make-buffer-file-executable-if-script-p)

(defvar +amos--ivy-regex-hash
  (make-hash-table :test #'equal)
  "Store pre-computed regex.")

(defun +amos-ivy-regex-half-quote-a (str &optional greedy)
  "Re-build regex pattern from STR in case it has a space.
When GREEDY is non-nil, join words in a greedy way."
  (let ((hashed (unless greedy
                  (gethash str +amos--ivy-regex-hash))))
    (if hashed
        (prog1 (cdr hashed)
          (setq ivy--subexps (car hashed)))
      (when (string-match "\\([^\\]\\|^\\)\\\\$" str)
        (setq str (substring str 0 -1)))
      (cdr (puthash str
                    (let ((subs (ivy--split str)))
                      (if (= (length subs) 1)
                          (cons (setq ivy--subexps 0) (regexp-quote (car subs)))
                        (cons (setq ivy--subexps (length subs))
                              (mapconcat (lambda (s) (format "\\(%s\\)" (regexp-quote s))) subs (if greedy ".*" ".*?")))))
                    +amos--ivy-regex-hash)))))
(advice-add #'ivy--regex :override #'+amos-ivy-regex-half-quote-a)

(defvar +amos-escape-ivy-regex "[]^$?+.*[]")
(defun +amos-escape-ivy-string (str)
  (pcase str
    ("\\" "\\\\")
    ("^" "\\^")
    ("$" "\\$")
    ("." "\\.")
    ("+" "\\+")
    ("?" "\\?")
    ("*" "\\*")
    ("[" "\\[")
    ("]" "\\]")))

(defvar +amos-escape-counsel-regex "[]^[$+?.*({)}]")
(defun +amos-escape-counsel-string (str)
  (pcase str
    ("." "\\.")
    ("^" "\\^")
    ("*" "\\*")
    ("?" "\\?")
    ("$" "\\$")
    ("+" "\\+")
    ("[" "\\[")
    ("]" "\\]")
    ("{" "\\{")
    ("}" "\\}")
    (")" "\\)")
    ("(" "\\(")))

(defun +amos-ivy-split (str)
  "Split STR into list of substrings bounded by spaces.
Single spaces act as splitting points.  Consecutive spaces
\"quote\" their preceding spaces, i.e., guard them from being
split.  This allows the literal interpretation of N spaces by
inputting N+1 spaces.  Any substring not constituting a valid
regexp is passed to `regexp-quote'."
  (let ((len (length str))
        start0
        (start1 0)
        res s
        match-len)
    (while (and (string-match " +" str start1)
                (< start1 len))
      (if (and (> (match-beginning 0) 2)
               (string= "[^" (substring
                              str
                              (- (match-beginning 0) 2)
                              (match-beginning 0))))
          (progn
            (setq start0 start1)
            (setq start1 (match-end 0)))
        (setq match-len (- (match-end 0) (match-beginning 0)))
        (if (= match-len 1)
            (progn
              (when start0
                (setq start1 start0)
                (setq start0 nil))
              (push (substring str start1 (match-beginning 0)) res)
              (setq start1 (match-end 0)))
          (setq str (replace-match
                     (make-string (1- match-len) ?\ )
                     nil nil str))
          (setq start0 (or start0 start1))
          (setq start1 (1- (match-end 0))))))
    (if start0
        (push (substring str start0) res)
      (setq s (substring str start1))
      (unless (= (length s) 0)
        (push s res)))
    (nreverse res)))

(defun +amos-counsel-ag-regex (str &optional greedy)
  "Re-build regex pattern from STR in case it has a space.
When GREEDY is non-nil, join words in a greedy way."
  (let ((hashed (unless greedy
                  (gethash str ivy--regex-hash))))
    (if hashed
        (progn
          (setq ivy--subexps (car hashed))
          (cdr hashed))
      (setq str (ivy--trim-trailing-re str))
      (cdr (puthash str
                    (let ((subs (+amos-ivy-split str)))
                      (if (= (length subs) 1)
                          (progn
                            (cons
                             (setq ivy--subexps 0)
                             (setq x (replace-regexp-in-string +amos-escape-counsel-regex #'+amos-escape-counsel-string (car subs) t t))))
                        (cons
                         (setq ivy--subexps (length subs))
                         (mapconcat
                          (lambda (x)
                            (replace-regexp-in-string +amos-escape-counsel-regex #'+amos-escape-counsel-string x t t))
                          subs
                          (if greedy ".*" ".*?")))))
                    ivy--regex-hash)))))

(defun +amos-counsel-rg-function (string)
  "Grep in the current directory for STRING."
  (let* ((command-args (counsel--split-command-args string))
         (search-term (cdr command-args)))
    (or
     (let ((ivy-text search-term))
       (ivy-more-chars))
     (let* ((default-directory (ivy-state-directory ivy-last))
            (regex (+amos-counsel-ag-regex search-term))
            (subs (+amos-ivy-split search-term)))
       (setq ivy--old-re (mapconcat
                          (lambda (x)
                            (format "\\(%s\\)" (replace-regexp-in-string +amos-escape-ivy-regex #'+amos-escape-ivy-string x t t)))
                          subs ".*"))
       (counsel--async-command (append counsel-rg-args `("--" ,regex ".")))
       nil))))

(cl-defun +amos-counsel-rg-a (&optional initial-input initial-directory extra-ag-args ag-prompt &key caller)
  (interactive)
  (setq counsel--regex-look-around t)
  (let ((default-directory (or initial-directory (counsel--git-root) default-directory))
        (ivy-use-selectable-prompt nil))
    (ivy-read "amos-rg: "
              (if extra-ag-args
                  (lambda (string)
                    (let ((counsel-rg-args (append counsel-rg-args '("-uu"))))
                      (+amos-counsel-rg-function string)))
                #'+amos-counsel-rg-function)
              :initial-input initial-input
              :dynamic-collection t
              :keymap counsel-ag-map
              :history 'counsel-git-grep-history
              :action #'counsel-git-grep-action
              :unwind (lambda ()
                        (counsel-delete-process)
                        (swiper--cleanup))
              :caller (or caller 'counsel-rg))))

(advice-add #'counsel-rg :override #'+amos-counsel-rg-a)

(defun +amos-counsel-ag-occur-a ()
  (ivy-occur-grep-mode)
  (insert (format "-*- mode:grep; default-directory: %S -*-\n\n\n"
                  default-directory))
  (insert (format "%d candidates:\n" (length ivy--all-candidates)))
  (ivy--occur-insert-lines ivy--all-candidates))
(advice-add #'counsel-ag-occur :override #'+amos-counsel-ag-occur-a)

(defvar counsel-rg-args '("rgemacs" "-S" "-M" "500" "--no-messages" "--no-heading" "--line-number" "--color" "never"))

(evil-define-command ab-char-inc ()
  (save-excursion
    (let ((chr  (1+ (char-after))))
      (unless (characterp chr) (error "Cannot increment char by one"))
      (delete-char 1)
      (insert chr))))

(evil-define-command +amos/replace-last-sexp ()
  (let ((value (eval (preceding-sexp))))
    (kill-sexp -1)
    (insert (format "%S" value))))

(evil-define-command +amos/replace-defun ()
  (narrow-to-defun)
  (goto-char (point-max))
  (let ((value (eval (preceding-sexp))))
    (kill-sexp -1)
    (insert (format "%s" value)))
  (widen)
  (backward-char))

(evil-define-command +amos/new-empty-elisp-buffer ()
  (let ((buf (generate-new-buffer "*new*")))
    (+amos/workspace-new)
    (switch-to-buffer buf)
    (emacs-lisp-mode)
    (evil-insert-state)
    (setq buffer-offer-save nil)
    buf))

(evil-define-command +amos/ivy-complete-dir ()
  (let ((enable-recursive-minibuffers t)
        (history (+amos--get-all-jump-dirs))
        (old-last ivy-last)
        (ivy-recursive-restore nil))
    (ivy-read "Choose-directory: "
              history
              :action (lambda (x)
                        (setq x (concat x "/"))
                        (ivy--reset-state
                         (setq ivy-last old-last))
                        (delete-minibuffer-contents)
                        (insert (substring-no-properties x))
                        (ivy--cd-maybe)))))

(defun +amos/smart-jumper (&optional f)
  (let* ((dir (if f -1 (forward-char) 1))
         (c (point))
         quote
         delim)
    (setq quote (if (nth 3 (syntax-ppss))
                    (let ((b (save-excursion (progn (up-list -1 t t) (point))))
                          (e (save-excursion (progn (up-list 1 t t) (point)))))
                      (if (and (< b c) (< c e))
                          (if (< 0 dir) e b)
                        (user-error "syntax-ppss says point is in quotes but we cannot locate the boundary.")))
                  -1))
    (if (< 0 quote)
        (goto-char quote)
      (let* ((paren (save-excursion (if (= 0 (evil-up-paren ?\( ?\) dir)) (point) nil)))
             (bracket (save-excursion (if (= 0 (evil-up-paren ?\[ ?\] dir)) (point) nil)))
             (brace (save-excursion (if (= 0 (evil-up-paren ?{ ?} dir)) (point) nil))))
        (setq delim (condition-case nil
                        (if (< dir 0)
                            (-max (--filter it (list paren bracket brace)))
                          (-min (--filter it (list paren bracket brace))))
                      (error nil))))
      (if delim (goto-char delim)))
    (if (< 0 dir) (backward-char))))

(evil-define-command +amos/smart-jumper-backward ()
  (leap-set-jump)
  (+amos/smart-jumper t))

(evil-define-command +amos/smart-jumper-forward ()
  (leap-set-jump)
  (+amos/smart-jumper))

(evil-define-command +amos/complete ()
  (if (/= (point)
          (save-excursion
            (if (bounds-of-thing-at-point 'symbol)
                (end-of-thing 'symbol))
            (point)))
      (save-excursion (insert " ")))
  (company-manual-begin))

(evil-define-command +amos/complete-filter ()
  (+amos/complete)
  (company-filter-candidates))

(defvar my-kill-ring nil)
(defmacro mkr! (&rest body)
  `(let (interprogram-cut-function
         (kill-ring my-kill-ring))
     ,@body
     (setq my-kill-ring kill-ring)))

(evil-define-command +amos/delete-char()
  (mkr! (delete-char 1 1)))

(evil-define-operator +amos/evil-change
  (beg end type register yank-handler delete-func)
  (interactive "<R><x><y>")
  (if (evil-visual-state-p)
      (mkr! (evil-change beg end type register yank-handler delete-func))
    (evil-change beg end type register yank-handler delete-func)))

(evil-define-command +amos/delete-backward-char()
  (mkr! (with-no-warnings (delete-backward-char 1 1))))

(evil-define-command +amos/kill-line ()
  (mkr! (kill-region (point)
                     (let ((overlay (iedit-find-overlay-at-point (point) 'iedit-occurrence-overlay-name)))
                       (if overlay
                           (overlay-end overlay)
                         (point-at-eol))))))

(evil-define-command +amos/backward-kill-to-bol-and-indent ()
  (if (bolp) (+amos/delete-backward-char)
    (let* ((overlay (iedit-find-overlay-at-point (1- (point)) 'iedit-occurrence-overlay-name))
           (x (if overlay (overlay-start overlay) (save-excursion (doom/backward-to-bol-or-indent))))
           (y (point)))
      (mkr! (kill-region x y)))))

(defun +amos-insert-state-p ()
  (or (evil-insert-state-p) (evil-multiedit-insert-state-p) (active-minibuffer-window)))

(defun +amos-insert-state ()
  (setq evil-insert-count 1
        evil-insert-vcount nil)
  (if (evil-multiedit-state-p)
      (evil-multiedit-insert-state)
    (evil-insert-state)))

(defmacro +amos-subword-move! (type command)
  `(evil-define-motion ,(intern (concat "+amos/" (s-replace "word" "subword" (symbol-name command)))) (count)
     :type ,type
     (let ((find-word-boundary-function-table +amos-subword-find-word-boundary-function-table))
       (,command count))))

(+amos-subword-move! inclusive evil-forward-word-end)
(+amos-subword-move! exclusive evil-forward-word-begin)
(+amos-subword-move! exclusive evil-backward-word-begin)

(evil-define-command +amos/delete-forward-word (&optional subword)
  (evil-signal-at-bob-or-eob 1)
  (when (or (not (or (evil-multiedit-state-p) (evil-multiedit-insert-state-p)))
            (iedit-find-overlay-at-point (point) 'iedit-occurrence-overlay-name))
    (unless (+amos-insert-state-p)
      (+amos-insert-state))
    (mkr! (kill-region (point)
                       (max
                        (save-excursion
                          (if (looking-at "[ \t\r\n\v\f]")
                              (progn
                                (re-search-forward "[^ \t\r\n\v\f]")
                                (backward-char))
                            (+amos-word-movement-internal subword 1))
                          (point))
                        (line-beginning-position))))))
(evil-define-command +amos/delete-forward-subword ()
  (+amos/delete-forward-word t))

(evil-define-command +amos/delete-backward-word (&optional subword)
  (evil-signal-at-bob-or-eob -1)
  (when (or (not (or (evil-multiedit-state-p) (evil-multiedit-insert-state-p)))
            (iedit-find-overlay-at-point (1- (point)) 'iedit-occurrence-overlay-name))
    (unless (or (eolp) (+amos-insert-state-p))
      (+amos-insert-state)
      (forward-char))
    (mkr! (kill-region (point)
                       (min
                        (save-excursion
                          (if (looking-back "[ \t\r\n\v\f]")
                              (progn
                                (re-search-backward "[^ \t\r\n\v\f]")
                                (forward-char))
                            (+amos-word-movement-internal subword -1))
                          (point))
                        (line-end-position))))))
(evil-define-command +amos/delete-backward-subword ()
  (+amos/delete-backward-word t))

(evil-define-command +amos/backward-word-insert (&optional subword)
  (evil-signal-at-bob-or-eob -1)
  (unless (or (eolp) (+amos-insert-state-p))
    (+amos-insert-state)
    (forward-char))
  (if (looking-back "[ \t\r\n\v\f]")
      (progn
        (re-search-backward "[^ \t\r\n\v\f]")
        (forward-char))
    (+amos-word-movement-internal subword -1)))
(evil-define-command +amos/backward-subword-insert ()
  (+amos/backward-word-insert t))

(evil-define-command +amos/forward-word-insert (&optional subword)
  (evil-signal-at-bob-or-eob 1)
  (unless (+amos-insert-state-p)
    (+amos-insert-state))
  (if (looking-at "[ \t\r\n\v\f]")
      (progn
        (re-search-forward "[^ \t\r\n\v\f]")
        (backward-char))
    (+amos-word-movement-internal subword 1)))
(evil-define-command +amos/forward-subword-insert ()
  (+amos/forward-word-insert t))

(defvar +amos-subword-forward-regexp
  "\\W*\\(\\([[:upper:]]*\\(\\W\\)?\\)[[:lower:][:digit:]]*\\)"
  "Regexp used by `subword-forward-internal'.")

(defvar +amos-subword-backward-regexp
  "\\(\\(\\W\\|[[:lower:][:digit:]]\\)\\([[:upper:]]+\\W*\\)\\|\\W\\w+\\)"
  "Regexp used by `subword-backward-internal'.")

(defun +amos-subword-forward-internal ()
  (if (and
       (save-excursion
         (let ((case-fold-search nil))
           (modify-syntax-entry ?_ "_")
           (re-search-forward +amos-subword-forward-regexp nil t)))
       (> (match-end 0) (point)))
      (goto-char
       (cond
        ((and (< 1 (- (match-end 2) (match-beginning 2)))
              (not (and (null (match-beginning 3))
                        (eq (match-end 2) (match-end 1)))))
         (1- (match-end 2)))
        (t
         (match-end 0))))
    (forward-word 1)))

(defun +amos-subword-backward-internal ()
  (if (save-excursion
        (let ((case-fold-search nil))
          (modify-syntax-entry ?_ "_")
          (re-search-backward +amos-subword-backward-regexp nil t)))
      (goto-char
       (cond
        ((and (match-end 3)
              (< 1 (- (match-end 3) (match-beginning 3)))
              (not (eq (point) (match-end 3))))
         (1- (match-end 3)))
        (t
         (1+ (match-beginning 0)))))
    (backward-word 1)))

(defconst +amos-subword-find-word-boundary-function-table
  (let ((tab (make-char-table nil)))
    (set-char-table-range tab t #'+amos-subword-find-word-boundary)
    tab))

(defconst +amos-subword-empty-char-table
  (make-char-table nil))

(defun +amos-subword-find-word-boundary (pos limit)
  (let ((find-word-boundary-function-table +amos-subword-empty-char-table))
    (save-match-data
      (save-excursion
        (save-restriction
          (if (< pos limit)
              (progn
                (goto-char pos)
                (narrow-to-region (point-min) limit)
                (+amos-subword-forward-internal))
            (goto-char (1+ pos))
            (narrow-to-region limit (point-max))
            (+amos-subword-backward-internal))
          (point))))))

(defun +amos-word-movement-internal (subword dir)
  (let ((find-word-boundary-function-table
         (if subword
             +amos-subword-find-word-boundary-function-table
           +amos-subword-empty-char-table)))
    (goto-char
     (funcall (if (< 0 dir) #'min #'max)
              (save-excursion
                (let ((word-separating-categories evil-cjk-word-separating-categories)
                      (word-combining-categories evil-cjk-word-combining-categories))
                  (if subword (push '(?u . ?U) word-separating-categories)))
                (forward-word dir)
                (point))
              (save-excursion
                (if (< 0 dir)
                    (if-let ((overlay (iedit-find-overlay-at-point (point) 'iedit-occurrence-overlay-name)))
                        (goto-char (overlay-end overlay))
                      (goto-char (line-end-position)))
                  (if-let ((overlay (iedit-find-overlay-at-point (1- (point)) 'iedit-occurrence-overlay-name)))
                      (goto-char (overlay-start overlay))
                    (goto-char (line-beginning-position))))
                (point))
              (save-excursion
                (forward-thing 'evil-word dir)
                (point))))))

(defun +amos-word-movement-internal (subword dir)
  (let ((find-word-boundary-function-table
         (if subword
             +amos-subword-find-word-boundary-function-table
           +amos-subword-empty-char-table)))
    (evil-forward-nearest
     dir
     (lambda (&optional cnt)
       (let ((word-separating-categories evil-cjk-word-separating-categories)
             (word-combining-categories evil-cjk-word-combining-categories))
         (if subword (push '(?u . ?U) word-separating-categories))
         (pnt (point)))
       (forward-word cnt)
       (if (= pnt (point)) cnt 0))
     (lambda (&optional cnt)
       (if (< 0 cnt)
           (if-let ((overlay (iedit-find-overlay-at-point (point) 'iedit-occurrence-overlay-name)))
               (goto-char (overlay-end overlay))
             (goto-char (line-end-position)))
         (if-let ((overlay (iedit-find-overlay-at-point (1- (point)) 'iedit-occurrence-overlay-name)))
             (goto-char (overlay-start overlay))
           (goto-char (line-beginning-position))))
       0)
     (lambda (&optional cnt) (forward-thing 'evil-word cnt) 0))))

(evil-define-text-object +amos/any-object-inner (count &optional beg end type)
  (save-excursion
    (if (looking-at "['\"]")
        (if (nth 3 (syntax-ppss))
            (backward-char)
          (forward-char))
      (if (looking-at "[[({]")
          (forward-char)))
    (+amos/smart-jumper-backward)
    (forward-char)
    (let ((s (point))
          (e (progn
               (backward-char)
               (+amos/smart-jumper-forward)
               (point))))
      (evil-range s e type :expanded t))))

(evil-define-text-object +amos/any-object-outer (count &optional beg end type)
  (save-excursion
    (if (looking-at "['\"]")
        (if (nth 3 (syntax-ppss))
            (backward-char)
          (forward-char))
      (if (looking-at "[[({]")
          (forward-char)))
    (+amos/smart-jumper-backward)
    (push-mark)
    (let ((s (point))
          (e (progn
               (+amos/smart-jumper-forward)
               (forward-char)
               (point))))
      (evil-range s e type :expanded t))))

(after! xref
  (add-to-list 'xref-prompt-for-identifier '+lookup/definition :append)
  (add-to-list 'xref-prompt-for-identifier '+lookup/references :append)
  (add-to-list 'xref-prompt-for-identifier 'xref-find-references :append))

(defun +amos/lsp-highlight-symbol ()
  (interactive)
  (let ((url (thing-at-point 'url)))
    (if url (goto-address-at-point)
      (let ((inhibit-message t))
        (setq-local +amos--lsp-maybe-highlight-symbol t)
        (lsp--document-highlight)))))

(defun +amos-lsp-remove-highlight-h ()
  (interactive)
  (when (and (boundp '+amos--lsp-maybe-highlight-symbol) +amos--lsp-maybe-highlight-symbol)
    (--each (lsp-workspaces)
      (with-lsp-workspace it
        (lsp--remove-overlays 'lsp-highlight)))
    (setq-local +amos--lsp-maybe-highlight-symbol nil)))

(add-hook 'doom-escape-hook #'+amos-lsp-remove-highlight-h)

(defun +amos-surround-with-pair (c &optional back)
  (let* ((e (save-excursion
              (if back
                  (+amos/backward-word-insert)
                (+amos/forward-word-insert))
              (point)))
         (b (point)))
    (if (< b e)
        (evil-surround-region b e t c)
      (save-excursion
        (evil-surround-region e b t c))
      (forward-char 1))))

(cl-defun +amos-lsp-find-custom (kind method &optional extra &key display-action)
  "Send request named METHOD and get cross references of the symbol under point.
EXTRA is a plist of extra parameters."
  (let ((loc (lsp-request method
                          (append (lsp--text-document-position-params) extra))))
    (if loc
        (+amos-ivy-xref (lsp--locations-to-xref-items (if (sequencep loc) loc (list loc))) kind)
      (message "Not found for: %s" (thing-at-point 'symbol t)))))

(defun +amos/definitions ()
  (interactive)
  (+amos-lsp-find-custom 'definitions "textDocument/definition"))

(defun +amos/references ()
  (interactive)
  (+amos-lsp-find-custom 'references "textDocument/references"))

(defun +amos-lsp--position-to-point-a (params)
  "Convert Position object in PARAMS to a point."
  (save-excursion
    (save-restriction
      (widen)
      (goto-char (point-min))
      ;; We use `goto-char' to ensure that we return a point inside the buffer
      ;; to avoid out of range error
      (goto-char (+ (line-beginning-position (1+ (gethash "line" params)))
                    (gethash "character" params)))
      (point))))

(advice-add #'lsp--position-to-point :override #'+amos-lsp--position-to-point-a)
(advice-add #'lsp-ui-sideline--diagnostics-changed :override #'ignore)

(defun +amos/create-fish-function (name)
  (interactive "sNew function's name: ")
  (let ((full-name (expand-file-name (concat name ".fish") "/home/amos/.config/fish/functions/")))
    (if (file-exists-p full-name)
        (user-error "Function with the same name already exists!"))
    (find-file full-name)
    (evil-initialize-state 'insert)))

(defvar zygospore-spore-formation-register-name
  "zygospore-windows-time-machine"
  "Name of the register that zygospore uses to reverse `zygospore-delete-other-windows'.")

(defvar zygospore-last-full-frame-window
  nil
  "Last window that was full-frame'd.")

(defvar zygospore-last-full-frame-buffer
  nil
  "Last buffer that was full-frame'd.")

(defun zygospore-delete-other-window ()
  "Save current window-buffer configuration and full-frame the current buffer."
  (setq zygospore-last-full-frame-window (selected-window))
  (setq zygospore-last-full-frame-buffer (current-buffer))
  (window-configuration-to-register zygospore-spore-formation-register-name)
  (delete-other-windows))

(defun zygospore-restore-other-windows ()
  "Restore the window configuration to prior to full-framing."
  (jump-to-register zygospore-spore-formation-register-name))

(defun zygospore-toggle-delete-other-windows ()
  "Main zygospore func.
If the current frame has several windows, it will act as `delete-other-windows'.
If the current frame has one window,
  and it is the one that was last full-frame'd,
  and the buffer remained the same,
it will restore the window configuration to prior to full-framing."
  (interactive)
  (if (and (equal (selected-window) (next-window))
           (equal (selected-window) zygospore-last-full-frame-window)
           (equal (current-buffer) zygospore-last-full-frame-buffer))
      (zygospore-restore-other-windows)
    (zygospore-delete-other-window)))

(defun save-buffer-maybe ()
  (interactive)
  ;; (garbage-collect)
  (when (and (buffer-file-name)
             (not defining-kbd-macro)
             (buffer-modified-p))
    (save-buffer))
  nil)

(defun git-gutter-maybe ()
  (interactive)
  (when git-gutter-mode (ignore (call-interactively #'git-gutter)))
  nil)

(add-hook! 'doom-escape-hook #'save-buffer-maybe)
(add-hook! 'doom-escape-hook #'git-gutter-maybe)

(defun my-reload-dir-locals-for-all-buffer-in-this-directory ()
  "For every buffer with the same `default-directory` as the
current buffer's, reload dir-locals."
  (interactive)
  (let ((dir default-directory))
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (when (equal default-directory dir))
        (my-reload-dir-locals-for-current-buffer)))))

(defun my-reload-dir-locals-for-current-buffer ()
  "reload dir locals for the current buffer"
  (interactive)
  (let ((enable-local-variables :all))
    (hack-dir-local-variables-non-file-buffer)))

(add-hook! 'emacs-lisp-mode-hook
  (defun enable-autoreload-for-dir-locals ()
    (when (and (buffer-file-name)
               (equal dir-locals-file
                      (file-name-nondirectory (buffer-file-name))))
      (add-hook! (make-variable-buffer-local 'after-save-hook)
                 #'my-reload-dir-locals-for-all-buffer-in-this-directory))))

(setq tmux-p (getenv "TMUX"))
(setq gui-p (getenv "GUI"))

(unless tmux-p
  (map!
   (:map key-translation-map
     "\033"          (kbd "<escape>"))))

(when tmux-p
  (let ((create-lockfiles t))
    (find-file-noselect "/tmp/emacs.lock")
    (lock-buffer "/tmp/emacs.lock"))
  (advice-add #'switch-to-buffer-other-frame :override #'+amos/switch-to-buffer-other-frame))

(defvar +amos-last-xref-list nil)
(defun +amos/ivy-xref-make-collection (xrefs)
  "Transform XREFS into a collection for display via `ivy-read'."
  (let (collection last-xref-list)
    (dolist (xref xrefs)
      (with-slots (summary location) xref
        (let ((line (xref-location-line location))
              (file (xref-location-group location))
              (candidate nil))
          (setq candidate (concat
                           ;; use file name only
                           (car (reverse (split-string file "\\/")))
                           (when (string= "integer" (type-of line))
                             (concat ":" (int-to-string line) ": "))
                           summary))
          (push `(,candidate . ,location) collection)
          (push (format "%s:%d:%s" (replace-regexp-in-string (concat "^" default-directory) "./" file) line summary) last-xref-list))))
    (setq +amos-last-xref-list (nreverse last-xref-list))
    (nreverse collection)))

(defun +amos-ivy-xref (xrefs kind)
  (if (= 1 (length xrefs))
      (dolist (xref xrefs)
        (with-slots (summary location) xref
          (let* ((marker (xref-location-marker location))
                 (buf (marker-buffer marker)))
            (leap-set-jump)
            (switch-to-buffer buf)
            (goto-char marker))))
    (let ((xref-pos (point))
          (xref-buffer (current-buffer))
          (default-directory (doom-project-root))
          (success nil))
      (ivy-read (concat "Find " (symbol-name kind) ": ") (+amos/ivy-xref-make-collection xrefs)
                :unwind (lambda ()
                          (unless success
                            (switch-to-buffer xref-buffer)
                            (goto-char xref-pos)))
                :action (lambda (x)
                          (let ((location (cdr x)))
                            (let* ((marker (xref-location-marker location))
                                   (buf (marker-buffer marker)))
                              (switch-to-buffer buf)
                              (with-ivy-window
                                (goto-char marker))
                              (unless (eq 'ivy-call this-command)
                                (setq success t)))))
                :caller '+amos-ivy-xref))))

(defun +amos-xref--find-xrefs-a (input kind arg display-action)
  (let ((xrefs (funcall (intern (format "xref-backend-%s" kind))
                        (xref-find-backend)
                        arg)))
    (unless xrefs
      (user-error "No %s found for: %s" (symbol-name kind) input))
    (+amos-ivy-xref xrefs kind)))
(advice-add #'xref--find-xrefs :override #'+amos-xref--find-xrefs-a)

(defun +amos-ivy-xref-show-xrefs-a (xrefs alist)
  (+amos-ivy-xref xrefs 'xref))
(advice-add #'ivy-xref-show-xrefs :override #'+amos-ivy-xref-show-xrefs-a)

(after! recentf
  (setq recentf-exclude '("^/tmp/" "/ssh:" "\\.?ido\\.last$" "\\.revive$" "\\.git" "/TAGS$" "^/var" "^/usr" "~/cc/" "~/Mail/" "~/\\.emacs\\.d/.local/cache")))

(after! ivy
  (setcdr (assq t ivy-format-functions-alist) #'ivy-format-function-line)
  (setf (alist-get t ivy-re-builders-alist) 'ivy--regex-plus)
  (dolist (command '(ccls/includes))
    (setf (alist-get command ivy-re-builders-alist) 'ivy--regex-fuzzy))
  (defun amos-recentf ()
    (interactive)
    (recentf-mode +1)
    (ivy-read "Recentf: " (mapcar #'substring-no-properties recentf-list)
              :action (lambda (f)
                        (with-ivy-window
                          (find-file f)))
              :sort t
              :caller 'counsel-recentf))
  (ivy-set-actions
   'amos-recentf
   '(("j" find-file-other-window "other window")
     ("f" find-file-other-frame "other frame")
     ("x" counsel-find-file-extern "open externally")))

  ;; SLOWWWWW
  ;; (defun amos-recentf-sort-function (a b)
  ;;   (let ((project-root (doom-project-root)))
  ;;     (or (file-in-directory-p a project-root) (not (file-in-directory-p b project-root)))))
  ;; (add-to-list 'ivy-sort-functions-alist '(counsel-recentf . amos-recentf-sort-function))

  (dolist (cmd '(counsel-find-file +amos/counsel-projectile-switch-project))
    (ivy-add-actions
     cmd
     '(("f" find-file-other-frame "other frame"))))
  (dolist (cmd '(ivy-switch-buffer))
    (ivy-add-actions
     cmd
     '(("f" switch-to-buffer-other-frame "other frame")))))

(defun +amos/redisplay-and-recenter (&rest _)
  (interactive)
  (if (> (window-hscroll) 0)
      (evil-scroll-left 10))
  (redraw-display)
  (+amos/recenter))

(defun evil-numbers/inc-at-pt (amount)
  "Increment the number at point or after point before `end-of-line' by AMOUNT."
  (interactive "p*")
  (save-match-data
    (when (evil-numbers/search-number))
    (or
     ;; find binary literals
     (evil-numbers/search-and-replace "0[bB][01]+" "01" "\\([01]+\\)" amount 2)
     ;; find octal literals
     (evil-numbers/search-and-replace "0[oO][0-7]+" "01234567" "\\([0-7]+\\)" amount 8)
     ;; find hex literals
     (evil-numbers/search-and-replace "0[xX][0-9a-fA-F]*"
                                      "0123456789abcdefABCDEF"
                                      "\\([0-9a-fA-F]+\\)" amount 16)
     ;; find decimal literals
     (progn
       (skip-chars-backward "0123456789")
       (skip-chars-backward "-")
       (when (looking-at "-?\\([0-9]+\\)")
         (replace-match
          (format (format "%%0%dd" (- (match-end 1) (match-beginning 1)))
                  (+ amount (string-to-number (match-string 0) 10))))
         ;; Moves point one position back to conform with Vim
         (forward-char -1)
         t)))))

(defun evil-numbers/dec-at-pt (amount)
  "Decrement the number at point or after point before `end-of-line' by AMOUNT."
  (interactive "p*")
  (evil-numbers/inc-at-pt (- amount)))

;;; utils

(defun evil-numbers/search-number ()
  "Return non-nil if a binary, oct, hex or decimal literal at or after point.
If point is already within or after a literal it stays.

The literals have to be in the following forms:
binary: 0[bB][01]+, e.g. 0b101 or 0B0
octal: 0[oO][0-7]+, e.g. 0o42 or 0O5
hexadecimal 0[xX][0-9a-fA-F]+, e.g. 0xBEEF or 0Xcafe
decimal: [0-9]+, e.g. 42 or 23"
  (or
   ;; numbers or format specifier in front
   (looking-back (rx (or (+? digit)
                         (and "0" (or (and (in "bB") (*? (in "01")))
                                      (and (in "oO") (*? (in "0-7")))
                                      (and (in "xX") (*? (in digit "A-Fa-f"))))))))
   ;; search for number in rest of line
   ;; match 0 of specifier or digit, being in a literal and after specifier is
   ;; handled above
   (and
    (re-search-forward "[[:digit:]]" (point-at-eol) t)
    (or
     (not (memq (char-after) '(?b ?B ?o ?O ?x ?X)))
     (/= (char-before) ?0)
     (and (> (point) 2)                 ; Should also take bofp into consideration
          (not (looking-back "\\W0" 2)))
     ;; skip format specifiers and interpret as bool
     (<= 0 (skip-chars-forward "bBoOxX"))))))

(defun evil-numbers/search-and-replace (look-back skip-back search-forward inc base)
  "When looking back at LOOK-BACK skip chars SKIP-BACK backwards and
replace number incremented by INC in BASE and return non-nil."
  (when (looking-back look-back)
    (skip-chars-backward skip-back)
    (search-forward-regexp search-forward)
    (replace-match (evil-numbers/format (+ inc (string-to-number (match-string 1) base))
                                        (length (match-string 1))
                                        base))
    ;; Moves point one position back to conform with Vim
    (forward-char -1)
    t))

(defun evil-numbers/format (num width base)
  "Format NUM with at least WIDTH space in BASE."
  (cond
   ((= base 2) (evil-numbers/format-binary num width))
   ((= base 8) (format (format "%%0%do" width) num))
   ((= base 16) (format (format "%%0%dX" width) num))
   (t "")))

(defun evil-numbers/format-binary (number &optional width fillchar)
  "Format NUMBER as binary.
Fill up to WIDTH with FILLCHAR (defaults to ?0) if binary
representation of `NUMBER' is smaller."
  (let (nums
        (fillchar (or fillchar ?0)))
    (while (> number 0)
      (push (number-to-string (% number 2)) nums)
      (setq number (truncate number 2)))
    (let ((len (length nums)))
      (apply #'concat
             (if (and width (< len width))
                 (make-string (- width len) fillchar)
               "")
             nums))))

(defun +amos/inc (s e &optional inc)
  (save-restriction
    (narrow-to-region s e)
    (goto-char (point-min))
    (if (and (evil-numbers/inc-at-pt +amos--gca-count) inc)
        (setq +amos--gca-count (+ 1 +amos--gca-count)))))

(defvar +amos--gca-count nil)
(defun +amos/gca (count start end)
  (interactive "*p\nr")
  (setq +amos--gca-count count)
  (evil-apply-on-block #'+amos/inc start end nil t))

(defun +amos/ca (count start end)
  (interactive "*p\nr")
  (setq +amos--gca-count count)
  (evil-apply-on-block #'+amos/inc start end nil))

(defun +amos/dec (s e &optional inc)
  (save-restriction
    (narrow-to-region s e)
    (goto-char (point-min))
    (if (and (evil-numbers/dec-at-pt +amos--gcd-count) inc)
        (setq +amos--gcd-count (+ 1 +amos--gcd-count)))))

(defvar +amos--gcd-count nil)
(defun +amos/gcd (count start end)
  (interactive "*p\nr")
  (setq +amos--gcd-count count)
  (evil-apply-on-block #'+amos/dec start end nil t))

(defun +amos/cd (count start end)
  (interactive "*p\nr")
  (setq +amos--gcd-count count)
  (evil-apply-on-block #'+amos/dec start end nil))

(setq +amos-end-of-statement-regex nil)
(defun set-eos! (modes &rest plist)
  (dolist (mode (doom-enlist modes))
    (push (cons mode plist) +amos-end-of-statement-regex)))
(set-eos! '(c-mode c++-mode java-mode perl-mode js2-mode typescript-mode) :regex-char '("[ \t\r\n\v\f]" "[[{(;]" ?\;))
(set-eos! '(sql-mode) :regex-char '("[ \t\r\n\v\f]" ";" ?\;))
(set-eos! '(emacs-lisp-mode) :regex-char "[ \t\r\n\v\f]")

(defun +amos/better-semicolon ()
  (interactive)
  (if (and (eolp) (looking-back ";" 0))
      (funcall-interactively (key-binding (kbd "RET")))
    (insert ";")))

(defun +amos/maybe-add-end-of-statement (&optional move)
  (interactive)
  (if (and move (not (eolp))) (end-of-line)
    (let ((p (save-excursion
               (let (s e)
                 (back-to-indentation)
                 (setq s (point))
                 (end-of-line)
                 (setq e (point))
                 (when-let* ((plist (cdr (assq major-mode +amos-end-of-statement-regex))))
                   (when-let* ((regex-char (doom-enlist (plist-get plist :regex-char))))
                     (if (looking-back (car regex-char))
                         (delete-trailing-whitespace s e)
                       (when-let* ((chars (nth 1 regex-char))
                                   (char (nth 2 regex-char)))
                         (if (looking-back chars 1)
                             (if move (funcall-interactively (key-binding (kbd "RET"))))
                           (insert char))))))
                 (point)))))
      (if move (goto-char p)))))

(defun +amos/insert-eol-and-return (&optional move)
  (interactive)
  (let (s e)
    (end-of-line)
    (back-to-indentation)
    (setq s (point))
    (end-of-line)
    (setq e (point))
    (when-let* ((plist (cdr (assq major-mode +amos-end-of-statement-regex))))
      (when-let* ((regex-char (doom-enlist (plist-get plist :regex-char))))
        (if (looking-back (car regex-char))
            (delete-trailing-whitespace s e)
          (when-let* ((chars (nth 1 regex-char))
                      (char (nth 2 regex-char)))
            (unless (looking-back chars 1)
              (insert char))
            (funcall-interactively (key-binding (kbd "RET")))))))))

(defun +amos/smart-eol-insert ()
  (interactive)
  (+amos/maybe-add-end-of-statement t))

(defun +amos/mark-whole-buffer ()
  (interactive)
  (evil-visual-line (point-min) (point-max)))

(defun +amos/projectile-find-other-file ()
  (interactive)
  (if (and (boundp 'cc-playground-mode) cc-playground-mode)
      (cc-switch-between-src-and-test)
    (projectile-find-other-file)))

(advice-add #'hide-mode-line-mode :override #'ignore)

;; (defun +amos/fcitx--activate-proc ()
;;   (osc-fcitx-activate))

;; (defun +amos/fcitx--deactivate-proc ()
;;   (osc-fcitx-deactivate))

;; there is no easy way to query local info from remote via termio
;; (when tmux-p
;;   (advice-add #'fcitx-check-status :override (lambda () t))
;;   (advice-add #'fcitx--active-p :override #'ignore)
;;   (advice-add #'fcitx--activate-proc :override #'+amos/fcitx--activate-proc)
;;   (advice-add #'fcitx--deactivate-proc :override #'+amos/fcitx--deactivate-proc))

(when gui-p
  (require 'fcitx)
  (fcitx-aggressive-setup))

(defun first-non-dired-buffer ()
  (--first (not (with-current-buffer it (derived-mode-p 'dired-mode))) (buffer-list)))

(setq +popup-default-alist
      '((slot . 1)
        (vslot . -1)
        (side . right)
        (size . 0.5)
        (reusable-frames . nil)))
(map-put +popup-default-parameters 'modeline t)

(set-popup-rules!
  '(("^\\*"  :slot 1 :vslot -1 :select t)
    ("^ \\*" :slot 1 :vslot -1 :size +popup-shrink-to-fit))
  '(("^\\*Completions" :slot -1 :vslot -2 :ttl kill-buffer)
    ("^\\*Warning*" :actions (+popup-display-buffer-stacked-side-window-fn))
    ("^\\*rmsbolt-output*" :side right :size 0.5 :ttl kill-buffer :select nil :quit t)
    ("^\\*git-gutter*" :side right :size 0.5)
    ("^\\*Flycheck" :side bottom :size 0.5 :select t :ttl kill-buffer :quit t)
    ("^\\*Compil\\(?:ation\\|e-Log\\)" :side right :size 0.5 :select t :ttl kill-buffer :quit t)
    ("^\\*temp\\*" :side right :size 0.5 :select t :ttl kill-buffer :quit t)
    ("^\\*\\(?:scratch\\|Messages\\)" :autosave t :ttl nil)
    ("^\\*Man " :size 0.45 :vslot -6 :ttl kill-buffer :quit t :select t)
    ("^\\*doom \\(?:term\\|eshell\\)" :size 0.25 :vslot -10 :select t :quit nil :ttl kill-buffer)
    ("^\\*doom:" :vslot -20 :size 0.35 :autosave t :select t :modeline t :quit nil)
    ("^\\*\\(?:\\(?:Pp E\\|doom e\\)val\\)" :size +popup-shrink-to-fit :side right :ttl kill-buffer :select ignore)
    ("^\\*Customize" :ignore t)
    ("^amos-compress-view" :ignore t)
    ("^ \\*undo-tree\\*" :slot 2 :side left :size 20 :select t :ttl kill-buffer :quit t)
    ;; `help-mode', `helpful-mode'
    ("^\\*[Hh]elp" :side right :size 0.5 :ttl kill-buffer :select t)
    ;; `Info-mode'
    ("^\\*info\\*$" :slot 2 :vslot 2 :size 0.45 :ttl kill-buffer :select t)
    ("\\*TeX" :side right :size 0.4 :ttl kill-buffer)
    ("^\\(?:\\*magit\\|magit:\\)" :ignore t)
    ("\\[ Table \\]\\*" :side right :size 0.9 :select t :quit nil))
  '(("^\\*Backtrace" :side right :size 0.5 :quit nil)))

(evil-define-command +amos-evil-visual-paste-a (count &optional register)
  "Paste over Visual selection."
  :suppress-operator t
  (interactive "P<x>")
  ;; evil-visual-paste is typically called from evil-paste-before or
  ;; evil-paste-after, but we have to mark that the paste was from
  ;; visual state
  (setq this-command 'evil-visual-paste)
  (let* ((text (if register
                   (evil-get-register register)
                 (current-kill 0)))
         (yank-handler (car-safe (get-text-property
                                  0 'yank-handler text)))
         new-kill
         paste-eob)
    (evil-with-undo
      (let* ((kill-ring (list (current-kill 0)))
             (kill-ring-yank-pointer kill-ring))
        (when (evil-visual-state-p)
          (evil-visual-rotate 'upper-left)
          ;; if we replace the last buffer line that does not end in a
          ;; newline, we use `evil-paste-after' because `evil-delete'
          ;; will move point to the line above
          (when (and (= evil-visual-end (point-max))
                     (/= (char-before (point-max)) ?\n))
            (setq paste-eob t))
          (evil-delete evil-visual-beginning evil-visual-end
                       (evil-visual-type) ?_)
          (when (and (eq yank-handler #'evil-yank-line-handler)
                     (not (eq (evil-visual-type) 'line))
                     (not (= evil-visual-end (point-max))))
            (insert "\n"))
          (evil-normal-state)
          (setq new-kill (current-kill 0))
          (current-kill 1))
        (if paste-eob
            (evil-paste-after count register)
          (evil-paste-before count register)))
      (when evil-kill-on-visual-paste
        (kill-new new-kill))
      ;; mark the last paste as visual-paste
      (setq evil-last-paste
            (list (nth 0 evil-last-paste)
                  (nth 1 evil-last-paste)
                  (nth 2 evil-last-paste)
                  (nth 3 evil-last-paste)
                  (nth 4 evil-last-paste)
                  t)))))
(advice-add #'evil-visual-paste :override #'+amos-evil-visual-paste-a)

(defvar leaped nil)
(defun +amos-+lookup--jump-to-a (prop identifier &optional display-fn arg)
  (let* (leaped
         (origin (point-marker))
         (handlers (plist-get (list :definition '+lookup-definition-functions
                                    :references '+lookup-references-functions
                                    :documentation '+lookup-documentation-functions
                                    :file '+lookup-file-functions)
                              prop))
         (result
          (if arg
              (if-let*
                  ((handler (intern-soft
                             (completing-read "Select lookup handler: "
                                              (remq t (append (symbol-value handlers)
                                                              (default-value handlers)))
                                              nil t))))
                  (+lookup--run-handlers handler identifier origin)
                (user-error "No lookup handler selected"))
            (run-hook-wrapped handlers #'+lookup--run-handlers identifier origin))))
    (when (cond ((null result)
                 (message "No lookup handler could find %S" identifier)
                 nil)
                ((markerp result)
                 (funcall (or display-fn #'switch-to-buffer)
                          (marker-buffer result))
                 (goto-char result)
                 result)
                (result))
      (unless (or leaped (null result))
        (with-current-buffer (marker-buffer origin)
          (leap-set-jump (marker-position origin)))
        (run-hooks 'leap-post-jump-hook))
      result)))
(advice-add #'+lookup--jump-to :override #'+amos-+lookup--jump-to-a)

(defvar is-swiper-occur nil)
(defun +amos-set-jump-point-maybe-a ()
  (unless is-swiper-occur
    (with-demoted-errors "Error: %S"
      (when (and
             (markerp +amos-ivy--origin)
             (marker-buffer +amos-ivy--origin)
             (eq ivy-exit 'done)
             (not (equal (with-ivy-window (point-marker)) +amos-ivy--origin)))
        (with-ivy-window
          (with-current-buffer (marker-buffer +amos-ivy--origin)
            (leap-set-jump +amos-ivy--origin))
          (run-hooks 'leap-post-jump-hook))
        (setq +amos-ivy--origin nil
              leaped t))
      (unless (or ivy-exit ivy-recursive-last)
        (with-ivy-window
          (run-hooks 'leap-post-jump-hook)))))
  (setq is-swiper-occur nil))
(advice-add #'ivy-call :after #'+amos-set-jump-point-maybe-a)

(defun +amos|record-position-maybe ()
  (with-ivy-window
    (setq +amos-ivy--origin (point-marker))))

(after! ivy
  (setq ivy-hooks-alist '((t . +amos|record-position-maybe))))

(advice-add #'better-jumper-jump-forward :override #'leap-jump-forward)
(advice-add #'better-jumper-jump-backward :override #'leap-jump-backward)
(advice-add #'better-jumper-set-jump :override #'ignore)
(advice-add #'doom-set-jump-a :override #'ignore)
(advice-add #'doom-set-jump-h :override #'ignore)
(advice-add #'doom-recenter-a :override #'ignore)
(dolist (fn '(evil-visualstar/begin-search-forward
              evil-visualstar/begin-search-backward
              evil-ex-search-word-backward
              evil-ex-search-word-backward
              evil-ex-search-forward
              evil-ex-search-backward))
  (advice-remove fn #'doom-recenter-a))

(advice-add #'elisp-def--flash-region :override #'ignore)
;; (ad-disable-advice 'switch-to-buffer 'before 'evil-jumps)
;; (ad-activate 'switch-to-buffer)  ;; stupid api
(add-hook 'leap-post-jump-hook #'+amos/recenter)

(defun +amos-leap-jump-h (&optional command)
  "Set jump point if COMMAND has a non-nil :jump property."
  (setq command (or command this-command))
  (when (evil-get-command-property command :jump)
    (leap-set-jump)))
(add-hook 'pre-command-hook #'+amos-leap-jump-h)

(defun +amos/yank-buffer-filename ()
  "Copy the current buffer's path to the kill ring."
  (interactive)
  (if-let* ((filename (or buffer-file-name (bound-and-true-p list-buffers-directory))))
      (message (kill-new (abbreviate-file-name filename)))
    (error "Couldn't find filename in current buffer")))

(defun +amos/yank-buffer-filename-nondir ()
  "Copy the current buffer's filename to the kill ring."
  (interactive)
  (if-let* ((filename (or buffer-file-name (bound-and-true-p list-buffers-directory))))
      (message (kill-new (file-name-nondirectory filename)))
    (error "Couldn't find filename in current buffer")))

(defun +amos/yank-buffer-filename-with-line-position ()
  "Copy the current buffer's filename with line number to the kill ring."
  (interactive)
  (if-let* ((filename (or buffer-file-name (bound-and-true-p list-buffers-directory))))
      (message (kill-new (concat filename ":" (number-to-string (line-number-at-pos)) "\n")))
    (error "Couldn't find filename in current buffer")))

(defun +amos/evil-insert-line-above (count)
  "Insert one or several lines above the current point's line without changing
the current state and point position."
  (interactive "p")
  (dotimes (_ count) (save-excursion (evil-insert-newline-above))))

(defun +amos/evil-insert-line-below (count)
  "Insert one or several lines below the current point's line without changing
the current state and point position."
  (interactive "p")
  (dotimes (_ count) (save-excursion (evil-insert-newline-below))))

(defun +amos/copy-without-useless-indent-and-newline ()
  (interactive)
  (let ((inhibit-message t))
    (when (evil-visual-state-p)
      (call-interactively #'narrow-reindent-to-region)
      (set-mark (point-min))
      (goto-char (point-max))
      (backward-char)
      (end-of-line)
      (call-interactively #'copy-region-as-kill)
      (narrow-reindent-widen)
      (+amos/recenter))))

(defun +amos/evil-visual-insert-snippet ()
  (interactive)
  (let ((start (region-beginning))
        (end (region-end))
        (register 121))
    (setq yas--condition-cache-timestamp (current-time))
    (let* ((yas-wrap-around-region register)
           (templates (yas--all-templates (yas--get-snippet-tables)))
           (yas--current-template (and templates
                                       (or (and (cl-rest templates) ;; more than one template for same key
                                                (yas--prompt-for-template templates))
                                           (car templates))))
           (_ (evil-substitute start end 'line register))
           (where (cons (point) (point))))
      (with-temp-buffer
        (evil-paste-from-register register)
        (indent-region (point-min) (point-max))
        (goto-char (point-max))
        (backward-char)
        (end-of-line)
        (let ((text (filter-buffer-substring (point-min) (point))))
          (evil-set-register ?y text)))
      (if yas--current-template
          (progn
            (yas-expand-snippet (yas--template-content yas--current-template)
                                (car where)
                                (cdr where)
                                (yas--template-expand-env yas--current-template)))
        (yas--message 1 "No snippets can be inserted here!")))))

(defun async-shell-command! (command)
  (let ((inhibit-message t))
    (call-process-shell-command command nil 0)))

(defun shell-command! (command &optional out-buffer err-buffer)
  (let ((inhibit-message t))
    (shell-command command out-buffer err-buffer)))

(defun +amos/tmux-detach ()
  "Detach if inside tmux."
  (interactive)
  (shell-command! "tmux detach-client"))

(defun +amos/find-file-other-frame (filename &optional wildcards)
  "Open file if inside tmux."
  (interactive
   (find-file-read-args "Find file in other frame: "
                        (confirm-nonexistent-file-or-buffer)))
  (+amos/workspace-new)
  (find-file filename wildcards))

(defun +amos/switch-to-buffer-other-frame (buffer-or-name &optional norecord)
  (interactive
   (list (read-buffer-to-switch "Switch to buffer in other frame: ")))
  (+amos/workspace-new)
  (switch-to-buffer buffer-or-name norecord))

(defun +amos/workspace-new-scratch ()
  (interactive)
  (+amos/switch-to-buffer-other-frame "*scratch"))

(defun +amos/tmux-fork-window (&optional command)
  "Detach if inside tmux."
  (interactive)
  (+amos-store-jump-history)
  (if command
      (shell-command! (format-spec "tmux switch-client -t amos; tmuxkillwindow amos:%a; tmux run -t amos \"tmux new-window -n %a -c %b; tmux send-keys %c C-m\"" `((?a . ,(getenv "envprompt")) (?b . ,default-directory) (?c . ,command))))
    (shell-command! (format "tmux switch-client -t amos; tmux run -t amos \"tmux new-window -c %s\"" default-directory))))

(defun +amos/tmux-source ()
  "Source tmux config if inside tmux."
  (interactive)
  (shell-command! "tmux source-file ~/.tmux/.tmux.conf.emacs"))

(defun +amos/prompt-kill-emacs ()
  "Prompt to save changed buffers and exit Spacemacs"
  (interactive)
  (save-some-buffers nil t)
  (kill-emacs))

(defun comp-buffer-name (maj-mode)
  (concat "*" (downcase maj-mode) " " default-directory "*"))
(setq compilation-buffer-name-function #'comp-buffer-name)
(defun +amos-normalize-compilation-buffer-h (buffer msg)
  (with-current-buffer buffer
    (evil-normal-state)))
(add-hook! 'compilation-finish-functions #'+amos-normalize-compilation-buffer-h)

(defvar +amos-frame-list nil)
(defvar +amos-frame-stack nil)
(defvar +amos-tmux-need-switch nil)

(defun +amos/set-face ()
  (after! swiper
    (set-face-attribute 'swiper-line-face nil :inherit 'unspecified :background 'unspecified :foreground 'unspecified :underline t))
  (after! ivy
    (set-face-attribute 'ivy-current-match nil :inherit 'unspecified :distant-foreground 'unspecified
                        :weight 'unspecified :background 'unspecified :foreground 'unspecified :underline t))
  (after! xref
    (set-face-attribute 'xref-match nil :inherit 'unspecified :distant-foreground 'unspecified
                        :weight 'unspecified :background 'unspecified :foreground 'unspecified :weight 'ultra-bold))
  (set-face-background 'vertical-border 'unspecified)
  (set-face-attribute 'mode-line-inactive nil :inherit 'mode-line :background nil :foreground nil))

;; vertical bar
(add-hook! 'doom-load-theme-hook #'+amos/set-face)

(defun +amos-after-make-frame-functions-h (&rest _)
  (+amos/set-face)
  (unless +amos-frame-list
    (setq +amos-frame-list (+amos--frame-list-without-daemon))))
(add-hook! 'after-make-frame-functions #'+amos-after-make-frame-functions-h)

(defun +amos--is-frame-daemons-frame (f)
  (and (daemonp) (eq f terminal-frame)))
(defun +amos--frame-list-without-daemon ()
  (if (daemonp)
      (filtered-frame-list (lambda (f) (not (+amos--is-frame-daemons-frame f))))
    (frame-list)))

(defun +amos/workspace-new ()
  (interactive)
  (if gui-p (setenv "DISPLAY" ":0"))
  (let ((name (frame-parameter nil 'name))
        (oframe (selected-frame))
        (nframe))
    (make-frame-invisible oframe t)
    (setq nframe (if (s-starts-with? "F" name)
                     (make-frame)
                   (make-frame `((name . ,name)))))
    (select-frame nframe)
    (let ((dir default-directory))
      (switch-to-buffer "*scratch*")
      (cd dir))
    (push nframe +amos-frame-stack)
    (setq +amos-frame-list
          (-insert-at (1+ (-elem-index oframe +amos-frame-list)) nframe +amos-frame-list))))

(defun +amos/workspace-delete ()
  (interactive)
  (let ((f (selected-frame)))
    (setq +amos-frame-list (--remove (eq f it) +amos-frame-list))
    (setq +amos-frame-stack (-uniq (--remove (eq f it) +amos-frame-stack)))
    (if +amos-frame-stack
        (+amos/workspace-switch-to-frame (car +amos-frame-stack)))
    (delete-frame f))
  (when +amos-tmux-need-switch
    (shell-command! "tmux switch-client -t amos\; run-shell -t amos '/home/amos/scripts/setcursor.sh $(tmux display -p \"#{pane_tty}\")'")
    (setq +amos-tmux-need-switch nil)))

(defun +amos/workspace-switch-to-frame (frame)
  (setq +amos-tmux-need-switch nil)
  (let ((oframe (selected-frame)))
    (make-frame-invisible oframe t)
    (select-frame frame)
    (raise-frame frame)
    (push frame +amos-frame-stack)
    (+amos/reset-cursor)
    (recenter)))

(defun +amos/workspace-switch-to (index)
  (interactive)
  (when (< index (length +amos-frame-list))
    (let ((frame (nth index +amos-frame-list)))
      (+amos/workspace-switch-to-frame frame))))

(defun +amos/workspace-switch-to-1 () (interactive) (+amos/workspace-switch-to 0))
(defun +amos/workspace-switch-to-2 () (interactive) (+amos/workspace-switch-to 1))
(defun +amos/workspace-switch-to-3 () (interactive) (+amos/workspace-switch-to 2))
(defun +amos/workspace-switch-to-4 () (interactive) (+amos/workspace-switch-to 3))
(defun +amos/workspace-switch-to-5 () (interactive) (+amos/workspace-switch-to 4))
(defun +amos/workspace-switch-to-6 () (interactive) (+amos/workspace-switch-to 5))
(defun +amos/workspace-switch-to-7 () (interactive) (+amos/workspace-switch-to 6))
(defun +amos/workspace-switch-to-8 () (interactive) (+amos/workspace-switch-to 7))
(defun +amos/workspace-switch-to-9 () (interactive) (+amos/workspace-switch-to 8))
(defun +amos-workspace-cycle (off)
  (let* ((n (length +amos-frame-list))
         (index (-elem-index (selected-frame) +amos-frame-list))
         (i (% (+ off index n) n)))
    (+amos/workspace-switch-to i)))
(defun +amos/workspace-switch-left ()  (interactive) (+amos-workspace-cycle -1))
(defun +amos/workspace-switch-right () (interactive) (+amos-workspace-cycle +1))

(defun +amos|maybe-delete-frame-buffer (frame)
  (let ((windows (window-list frame)))
    (dolist (window windows)
      (let ((buffer (window-buffer (car windows))))
        (when (eq 1 (length (get-buffer-window-list buffer nil t)))
          (kill-buffer buffer))))))
(add-to-list 'delete-frame-functions #'+amos|maybe-delete-frame-buffer)

(defun +amos-flycheck-next-error-function-a (n reset)
  (-if-let* ((pos (flycheck-next-error-pos n reset))
             (err (get-char-property pos 'flycheck-error))
             (filename (flycheck-error-filename err))
             (dummy (string= buffer-file-name filename)))
      (progn
        (leap-set-jump)
        (flycheck-jump-to-error err))
    (user-error "No more Flycheck errors")))
(advice-add #'flycheck-next-error-function :override #'+amos-flycheck-next-error-function-a)

;; only reuse current frame's popup
(defadvice +popup-display-buffer (around +amos*popup-display-buffer activate)
  (doom-with-advice (get-window-with-predicate (lambda (orig-fun f &rest _) (funcall orig-fun f)))
      ad-do-it))

(after! dired-x
  (setq dired-omit-files
        (concat dired-omit-files "\\|\\.directory$"))
  (add-hook! 'dired-mode-hook
    (let ((inhibit-message t))
      (toggle-truncate-lines +1)
      ;; (dired-omit-mode) ;; .d folders are gone
      (+amos-store-jump-history))))

(define-advice dired-revert (:after (&rest _) +amos*dired-revert)
  "Call `recenter' after `dired-revert'."
  (with-demoted-errors "Errors: %S" (+amos/recenter)))

(after! wdired
  (evil-set-initial-state 'wdired-mode 'normal))

(defun +amos/dired-open-callgrind ()
  "Open callgrind files according to its name."
  (interactive)
  (let ((file (ignore-errors (dired-get-file-for-visit)))
        process)
    (when (and file
               (not (file-directory-p file)))
      (when (string-match-p "$[cachegrind|callgrind].out" file)
        (setq process (dired-open--start-process file "kcachegrind"))))
    process))

(defadvice dired-clean-up-after-deletion (around +amos*dired-clean-up-after-deletion activate)
  (doom-with-advice (y-or-n-p (lambda (&rest _) t))
      ad-do-it))

(after! evil-snipe
  (push 'dired-mode evil-snipe-disabled-modes)
  )

;; fix constructor list
(defun +amos*c-determine-limit (orig-fun &rest args)
  (setf (car args) 5000)
  (apply orig-fun args))
(advice-add #'c-determine-limit :around #'+amos*c-determine-limit)

(evil-define-state lisp
  "Lisp state.
 Used to navigate lisp code and manipulate the sexp tree."
  :tag " <L> "
  :cursor (bar . 2)
  ;; force smartparens mode
  (if (evil-lisp-state-p) (smartparens-mode)))

(set-keymap-parent evil-lisp-state-map evil-insert-state-map)

(general-define-key
 :states 'lisp
 "<escape>"       (lambda! (evil-normal-state) (unless (bolp) (backward-char)))
 "M-o"            #'lisp-state-toggle-lisp-state
 "M-U"            #'+amos/replace-defun
 "M-u"            #'eval-defun
 "C-a"            #'sp-beginning-of-sexp
 "C-e"            #'sp-end-of-sexp
 "C-n"            #'sp-down-sexp
 "C-p"            #'sp-up-sexp
 "M-n"            #'sp-backward-down-sexp
 "M-p"            #'sp-backward-up-sexp
 "M-f"            #'sp-forward-sexp
 "M-b"            #'sp-backward-sexp
 "M-,"            #'sp-backward-unwrap-sexp
 "M-."            #'sp-unwrap-sexp
 "M-r"            #'sp-forward-slurp-sexp
 "M-R"            #'sp-forward-barf-sexp
 "M-s"            #'sp-splice-sexp
 "M-t"            #'sp-transpose-sexp
 "C-t"            #'sp-transpose-hybrid-sexp
 "M-d"            #'sp-kill-sexp
 "C-o"            #'sp-kill-hybrid-sexp
 [M-backspace]    #'sp-backward-kill-sexp
 [134217855]      #'sp-backward-kill-sexp ; M-DEL
 "M-w"            #'sp-copy-sexp
 "M-("            #'sp-wrap-round
 "M-{"            #'sp-wrap-curly
 "M-["            #'sp-wrap-square
 "M-\""           (lambda! (sp-wrap-with-pair "\"")))

(defun lisp-state-toggle-lisp-state ()
  "Toggle the lisp state."
  (interactive)
  (if (eq 'lisp evil-state)
      (progn
        (message "state: lisp -> insert")
        (evil-insert-state))
    (message "state: %s -> lisp" evil-state)
    (evil-lisp-state)))

(defun lisp-state-wrap (&optional arg)
  "Wrap a symbol with parenthesis."
  (interactive "P")
  (sp-wrap-with-pair "("))

(defun evil-lisp-state-next-paren (&optional closing)
  "Go to the next/previous closing/opening parenthesis/bracket/brace."
  (if closing
      (let ((curr (point)))
        (forward-char)
        (unless (eq curr (search-forward-regexp "[])}]"))
          (backward-char)))
    (search-backward-regexp "[[({]")))

(defun lisp-state-prev-opening-paren ()
  "Go to the next closing parenthesis."
  (interactive)
  (evil-lisp-state-next-paren))

(defun lisp-state-next-closing-paren ()
  "Go to the next closing parenthesis."
  (interactive)
  (evil-lisp-state-next-paren 'closing))

(defun lisp-state-forward-symbol (&optional arg)
  "Go to the beginning of the next symbol."
  (interactive "P")
  (let ((n (if (char-equal (char-after) ?\() 1 2)))
    (sp-forward-symbol (+ (if arg arg 0) n))
    (sp-backward-symbol)))

(defun lisp-state-insert-sexp-after ()
  "Insert sexp after the current one."
  (interactive)
  (let ((sp-navigate-consider-symbols nil))
    (if (char-equal (char-after) ?\() (forward-char))
    (sp-up-sexp)
    (evil-insert-state)
    (sp-newline)
    (sp-insert-pair "(")))

(defun lisp-state-insert-sexp-before ()
  "Insert sexp before the current one."
  (interactive)
  (let ((sp-navigate-consider-symbols nil))
    (if (char-equal (char-after) ?\() (forward-char))
    (sp-backward-sexp)
    (evil-insert-state)
    (sp-newline)
    (evil-previous-visual-line)
    (evil-end-of-line)
    (insert " ")
    (sp-insert-pair "(")
    (indent-for-tab-command)))

(defun lisp-state-eval-sexp-end-of-line ()
  "Evaluate the last sexp at the end of the current line."
  (interactive)
  (save-excursion
    (end-of-line)
    (eval-last-sexp nil)))

(defun lisp-state-beginning-of-sexp (&optional arg)
  "Go to the beginning of current s-exp"
  (interactive "P")
  (sp-beginning-of-sexp)
  (evil-backward-char))

(after! iedit
  (add-hook! 'iedit-mode-end-hook (+amos/recenter) (setq iedit-unmatched-lines-invisible nil)))

(after! magit
  ;; (magit-auto-revert-mode +1)
  (setq
   magit-refresh-status-buffer nil
   magit-display-buffer-function 'magit-display-buffer-fullframe-status-topleft-v1
   magit-display-buffer-noselect nil
   magit-repository-directories '(("~/git" . 2))
   magit-revision-show-gravatars '("^Author:     " . "^Commit:     "))
  (defun +amos*remove-git-index-lock (&rest _)
    (ignore-errors
      (delete-file ".git/index.lock")))
  (advice-add #'magit-refresh :before #'+amos*remove-git-index-lock))

(after! evil-magit
  (setq evil-magit-use-z-for-folds nil))

(after! org
  (setq org-image-actual-width '(400)))

(after! recentf
  (setq recentf-max-saved-items 10000))

(defun +amos-flycheck-inline-display-errors-a (ofun &rest candidate)
  (if (or (memq this-command '(+amos/flycheck-previous-error
                               +amos/flycheck-next-error
                               flycheck-previous-error
                               flycheck-next-error
                               +amos/yank-flycheck-error))
          (eq last-input-event 29))
      (apply ofun candidate)))
(advice-add #'flycheck-inline-display-errors :around #'+amos-flycheck-inline-display-errors-a)
(advice-add #'evil-multiedit--cycle :after #'+amos/recenter)
(advice-add #'wgrep-abort-changes :after #'kill-buffer)
(advice-add #'wgrep-finish-edit :after #'kill-buffer)
(advice-remove #'wgrep-abort-changes #'+popup-close-a)
(advice-remove #'wgrep-finish-edit #'+popup-close-a)
(advice-add #'evil-multiedit-match-and-next :after #'+amos/recenter)
(advice-add #'edebug-overlay-arrow :after #'realign-windows)

(evil-define-motion +amos/evil-goto-line (count)
  "Go to the first non-blank character of line COUNT.
By default the last line."
  :jump t
  :type line
  (if (null count)
      (with-no-warnings (end-of-buffer))
    (goto-char (point-min))
    (forward-line (1- count)))
  (evil-first-non-blank)
  (+amos/recenter))

(defun +amos/company-abort ()
  (interactive)
  (if company-selection-changed
      (+amos/company-search-abort)
    (company-abort)
    (evil-normal-state)
    (cl-decf evil-repeat-pos)))

(defun +amos/company-search-abort ()
  (interactive)
  (if company-selection-changed
      (progn
        (advice-add 'company-call-backend :before-until 'company-tng--supress-post-completion)
        (company-complete-selection))
    (company-abort))
  (evil-normal-state)
  (cl-decf evil-repeat-pos))

(defun +amos/close-block ()
  (interactive)
  (evil-with-state 'insert
    (syntactic-close)))

;; TODO useless?
(defun +amos-get-buffer-by-name (name)
  (cl-loop for buffer in (buffer-list)
           if (or (get-file-buffer name)
                  (string= (buffer-name buffer) name))
           collect buffer))

(advice-add #'evil--jumps-savehist-load :override #'ignore)
(defun +amos-clean-evil-jump-list (&optional buffer)
  (let* ((ring (make-ring evil-jumps-max-length))
         (jump-struct (evil--jumps-get-current))
         (idx (evil-jumps-struct-idx jump-struct))
         (target-list (evil-jumps-struct-ring jump-struct))
         (size (ring-length target-list))
         (i 0))
    (when target-list
      (cl-loop for target in (ring-elements target-list)
               do (let* ((marker (car target))
                         (file-name (cadr target)))
                    (if (or (not (markerp marker))
                            (not (marker-buffer marker))
                            (and buffer
                                 (string= file-name (or buffer-file-name (buffer-name buffer)))))
                        (if (<= i idx) (setq idx (- idx 1)))
                      ;; else
                      (ring-insert-at-beginning ring target)
                      (setq i (+ i 1)))))
      (setf (evil-jumps-struct-ring jump-struct) ring)
      (setf (evil-jumps-struct-idx jump-struct) idx))))

(defun +amos/close-current-buffer (&optional wipe kill)
  (interactive)
  (if wipe
      (+amos-clean-evil-jump-list (current-buffer)))
  (if kill (kill-buffer) (bury-buffer)))

(defun +amos-undo-tree-a (ofun &rest arg)
  (if (and (not defining-kbd-macro)
           (not executing-kbd-macro))
      (if (not (memq major-mode '(c-mode c++-mode)))
          (apply ofun arg)
        ;; (+amos|iedit-setup-hooks)
        (apply ofun arg)
        ;; (+amos|iedit-mode-end-hook)
        )
    (message "cannot use undo when recording/executing a macro!")))
(advice-add #'undo-tree-undo :around #'+amos-undo-tree-a)
(advice-add #'undo-tree-redo :around #'+amos-undo-tree-a)

(add-hook! 'eval-expression-minibuffer-setup-hook
  (define-key minibuffer-local-map "\C-p" #'previous-line-or-history-element)
  (define-key minibuffer-local-map "\C-n" #'next-line-or-history-element))

(add-hook! 'minibuffer-setup-hook
  (buffer-disable-undo)
  (setq-local truncate-lines t)
  (setq-local inhibit-message t))

(advice-add #'window-adjust-process-window-size-smallest :override #'ignore)
(advice-add #'set-process-window-size :override #'ignore)
(advice-add #'evil-escape-mode :override #'ignore)
(advice-add #'dired-k--highlight-by-file-attribyte :override #'ignore)
(advice-add #'recenter-top-bottom :override #'recenter)
(advice-add #'git-gutter:next-hunk :after (lambda (arg) (recenter)))
(advice-add #'magit-blame--update-margin :override #'ignore)
(advice-add #'evil-visual-update-x-selection :override #'ignore)

(defun +amos-magit-blob-next-a ()
  "Visit the next blob which modified the current file."
  (interactive)
  (if-let ((file (and magit-buffer-file-name (magit-blob-successor magit-buffer-revision magit-buffer-file-name))))
      (magit-blob-visit file)
    (user-error "You have reached the previous end of time")))
(advice-add #'magit-blob-next :override #'+amos-magit-blob-next-a)

(defun +amos/avy-goto-url()
  "Use avy to go to an URL in the buffer."
  (interactive)
  (require 'avy)
  (avy-jump "https?://" :window-flip nil :beg nil :end nil :action #'goto-char))

(defun +amos/avy-open-url ()
  "Use avy to select an URL in the buffer and open it."
  (interactive)
  (require 'avy)
  (avy-jump "https?://" :window-flip nil :beg nil :end nil :action (lambda (p) (save-excursion (goto-char p) (browse-url-at-point)))))

(defun +amos/avy-goto-char-timer (&optional arg)
  "Read one or many consecutive chars and jump to the first one.
The window scope is determined by `avy-all-windows' (ARG negates it)."
  (interactive "P")
  (require 'avy)
  (let (block)
    (when (eq 'block evil-visual-selection)
      (evil-visual-char)
      (setq block t))
    (let ((avy-all-windows (if arg
                               (not avy-all-windows)
                             avy-all-windows)))
      (avy-with avy-goto-char-timer
                (avy--process
                 (avy--read-candidates)
                 (avy--style-fn avy-style))))
    (if block (evil-visual-block))))
;; (evil-define-avy-motion +amos/avy-goto-char-timer inclusive)

(defun lua-busted-fuckups-fix ()
  (save-excursion
    (lua-forward-line-skip-blanks 'back)
    (let* ((current-indentation (current-indentation))
           (line (thing-at-point 'line t))
           (busted-p (s-matches?
                      (rx (+ bol (* space)
                             (or "context" "describe" "it" "setup" "teardown")
                             "("))
                      line)))
      (when busted-p
        (+ current-indentation lua-indent-level)))))
(defun +amos*lua-calculate-indentation-override (old-function &rest arguments)
  (or (lua-busted-fuckups-fix)
      (apply old-function arguments)))
(advice-add #'lua-calculate-indentation-override :around #'+amos*lua-calculate-indentation-override)

(defun lua-find-matching-token-in-line (found-token found-pos token-type &optional direction)
  (let ((line (line-number-at-pos))
        ;; If we are on a middle token, go backwards. If it is a middle-or-open,
        ;; go forwards.
        (search-direction
         (or direction
             (if (or (eq token-type 'open)
                     (eq token-type 'middle-or-open))
                 'forward
               'backward)
             'backward)))
    (save-excursion
      ;; This is required since lua-find-matching-token-word needs point to be
      ;; at the beginning of the keyword.
      (goto-char found-pos)
      (let ((found-match (lua-find-matching-token-word found-token search-direction)))
        (when (and found-match (= line (line-number-at-pos)))
          (point))))))

(defun lua-resolve-token-type (found-token found-pos)
  "Get resolved token type.
 If token type is 'middle-or-open, determine which one it is and
 return it."
  (save-excursion
    (let ((token-type (lua-get-token-type (lua-get-block-token-info found-token))))
      (if (not (eq token-type 'middle-or-open))
          token-type
        (goto-char found-pos)
        (if (not (lua-find-matching-token-word found-token 'backward))
            'open
          'middle)))))

(defun lua-line-indent-impact-current (&optional bound)
  "Calculate how much current line impacts indentation of current line.
 `bound' is set to `line-end-position' by default."
  ;; TODO: Optimization idea: sum all closers and matched-in-line openers until
  ;; an unmatched-in-line opener is met.
  (unless bound
    (setq bound (line-end-position)))
  (save-excursion
    (back-to-indentation)
    ;; Check first token.
    (if (or (lua-comment-or-string-p)
            (not (looking-at lua-indentation-modifier-regexp)))
        0
      (let ((token-type (lua-resolve-token-type (match-string 0) (match-beginning 0))))
        (cond
         ((eq token-type 'middle)
          (- lua-indent-level))
         ((eq token-type 'close)
          ;; Loop over all tokens in line.
          (back-to-indentation)
          (let ((shift 0))
            (while (lua-find-regexp 'forward lua-indentation-modifier-regexp bound)
              (let ((found-token (match-string 0))
                    (found-pos (match-beginning 0)))
                (setq token-type (lua-resolve-token-type found-token found-pos))
                ;; Only if 'close and unmatched.
                (when (and (eq token-type 'close)
                           (not (lua-find-matching-token-in-line found-token found-pos token-type)))
                  (setq shift (- shift lua-indent-level)))))
            (max -4 shift)))
         (t 0))))))

(defun lua-line-indent-impact-next (&optional bound)
  "Calculate how much current line impacts indentation of next line.
 `bound' is set to `line-end-position' by default."
  (unless bound
    (setq bound (line-end-position)))
  (save-excursion
    (back-to-indentation)
    (let ((shift 0)
          (add 0)
          (first-token-type)
          (token-type))
      ;; Shift if first token is 'middle.
      (when (and (not (lua-comment-or-string-p))
                 (looking-at lua-indentation-modifier-regexp)
                 (eq 'middle (setq first-token-type (lua-resolve-token-type (match-string 0) (match-beginning 0)))))
        (setq shift (+ shift lua-indent-level)))
      ;; Loop over all tokens in line.
      (while (lua-find-regexp 'forward lua-indentation-modifier-regexp bound)
        (let ((found-token (match-string 0))
              (found-pos (match-beginning 0)))
          (setq token-type (lua-resolve-token-type found-token found-pos))
          ;; Only if unmatched 'open and unmatched 'close if first token was not
          ;; 'close.
          (unless (lua-find-matching-token-in-line found-token found-pos token-type)
            (cond
             ((eq token-type 'open)
              (setq add (+ add lua-indent-level)))
             ((and (eq token-type 'close) (not (eq first-token-type 'close)))
              (setq add (- add lua-indent-level)))
             (t 0)))))
      (+ shift (min lua-indent-level add)))))

(defun +amos-lua-calculate-indentation-a (&optional parse-start)
  "Return appropriate indentation for current line as Lua code."
  ;; Algorithm: indentation is computed from current line and previous line.
  ;; Current line:
  ;; -1 on every unmatched closer if first token is a closer
  ;; -1 if first token is 'middle
  ;; Previous line:
  ;; +1 on every unmatched opener
  ;; +1 if first token is a 'middle
  ;; -1 on every unmatched closer if first token is not a closer (if first token
  ;;  is a 'middle, then first unmatched closer is actually closing the middle).
  ;;
  ;; To this we add
  ;; + previous line indentation
  ;; +1 if previous line is not a continuation and current-line is
  ;; -1 if previous line is a continuation and current-line is not
  (save-excursion
    (back-to-indentation)
    (let* ((continuing-p (lua-is-continuing-statement-p))
           (cur-line-begin-pos (line-beginning-position))
           (close-factor (lua-line-indent-impact-current)))

      (if (lua-forward-line-skip-blanks 'back)
          (+ (current-indentation)
             (lua-line-indent-impact-next cur-line-begin-pos)
             close-factor
             ;; Previous line is a continuing statement, but not current.
             (if (and (lua-is-continuing-statement-p) (not continuing-p))
                 (- lua-indent-level)
               0)
             ;; Current line is a continuing statement, but not previous.
             (if (and (not (lua-is-continuing-statement-p)) continuing-p)
                 lua-indent-level
               0))
        ;; If there's no previous line, indentation is 0.
        0))))
(advice-add #'lua-calculate-indentation :override #'+amos-lua-calculate-indentation-a)

(global-page-break-lines-mode +1)

(defun anzu-multiedit (&optional symbol)
  (interactive (list evil-symbol-word-search))
  (let ((string (evil-find-thing t (if symbol 'symbol 'word))))
    (if (null string)
        (user-error "No word under point")
      (let* ((regex (if nil ;; unbounded
                        (regexp-quote string)
                      (format (if symbol "\\_<%s\\_>" "\\<%s\\>")
                              (regexp-quote string))))
             (search-pattern (evil-ex-make-search-pattern regex)))
        (evil-multiedit-ex-match (point-min) (point-max) nil (car search-pattern))))))

(defun +amos/lsp-ui-imenu ()
  (interactive)
  (setq lsp-ui-imenu--origin (current-buffer))
  (imenu--make-index-alist)
  (let ((list imenu--index-alist))
    (with-current-buffer (get-buffer-create "*lsp-ui-imenu*")
      (let* ((padding (or (and (eq lsp-ui-imenu-kind-position 'top) 1)
                          (--> (-filter 'imenu--subalist-p list)
                               (--map (length (car it)) it)
                               (-max (or it '(1))))))
             (grouped-by-subs (-partition-by 'imenu--subalist-p list))
             (color-index 0)
             buffer-read-only)
        (remove-overlays)
        (erase-buffer)
        (lsp-ui-imenu--put-separator)
        (dolist (group grouped-by-subs)
          (if (imenu--subalist-p (car group))
              (dolist (kind group)
                (-let* (((title . entries) kind))
                  (lsp-ui-imenu--put-kind title padding color-index)
                  (--each-indexed entries
                    (insert (lsp-ui-imenu--make-line title it-index padding it color-index)))
                  (lsp-ui-imenu--put-separator)
                  (setq color-index (1+ color-index))))
            (--each-indexed group
              (insert (lsp-ui-imenu--make-line " " it-index padding it color-index)))
            (lsp-ui-imenu--put-separator)
            (setq color-index (1+ color-index))))
        (lsp-ui-imenu-mode)
        (setq mode-line-format '(:eval (lsp-ui-imenu--win-separator)))
        (goto-char 1)
        (add-hook 'post-command-hook 'lsp-ui-imenu--post-command nil t)))
    (let ((win (display-buffer-in-side-window (get-buffer "*lsp-ui-imenu*") '((side . right))))
          (fit-window-to-buffer-horizontally t))
      (set-window-margins win 1)
      (select-window win)
      (set-window-start win 1)
      (set-window-dedicated-p win t)
      (let ((fit-window-to-buffer-horizontally 'only))
        (fit-window-to-buffer win))
      (window-resize win 20 t))))

(defun +amos/toggle-mc ()
  (interactive)
  (evil-mc-make-cursor-here)
  (evil-mc-pause-cursors))

(defun +amos/wipe-current-buffer ()
  (interactive)
  (+amos/close-current-buffer t))

(defun +amos/kill-current-buffer ()
  (interactive)
  (+amos/close-current-buffer t t))

(defun +amos/switch-buffer ()
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) t)))

(defmacro +amos-evil-ex! (name command)
  `(evil-define-command ,(intern (concat "+amos/" (symbol-name name))) ()
     (evil-ex ,command)))
(+amos-evil-ex! line-substitute "s/")
(+amos-evil-ex! all-substitute "%s/")
(+amos-evil-ex! region-substitute "'<,'>s/")

(defun +amos/counsel-recentf-no-cache ()
  (interactive)
  (require 'recentf)
  (recentf-cleanup)
  (counsel-recentf))

(defun +amos/reset-zoom ()
  (interactive)
  (text-scale-set 0))

(defun +amos/increase-zoom ()
  (interactive)
  (text-scale-increase 0.5))

(defun +amos/decrease-zoom ()
  (interactive)
  (text-scale-decrease 0.5))

(setq ssh-remote-addr (and (getenv "SSH_CONNECTION") (nth 2 (split-string (getenv "SSH_CONNECTION") " "))))
(defun +amos-paste-file (filename)
  (if ssh-remote-addr
      (let ((cmd (format "scp %s %s:%s/" (shell-quote-argument filename) ssh-remote-addr (shell-quote-argument default-directory))))
        (message cmd)
        (osc-command cmd))
    (shell-command! (format "cp %s %s/" (shell-quote-argument filename) (shell-quote-argument default-directory)))))

(defun +amos-dispatch-uri-list (uri-list)
  (cond
   ((eq major-mode 'mu4e-compose-mode)
    (save-excursion
      (goto-char (point-max))
      (let ((files (split-string uri-list "[\0\r\n]" t)))
        (--each files
          (let ((file-name (url-unhex-string (string-remove-prefix "file://" it))))
            (when (and (file-exists-p file-name)
                       (not (file-directory-p file-name)))
              (mail-add-attachment file-name))))))
    t)
   ((eq major-mode 'dired-mode)
    (let ((files (split-string uri-list "[\0\r\n]" t)))
      (--each files
        (let ((file-name (string-remove-prefix "file://" it)))
          (+amos-paste-file file-name)))
      (revert-buffer t t t))
    t)
   (t
    nil)))

(defun +amos/dump-evil-jump-list ()
  (interactive)
  (message (format "idx = %d, size = %d"
                   (evil-jumps-struct-idx (evil--jumps-get-current))
                   (ring-length (evil--jumps-get-window-jump-list)))))

(defun +amos/reset-cursor ()
  (interactive)
  (evil-refresh-cursor)
  (realign-windows)
  ;; (if buffer-file-name (+amos/revert-buffer))
  )

(defun +amos-find-file-a (filename &optional wildcards)
  "Turn files like file.cpp:14 into file.cpp and going to the 14-th line."
  (pcase (file-name-extension filename)
    ("zip" (+amos/compress-view filename))
    ("rar" (+amos/compress-view filename))
    (_
     (save-match-data
       (let* ((matched (string-match "^\\(.*\\):\\([0-9]+\\):?$" filename))
              (line-number (and matched
                                (match-string 2 filename)
                                (string-to-number (match-string 2 filename))))
              (filename (if matched (match-string 1 filename) filename))
              (_ (let ((parent-directory (file-name-directory filename)))
                   (if (and parent-directory (not (file-exists-p parent-directory)))
                       (make-directory parent-directory t))))
              (buffer
               (let* ((value (find-file-noselect filename nil nil wildcards)))
                 (if (listp value)
                     (mapcar 'pop-to-buffer-same-window (nreverse value))
                   (pop-to-buffer-same-window value))
                 (+file-templates-check-h)
                 value)))
         (when line-number
           ;; goto-line is for interactive use
           (goto-char (point-min))
           (forward-line (1- line-number)))
         buffer)))))
(advice-add 'find-file :override #'+amos-find-file-a)

(mapc #'evil-declare-change-repeat
      '(
        +amos/complete
        +amos/complete-filter
        +amos/company-abort
        +amos/company-search-abort
        amos-company-files
        ))

(defun +amos/format-buffer ()
  (interactive)
  (if (use-region-p)
      (call-interactively #'+format/region)
    (call-interactively #'+format/buffer)))

;; debugging eldoc
(defun stupid_function (&optional xxxxxxx1 xxxxxxx2 xxxxxxx3 xxxxxxx4 xxxxxxx5 xxxxxxx6 xxxxxxx7 xxxxxxx8 xxxxxxx9 xxxxxxx10 xxxxxxx11 xxxxxxx12 xxxxxxx13 xxxxxxx14 xxxxxxx15 xxxxxxx16 xxxxxxx17 xxxxxxx18 xxxxxxx19 xxxxxxx20 xxxxxxx21 xxxxxxx22 xxxxxxx23 xxxxxxx24 xxxxxxx25 xxxxxxx26 xxxxxxx27 xxxxxxx28 xxxxxxx29 xxxxxxx30 xxxxxxx31 xxxxxxx32 xxxxxxx33 xxxxxxx34 xxxxxxx35 xxxxxxx36 xxxxxxx37 xxxxxxx38 xxxxxxx39))
(stupid_function)
(setq resize-mini-windows 'grow-only)

(defun +amos/find-file-at-point ()
  (interactive)
  (-if-let (s (symbol-at-point))
      (let* ((path (symbol-name s))
             (dir (file-name-directory path))
             (name (file-name-nondirectory path))
             (adir (expand-file-name (or dir "./")))
             (_ (while (not (file-directory-p adir))
                  (let ((tmp (substring adir 0 -1)))
                    (setq adir (file-name-directory tmp))
                    (setq name (concat (file-name-nondirectory tmp) "/" name)))))
             (default-directory adir))
        (minibuffer-with-setup-hook
            (lambda ()
              (insert name))
          (ivy-read "Find file: " #'read-file-name-internal
                    :matcher #'counsel--find-file-matcher
                    :action #'counsel-find-file-action
                    :require-match 'confirm-after-completion
                    :history 'file-name-history
                    :keymap counsel-find-file-map
                    :caller 'counsel-find-file)))
    (user-error "No file at point")))

(defun +amos/upload ()
  (interactive)
  (let ((filename (buffer-file-name))
        tmp)
    (unless filename
      (setq filename (make-temp-file "upload"))
      (write-region (point-min) (point-max) filename)
      (setq tmp t))
    (kill-new
     (string-trim-right
      (shell-command-to-string (concat "upload " filename " out"))))
    (osc-command "notify-send OSC52Command '\nText Uploaded'")
    (if tmp (delete-file filename))))

(advice-add #'semantic-mode :around #'doom-shut-up-a)

(defun my-inhibit-semantic-p ()
  (not (or (equal major-mode 'c-mode) (equal major-mode 'c++-mode))))
(add-to-list 'semantic-default-submodes 'global-semantic-stickyfunc-mode)
(semantic-mode -1)
(with-eval-after-load 'semantic
  (add-to-list 'semantic-inhibit-functions #'my-inhibit-semantic-p))

(defun my-replace (beg end)
  (interactive
   (list (if (use-region-p) evil-visual-beginning (line-beginning-position))
         (if (use-region-p) evil-visual-end (line-end-position))))
  (save-excursion
    (while (and (goto-char beg)
                (re-search-forward "\\[\\([^]]+\\)\\]" end t))
      (replace-match (format "{%s}" (match-string 1))))))

(add-hook! 'comint-mode-hook
  (add-hook! 'evil-insert-state-entry-hook :local
    (defun +amos|comint-scroll-to-bottom ()
      (setq comint-move-point-for-output 'this)
      (goto-char (point-max))))
  (add-hook! 'evil-insert-state-exit-hook :local
    (defun +amos|comint-stop-scroll ()
      (setq comint-move-point-for-output nil))))

(remove-hook '+lookup-definition-functions #'+lookup-dumb-jump-backend-fn)
(remove-hook '+lookup-definition-functions #'+lookup-project-search-backend-fn)

(defun +amos/clear-yasnippet ()
  (interactive)
  (let* ((snippet (car (yas-active-snippets)))
         (active-field (overlay-get yas--active-field-overlay 'yas--field))
         (target-field (yas--find-next-field 1 snippet active-field)))
    (while target-field
      (yas--skip-and-clear target-field)
      (setq target-field (yas--find-next-field 1 snippet target-field)))
    (yas-exit-snippet snippet)))

;; unwind flycheck backtrace
;; (defun doom*flycheck-buffer ()
;;   (interactive)
;;   (flycheck-clean-deferred-check)
;;   (if flycheck-mode
;;       (unless (flycheck-running-p)
;;         (run-hooks 'flycheck-before-syntax-check-hook)
;;         (flycheck-clear-errors)
;;         (flycheck-mark-all-overlays-for-deletion)
;;         (let* ((checker (flycheck-get-checker-for-buffer)))
;;           (if checker
;;               (flycheck-start-current-syntax-check checker)
;;             (flycheck-clear)
;;             (flycheck-report-status 'no-checker))))
;;     (user-error "Flycheck mode disabled")))
;; (advice-add #'flycheck-buffer :override #'doom*flycheck-buffer)
;; (defun doom*flycheck-start-command-checker (checker callback)
;;   (let (process)
;;     (let* ((program (flycheck-find-checker-executable checker))
;;            (args (flycheck-checker-substituted-arguments checker))
;;            (command (funcall flycheck-command-wrapper-function
;;                              (cons program args)))
;;            (process-connection-type nil))
;;       (setq process (apply 'start-process (format "flycheck-%s" checker)
;;                            nil command))
;;       (setf (process-sentinel process) #'flycheck-handle-signal)
;;       (setf (process-filter process) #'flycheck-receive-checker-output)
;;       (set-process-query-on-exit-flag process nil)
;;       (process-put process 'flycheck-checker checker)
;;       (process-put process 'flycheck-callback callback)
;;       (process-put process 'flycheck-buffer (current-buffer))
;;       (process-put process 'flycheck-working-directory default-directory)
;;       (process-put process 'flycheck-temporaries flycheck-temporaries)
;;       (setq flycheck-temporaries nil)
;;       (when (flycheck-checker-get checker 'standard-input)
;;         (flycheck-process-send-buffer process))
;;       process)))
;; (advice-add #'flycheck-start-command-checker :override #'doom*flycheck-start-command-checker)

;; (defun +amos*git-link--select-remote ()
;;   (if current-prefix-arg
;;       (git-link--read-remote)
;;     (or (magit-get-upstream-remote) (magit-get-push-remote) "origin")))
;; (setq git-link-default-branch "master")
;; (advice-add #'git-link--select-remote :override #'+amos*git-link--select-remote)

(evil-define-command +amos-evil-scroll-down-a (count)
  "Scrolls the window and the cursor COUNT lines downwards.
If COUNT is not specified the function scrolls down
`evil-scroll-count', which is the last used count.
If the scroll count is zero the command scrolls half the screen."
  :repeat nil
  :keep-visual t
  (interactive "<c>")
  (evil-save-column
    (setq count (or count (max 0 evil-scroll-count)))
    (setq evil-scroll-count count)
    (when (eobp) (signal 'end-of-buffer nil))
    (when (zerop count)
      (setq count (/ (1- (window-height)) 2)))
    ;; BUG #660: First check whether the eob is visible.
    ;; In that case we do not scroll but merely move point.
    (if (<= (point-max) (window-end))
        (with-no-warnings (next-line count nil))
      (let ((xy (posn-x-y (posn-at-point))))
        (condition-case nil
            (progn
              (scroll-up count)
              (let* ((wend (window-end nil t))
                     (p (posn-at-x-y (car xy) (cdr xy)))
                     ;; amos: header line breaks
                     (p2 (posn-at-x-y (car xy) (1+ (cdr xy))))
                     (margin (max 0 (- scroll-margin
                                       (cdr (posn-col-row p))))))
                (goto-char (or (posn-point p) (posn-point p2)))
                ;; ensure point is not within the scroll-margin
                (when (> margin 0)
                  (with-no-warnings (next-line margin))
                  (recenter scroll-margin))
                (when (<= (point-max) wend)
                  (save-excursion
                    (goto-char (point-max))
                    (recenter (- (max 1 scroll-margin)))))))
          (end-of-buffer
           (goto-char (point-max))
           (recenter (- (max 1 scroll-margin)))))))))
(advice-add #'evil-scroll-down :override #'+amos-evil-scroll-down-a)

(defun +amos-evil-insert-newline-below-a ()
  "Inserts a new line below point and places point in that line
with regard to indentation."
  (evil-narrow-to-field
    (evil-move-end-of-line)
    (if (not (looking-at "\n"))
        (insert (if use-hard-newlines hard-newline "\n"))
      (forward-char 1)
      (insert (if use-hard-newlines hard-newline "\n"))
      (backward-char 1))
    (back-to-indentation)))
(advice-add #'evil-insert-newline-below :override #'+amos-evil-insert-newline-below-a)

(evil-define-motion +amos-evil-ret-a (count)
  "Move the cursor COUNT lines down.
If point is on a widget or a button, click on it.
In Insert state, insert a newline."
  :type line
  (let ((url (thing-at-point 'url)))
    (if url (goto-address-at-point)
      (let ((nl (looking-at "\n")))
        (if nl (forward-char 1))
        (evil-ret-gen count nil)
        (if nl (backward-char 1))))))
(advice-add #'evil-ret :override #'+amos-evil-ret-a)

(defun +amos-git-gutter:search-near-diff-index-a (diffinfos is-reverse)
  (let ((lines (--map (git-gutter-hunk-start-line it) diffinfos)))
    (if is-reverse
        (--find-last-index (> (line-number-at-pos) it) lines)
      (--find-index (< (line-number-at-pos) it) lines))))
(advice-add #'git-gutter:search-near-diff-index :override #'+amos-git-gutter:search-near-diff-index-a)

(defun +amos-company--insert-candidate-a (candidate)
  (when (> (length candidate) 0)
    (setq candidate (substring-no-properties candidate))
    (let* ((prefix (s-shared-start company-prefix candidate))
           (non-prefix (substring company-prefix (length prefix))))
      (delete-region (- (point) (length non-prefix)) (point))
      (insert (substring candidate (length prefix))))))
(advice-add #'company--insert-candidate :override #'+amos-company--insert-candidate-a)

;; company

(setq-default company-idle-delay (lambda () (if (company-in-string-or-comment) nil 0.3))
              company-auto-complete nil ; this is actually company-auto-finish
              company-tooltip-limit 14
              company-dabbrev-downcase nil
              company-dabbrev-ignore-case nil
              company-dabbrev-code-time-limit 0.3
              company-dabbrev-ignore-buffers "\\`[ *]"
              company-tooltip-align-annotations t
              company-require-match 'never
              company-global-modes '(not eshell-mode comint-mode erc-mode message-mode help-mode gud-mode)
              company-frontends (append '(company-tng-frontend) company-frontends)
              company-backends '(company-lsp company-capf company-dabbrev company-ispell company-yasnippet)
              company-transformers nil
              company-lsp-async t
              company-lsp-cache-candidates nil
              company-search-regexp-function 'company-search-flex-regexp)
(defvar-local company-fci-mode-on-p nil)
(defun company-turn-off-fci (&rest ignore)
  (when (boundp 'fci-mode)
    (setq company-fci-mode-on-p fci-mode)
    (when fci-mode (fci-mode -1))))
(defun company-maybe-turn-on-fci (&rest ignore)
  (when company-fci-mode-on-p (fci-mode 1)))
(add-hook 'company-completion-started-hook   #'company-turn-off-fci)
(add-hook 'company-completion-finished-hook  #'company-maybe-turn-on-fci)
(add-hook 'company-completion-cancelled-hook #'company-maybe-turn-on-fci)

(defvar-local company-tng--overlay nil)

(defun company-tng-frontend (command)
  (cl-case command
    (show
     (let ((ov (make-overlay (point) (point))))
       (setq company-tng--overlay ov)
       (overlay-put ov 'priority 2))
     (advice-add 'company-select-next :before-until 'company-tng--allow-unselected)
     (advice-add 'company-fill-propertize :filter-args 'company-tng--adjust-tooltip-highlight))
    (update
     (let* ((ov company-tng--overlay)
            (candidate (nth company-selection company-candidates))
            (prefix (s-shared-start company-prefix candidate))
            (non-prefix (substring company-prefix (length prefix)))
            (selected (substring candidate (length prefix)))
            (selected (and company-selection-changed
                           (if (iedit-find-current-occurrence-overlay)
                               (propertize selected 'face 'iedit-occurrence)
                             selected))))
       (move-overlay ov (- (point) (length non-prefix)) (point))
       (overlay-put ov (if (= (length non-prefix) 0) 'after-string 'display)
                    selected)))
    (hide
     (when company-tng--overlay
       (delete-overlay company-tng--overlay)
       (kill-local-variable 'company-tng--overlay))
     (advice-remove 'company-select-next 'company-tng--allow-unselected)
     (advice-remove 'company-fill-propertize 'company-tng--adjust-tooltip-highlight))
    (pre-command
     (when (and company-selection-changed
                (not (company--company-command-p (this-command-keys))))
       (company--unread-this-command-keys)
       (setq this-command 'company-complete-selection)
       (advice-add 'company-call-backend :before-until 'company-tng--supress-post-completion)))))

(defun company-tng--allow-unselected (&optional arg)
  "Advice `company-select-next' to allow for an 'unselected'
state. Unselected means that no user interaction took place on the
completion candidates and it's marked by setting
`company-selection-changed' to nil. This advice will call the underlying
`company-select-next' unless we need to transition to or from an unselected
state.

Possible state transitions:
- (arg > 0) unselected -> first candidate selected
- (arg < 0) first candidate selected -> unselected
- (arg < 0 wrap-round) unselected -> last candidate selected
- (arg < 0 no wrap-round) unselected -> unselected

There is no need to advice `company-select-previous' because it calls
`company-select-next' internally."
  (cond
   ;; Selecting next
   ((or (not arg) (> arg 0))
    (unless company-selection-changed
      (company-set-selection (1- (or arg 1)) 'force-update)
      t))
   ;; Selecting previous
   ((< arg 0)
    (when (and company-selection-changed
               (< (+ company-selection arg) 0))
      (company-set-selection 0)
      (setq company-selection-changed nil)
      (company-call-frontends 'update)
      t)
    )))

(defun company-tng--adjust-tooltip-highlight (args)
  (unless company-selection-changed
    (setf (nth 3 args) nil))
  args)

(defun company-tng--supress-post-completion (command &rest args)
  (when (eq command 'post-completion)
    (advice-remove #'company-call-backend #'company-tng--supress-post-completion)
    t))

;; ignore buffers for switching
(defun +amos-doom-buffer-frame-predicate-a (buf)
  (let ((mode (with-current-buffer buf major-mode)))
    (pcase mode
      ;; ('dired-mode nil)
      (_ t))))
(advice-add #'doom-buffer-frame-predicate :override #'+amos-doom-buffer-frame-predicate-a)

(defun +amos-display-buffer-no-reuse-window (&rest _) nil)

(defun +amos/exec-shell-command ()
  (interactive)
  (ivy-read "Shell command: " (split-string (shell-command-to-string "bash -c 'compgen -c' | tail -n +85") "\n")
            :action #'compile
            :caller '+amos-exec-shell-command))

;; get rid of minibuffer resize limitation
(defun +amos-window--resize-mini-window-a (window delta)
  "Resize minibuffer window WINDOW by DELTA pixels.
If WINDOW cannot be resized by DELTA pixels make it as large (or
as small) as possible, but don't signal an error."
  (when (window-minibuffer-p window)
    (let* ((frame (window-frame window))
           (root (frame-root-window frame))
           (height (window-pixel-height window))
           (min-delta
            (- (window-pixel-height root)
               (window-min-size root nil t t)))) ;; amos
      ;; Sanitize DELTA.
      (cond
       ((<= (+ height delta) 0)
        (setq delta (- (frame-char-height (window-frame window)) height)))
       ((> delta min-delta)
        (setq delta min-delta)))

      (unless (zerop delta)
        ;; Resize now.
        (window--resize-reset frame)
        ;; Ideally we should be able to resize just the last child of root
        ;; here.  See the comment in `resize-root-window-vertically' for
        ;; why we do not do that.
        (window--resize-this-window root (- delta) nil nil t)
        (set-window-new-pixel window (+ height delta))
        ;; The following routine catches the case where we want to resize
        ;; a minibuffer-only frame.
        (when (resize-mini-window-internal window)
          (window--pixel-to-total frame)
          (run-window-configuration-change-hook frame))))))
(advice-add #'window--resize-mini-window :override #'+amos-window--resize-mini-window-a)

(defun +amos/swiper ()
  (interactive)
  (if (eq major-mode 'ivy-occur-grep-mode)
      (save-restriction
        (save-excursion
          (goto-char 1)
          (forward-line 4)
          (narrow-to-region (point) (point-max)))
        (swiper-isearch))
    (swiper-isearch)))

(defun +amos/swiper-search-symbol ()
  (interactive)
  (if (and (stringp (ivy-state-current ivy-last)) (string-empty-p (ivy-state-current ivy-last)))
      (let ((text (ignore-errors (with-ivy-window (symbol-name (symbol-at-point))))))
        (if text (insert (setf (ivy-state-current ivy-last) text))))
    (ivy-next-line)))

(defun +amos/swiper-symbol ()
  (interactive)
  (swiper-isearch (ignore-errors (symbol-name (symbol-at-point)))))

(defun +amos/wgrep-occur ()
  "Invoke the search+replace wgrep buffer on the current ag/rg search results."
  (interactive)
  (unless (window-minibuffer-p)
    (user-error "No completion session is active"))
  (require 'wgrep)
  (setq is-swiper-occur (eq (ivy-state-caller ivy-last) 'swiper-isearch))
  (let* ((ob (ivy-state-buffer ivy-last))
         (caller (ivy-state-caller ivy-last))
         (xref (eq caller '+amos-ivy-xref))
         (recursive (and (eq (with-current-buffer ob major-mode) 'ivy-occur-grep-mode)
                         (eq caller 'swiper-isearch)))
         (occur-fn (plist-get ivy--occurs-list caller))
         (buffer (generate-new-buffer
                  (format "*ivy-occur%s \"%s\"*"
                          (if caller (concat " " (prin1-to-string caller)) "")
                          ivy-text))))
    (with-current-buffer buffer
      (let ((inhibit-read-only t))
        (erase-buffer)
        (if recursive (+amos/swiper-occur)
          (if (not xref)
              (funcall occur-fn)
            (ivy-occur-grep-mode)
            ;; Need precise number of header lines for `wgrep' to work.
            (insert (format "-*- mode:grep; default-directory: %S -*-\n\n\n"
                            default-directory))
            (insert (format "%d candidates:\n" (length +amos-last-xref-list)))
            (ivy--occur-insert-lines +amos-last-xref-list))))
      ;; (setf (ivy-state-text ivy-last) ivy-text)
      (setq ivy-occur-last ivy-last)
      (setq-local ivy--directory ivy--directory)
      (goto-char 1)
      (forward-line 4))
    (with-selected-window (ivy-state-window ivy-last)
      (goto-char +amos-ivy--origin))
    (ivy-exit-with-action
     `(lambda (_)
        (if ,recursive
            (progn
              (switch-to-buffer ,buffer)
              (kill-buffer ,ob))
          (switch-to-buffer ,buffer))
        (ivy-wgrep-change-to-wgrep-mode)))))

(defun +amos-swiper--isearch-occur-cands (cands)
  (let* ((last-pt (get-text-property 0 'point (car cands)))
         (line (1+ (line-number-at-pos last-pt)))
         res pt)
    (dolist (cand cands)
      (setq pt (get-text-property 0 'point cand))
      (let ((lines (1- (count-lines last-pt pt))))
        (when (< 0 lines)
          (cl-incf line lines)
          (push (cons line cand) res)
          (setq last-pt pt))))
    (nreverse res)))

(defun +amos-swiper--occur-cands (cands)
  (when cands
    (with-current-buffer (ivy-state-buffer ivy-last)
      (setq cands (mapcar #'swiper--line-at-point cands))
      (mapcar (lambda (x) (cdr x)) (+amos-swiper--isearch-occur-cands cands)))))

(defun +amos/swiper-occur (&optional revert)
  "Generate a custom occur buffer for `swiper'.
When REVERT is non-nil, regenerate the current *ivy-occur* buffer.
When capture groups are present in the input, print them instead of lines."
  (let* ((buffer (ivy-state-buffer ivy-last))
         (ivy-text (progn (string-match "\"\\(.*\\)\"" (buffer-name))
                          (match-string 1 (buffer-name))))
         (re (mapconcat #'identity (ivy--split ivy-text) ".*?"))
         (cands
          (+amos-swiper--occur-cands
           (if (not revert)
               ivy--old-cands
             (setq ivy--old-re nil)
             (save-window-excursion
               (switch-to-buffer buffer)
               (if (eq (ivy-state-caller ivy-last) 'swiper)
                   (let ((ivy--regex-function 'swiper--re-builder))
                     (ivy--filter re (swiper--candidates)))
                 (swiper-isearch-function ivy-text)))))))
    (if (string-match-p "\\\\(" re)
        (insert
         (mapconcat #'identity
                    (swiper--extract-matches
                     re (with-current-buffer buffer
                          (swiper--candidates)))
                    "\n"))
      (unless (eq major-mode 'ivy-occur-grep-mode)
        (ivy-occur-grep-mode)
        (font-lock-mode -1))
      (setq swiper--current-window-start nil)
      (insert (format "-*- mode:grep; default-directory: %S -*-\n\n\n"
                      default-directory))
      (insert (format "%d candidates:\n" (length cands)))
      (ivy--occur-insert-lines cands)
      (goto-char (point-min))
      (forward-line 4))))

(defun +amos/delete-nonascii (beg end)
  "Delete binary characters in a region"
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region beg end)
      (goto-char (point-min))
      (while (re-search-forward "[^[:ascii:]]" nil t)
        (replace-match "")))))

(defun +amos/launch ()
  (interactive)
  (let ((default-directory (doom-project-root)))
    (+amos/tmux-fork-window "launch.sh")))

(defun +amos/list-file (&optional initial-input)
  (interactive)
  (ivy-read "List file: " (split-string (shell-command-to-string "find -- * -prune -type f -print && find .* -prune -type f -print") "\n")
            :initial-input initial-input
            :action #'find-file
            :preselect (counsel--preselect-file)
            :require-match 'confirm-after-completion
            :history 'file-name-history
            :keymap counsel-find-file-map
            :caller '+amos/list-file))

(defun +amos/iedit-number-occurrences ()
  (interactive)
  (-when-let* ((overlay (iedit-find-current-occurrence-overlay))
               (delta (- (point) (overlay-start overlay))))
    (iedit-barf-if-buffering)
    (setq format-string "%d")
    (let ((iedit-number-occurrence-counter 1)
          (inhibit-modification-hooks t))
      (save-excursion
        (goto-char (+ delta (iedit-first-occurrence)))
        (setq overlay (iedit-find-current-occurrence-overlay))
        (while (/= (point) (point-max))
          (insert (format format-string iedit-number-occurrence-counter))
          (iedit-move-conjoined-overlays overlay)
          (setq iedit-number-occurrence-counter
                (1+ iedit-number-occurrence-counter))
          (goto-char (next-single-char-property-change (point) 'iedit-occurrence-overlay-name))
          (goto-char (next-single-char-property-change (point) 'iedit-occurrence-overlay-name))
          (setq overlay (iedit-find-current-occurrence-overlay))
          (unless (and overlay
                       (= (point) (overlay-end overlay)))
            (goto-char (+ delta (point)))))))))

(defun +amos/shell-command-on-buffer (command)
  (interactive "sShell command on buffer: ")
  (shell-command-on-region (point-min) (point-max) command nil t))

(defun +amos/shell-command-on-region (start end command)
  (interactive (let (string)
                 (unless (mark)
                   (user-error "The mark is not set now, so there is no region"))
                 (setq string (read-shell-command "Shell command on region: "))
                 (list (region-beginning) (region-end) string)))
  (shell-command-on-region start end command nil t))

(defun +amos/shell-command-or-region ()
  (interactive)
  (if (use-region-p)
      (call-interactively #'+amos/shell-command-on-region)
    (call-interactively #'shell-command)))

(defun +amos/revert-projectile-buffers ()
  "Refresh all open file buffers in current projectile without confirmation.
Buffers in modified (not yet saved) state in emacs will not be reverted. They
will be reverted though if they were modified outside emacs.
Buffers visiting files which do not exist any more or are no longer readable
will be killed."
  (interactive)
  (dolist (buf (projectile-project-buffers))
    (let ((filename (buffer-file-name buf)))
      ;; Revert only buffers containing files, which are not modified;
      ;; do not try to revert non-file buffers like *Messages*.
      (when (and filename
                 (not (buffer-modified-p buf)))
        (if (file-readable-p filename)
            ;; If the file exists and is readable, revert the buffer.
            (with-current-buffer buf
              (revert-buffer :ignore-auto :noconfirm :preserve-modes))
          ;; Otherwise, kill the buffer.
          (let (kill-buffer-query-functions) ; No query done when killing buffer
            (kill-buffer buf)
            (message "Killed non-existing/unreadable file buffer: %s" filename))))))
  (message "Finished reverting buffers containing unmodified files."))

(advice-add #'flycheck-previous-error :after (lambda (&rest _) (recenter)))
(advice-add #'flycheck-next-error :after (lambda (&rest _) (recenter)))

(evil-define-state sticky
  "Sticky state.
 Used to stick modifiers."
  :tag " <Sticky> ")

(set-keymap-parent evil-sticky-state-map (make-composed-keymap evil-motion-state-map evil-normal-state-map))

(general-define-key
 :states 'sticky
 "u"            #'evil-scroll-up
 "d"            #'evil-scroll-down)
(add-hook! 'evil-sticky-state-exit-hook #'+amos/reset-cursor)

(evil-define-state struct
  "struct state.
 Used to do structure editing modifiers."
  :tag " <Struct> ")

(set-keymap-parent evil-struct-state-map (make-composed-keymap evil-motion-state-map evil-normal-state-map))

(defmacro scrollall! (command)
  `(defun ,(intern (concat "scroll-all-" (symbol-name command))) (arg)
     (interactive "p")
     (save-selected-window
       (dolist (walk-windows-window (window-list-1))
         (with-selected-window walk-windows-window
           (with-current-buffer (window-buffer walk-windows-window)
             (call-interactively #',command arg)
             (ccm-position-cursor)))))))

(scrollall! evil-next-line)
(scrollall! evil-previous-line)
(scrollall! evil-scroll-up)
(scrollall! evil-scroll-down)
(scrollall! evil-goto-first-line)
(scrollall! +amos/evil-goto-line)
(scrollall! +amos/redisplay-and-recenter)

(general-define-key
 :states 'struct
 "gg"             #'scroll-all-evil-goto-first-line
 "G"              #'scroll-all-+amos/evil-goto-line
 "k"              #'scroll-all-evil-previous-line
 "j"              #'scroll-all-evil-next-line
 "C-l"            #'scroll-all-+amos/redisplay-and-recenter
 "C-u"            #'scroll-all-evil-scroll-up
 "C-d"            #'scroll-all-evil-scroll-down)

(defun +amos/toggle-centered-cursor-mode-all-window ()
  (interactive "p")
  (require 'centered-cursor-mode)
  (save-selected-window
    (dolist (walk-windows-window (window-list-1))
      (with-selected-window walk-windows-window
        (with-current-buffer (window-buffer walk-windows-window)
          (ccm-first-start (interactive-p)))))))
(add-hook! 'evil-struct-state-entry-hook #'+amos/toggle-centered-cursor-mode-all-window)
(add-hook! 'evil-struct-state-exit-hook #'+amos/reset-cursor)

(remove-hook 'after-change-major-mode-hook #'doom-highlight-non-default-indentation-h)

;; for remapped escape key
(defun +amos-read-char-choice-a (prompt chars &optional inhibit-keyboard-quit)
  "Read and return one of CHARS, prompting for PROMPT.
Any input that is not one of CHARS is ignored.

If optional argument INHIBIT-KEYBOARD-QUIT is non-nil, ignore
keyboard-quit events while waiting for a valid input."
  (unless (consp chars)
    (error "Called `read-char-choice' without valid char choices"))
  (let (char done show-help (helpbuf " *Char Help*"))
    (let ((cursor-in-echo-area t)
          (executing-kbd-macro executing-kbd-macro)
          (esc-flag nil))
      (save-window-excursion          ; in case we call help-form-show
        (while (not done)
          (unless (get-text-property 0 'face prompt)
            (setq prompt (propertize prompt 'face 'minibuffer-prompt)))
          (setq char (let ((inhibit-quit inhibit-keyboard-quit))
                       (read-key prompt)))
          (and show-help (buffer-live-p (get-buffer helpbuf))
               (kill-buffer helpbuf))
          (cond
           ((eq 'escape char)
            (keyboard-quit))
           ((not (numberp char)))
           ;; If caller has set help-form, that's enough.
           ;; They don't explicitly have to add help-char to chars.
           ((and help-form
                 (eq char help-char)
                 (setq show-help t)
                 (help-form-show)))
           ((memq char chars)
            (setq done t))
           ((and executing-kbd-macro (= char -1))
            ;; read-event returns -1 if we are in a kbd macro and
            ;; there are no more events in the macro.  Attempt to
            ;; get an event interactively.
            (setq executing-kbd-macro nil))
           ((not inhibit-keyboard-quit)
            (cond
             ((and (null esc-flag) (eq char ?\e))
              (setq esc-flag t))
             ((memq char '(?\C-g ?\e))
              (keyboard-quit))))))))
    ;; Display the question with the answer.  But without cursor-in-echo-area.
    (message "%s%s" prompt (char-to-string char))
    char))
(advice-add #'read-char-choice :override #'+amos-read-char-choice-a)

(defun make-set ()
  (make-hash-table))
(defun add-to-set (element set)
  (puthash element t set))
(defun in-set-p (element set)
  (gethash element set nil))
(defun remove-from-set (element set)
  (remhash element set))

(defvar compile-set (make-set))
(defun +amos*add-compile-buffer-to-set (&rest _)
  (unless (s-starts-with? "*rmsbolt" (buffer-name))
    (add-to-set next-error-last-buffer compress-view-set)))
;; (advice-add #'compilation-start :after #'+amos*add-compile-buffer-to-set)

(defvar compress-view-set (make-set))
(defvar-local +amos-compressed-file nil)

(defun +amos/compress-view (&optional file)
  (interactive)
  (let ((file (or file (dired-get-file-for-visit)))
        (buffer (generate-new-buffer "amos-compress-view")))
    (switch-to-buffer buffer)
    ;; (shell-command! (format "7z l %s | perl -0777ne 'print /(Date      Time    Attr         Size   Compressed  Name.*)/s'"
    ;;                        (shell-quote-argument file)) buffer)
    (let ((encoding (if current-prefix-arg "zh_CN.GBK" "en_US.UTF-8")))
      (shell-command! (format "LANG=%s dtrx -l %s" encoding (shell-quote-argument file)) buffer))
    (add-to-set buffer compress-view-set)
    (amos-compress-view-mode)
    (cd (file-name-directory file))
    (setq-local +amos-compressed-file file)))

(defun +amos-kill-buffer-h()
  (if (in-set-p (current-buffer) compress-view-set) (remove-from-set (current-buffer) compress-view-set))
  (if (in-set-p (current-buffer) compile-set) (remove-from-set (current-buffer) compile-set)))
(add-hook! 'kill-buffer-hook #'+amos-kill-buffer-h)

(defun +amos-buffer-list-update-h()
  (maphash (lambda (buffer _) (unless (get-buffer-window buffer t) (kill-buffer buffer))) compress-view-set)
  (maphash (lambda (buffer _) (unless (get-buffer-window buffer t) (kill-buffer buffer))) compile-set))
(add-hook! 'buffer-list-update-hook #'+amos-buffer-list-update-h)

(defun +amos/decompress-file (&optional file)
  (interactive)
  (let ((encoding (if current-prefix-arg "zh_CN.GBK" "en_US.UTF-8")))
    (let* ((file (or file +amos-compressed-file (dired-get-file-for-visit)))
           (dir (shell-command-to-string (format "LANG=%s dtrx -n %s 2> /dev/null" encoding (shell-quote-argument file)))))
      (unless (string-empty-p dir)
        (dired-jump nil (string-trim-right dir))))))

(define-derived-mode amos-compress-view-mode special-mode "Compress-View")
(set-keymap-parent amos-compress-view-mode-map (make-composed-keymap evil-motion-state-map evil-normal-state-map))
(general-define-key
 :states 'normal
 :keymaps 'amos-compress-view-mode-map
 "i"            nil
 "x"            #'+amos/decompress-file
 "q"            #'kill-this-buffer
 "u"            #'evil-scroll-up
 "d"            #'evil-scroll-down)

(defun +amos-bibtex-completion-format-citation-cite (keys)
  "Formatter for LaTeX citation commands. Prompts for the command
and for arguments if the commands can take any. If point is
inside or just after a citation command, only adds KEYS to it."
  (let (macro)
    (cond
     ((and (require 'reftex-parse nil t)
           (setq macro (reftex-what-macro 1))
           (stringp (car macro))
           (string-match "\\`\\\\cite\\|cite\\'" (car macro)))
      ;; We are inside a cite macro. Insert key at point, with appropriate delimiters.
      (delete-horizontal-space)
      (concat (pcase (preceding-char)
                (?\{ "")
                (?, "")
                (_ ","))
              (s-join "," keys)
              (if (member (following-char) '(?\} ?,))
                  ""
                ",")))
     ((and (equal (preceding-char) ?\})
           (require 'reftex-parse nil t)
           (save-excursion
             (forward-char -1)
             (setq macro (reftex-what-macro 1)))
           (stringp (car macro))
           (string-match "\\`\\\\cite\\|cite\\'" (car macro)))
      ;; We are right after a cite macro. Append key and leave point at the end.
      (delete-char -1)
      (delete-horizontal-space t)
      (concat (pcase (preceding-char)
                (?\{ "")
                (?, "")
                (_ ","))
              (s-join "," keys)
              "}"))
     (t
      (format "~\\cite{%s}" (s-join "," keys))))))

(defun +amos-bibtex-completion-format-ref (key)
  (set-text-properties 0 (length key) nil key)
  (insert
   (let (macro)
     (cond
      ((and (require 'reftex-parse nil t)
            (setq macro (reftex-what-macro 1))
            (stringp (car macro))
            (string-match "\\`\\\\cref\\|cref\\'" (car macro)))
       ;; We are inside a cref macro. Insert key at point, with appropriate delimiters.
       (delete-horizontal-space)
       (concat (pcase (preceding-char)
                 (?\{ "")
                 (?, "")
                 (_ ","))
               key
               (if (member (following-char) '(?\} ?,))
                   ""
                 ",")))
      ((and (equal (preceding-char) ?\})
            (require 'reftex-parse nil t)
            (save-excursion
              (forward-char -1)
              (setq macro (reftex-what-macro 1)))
            (stringp (car macro))
            (string-match "\\`\\\\cref\\|cref\\'" (car macro)))
       ;; We are right after a cref macro. Append key and leave point at the end.
       (delete-char -1)
       (delete-horizontal-space t)
       (concat (pcase (preceding-char)
                 (?\{ "")
                 (?, "")
                 (_ ","))
               key
               "}"))
      (t
       (format "~\\cref{%s}" key))))))

(defun +amos/ivy-reftex ()
  (interactive)
  (require 'bibtex-completion)
  (require 'company-reftex)
  (bibtex-completion-init)
  (let* ((candidates (company-reftex-label-candidates "")))
    (ivy-read "RefTeX entries: "
              candidates
              :caller #'+amos/ivy-reftex
              :action #'+amos-bibtex-completion-format-ref)))

(evil-define-operator +amos/evil-substitute (beg end type)
  "Change a character."
  :motion evil-forward-char
  (interactive "<R>")
  (evil-change beg end type ?_))

(defun +amos-extract-rectangle-line (startcol _ lines)
  (let (start end begextra endextra line)
    (move-to-column startcol)
    (setq start (point)
          begextra (- (current-column) startcol))
    (end-of-line)
    (setq end (point)
          endextra 0)
    (setq line (buffer-substring start (point)))
    (if (< begextra 0)
        (setq endextra (+ endextra begextra)
              begextra 0))
    (if (< endextra 0)
        (setq endextra 0))
    (goto-char start)
    (while (search-forward "\t" end t)
      (let ((width (- (current-column)
                      (save-excursion (forward-char -1)
                                      (current-column)))))
        (setq line (concat (substring line 0 (- (point) end 1))
                           (spaces-string width)
                           (substring line (+ (length line)
                                              (- (point) end)))))))
    (if (or (> begextra 0) (> endextra 0))
        (setq line (concat (spaces-string begextra)
                           line
                           (spaces-string endextra))))
    (setcdr lines (cons line (cdr lines)))))

(defun +amos/xterm-paste (event)
  (interactive "e")
  (if (+amos-insert-state-p)
      (xterm-paste event)
    (let ((uri-list xterm-paste-urllist))
      (unless (and uri-list (+amos-dispatch-uri-list uri-list))
        (with-temp-buffer
          (xterm-paste event)
          (let ((lines (list nil)))
            (evil-apply-on-rectangle #'+amos-extract-rectangle-line (point-min) (point-max) lines)
            (setq lines (nreverse (cdr lines)))
            (let* ((yank-handler (list #'evil-yank-block-handler
                                       lines
                                       t
                                       'evil-delete-yanked-rectangle))
                   (text (propertize (mapconcat #'identity lines "\n")
                                     'yank-handler yank-handler)))
              (evil-set-register ?r text)))
          (evil-set-register ?t (buffer-substring-no-properties (point-min) (point-max))))
        (if (evil-multiedit-state-p)
            (evil-multiedit--delete-occurrences))
        (if current-prefix-arg
            (progn
              (if (and (= 2 current-prefix-arg) (not (evil-visual-state-p)))
                  (forward-char))
              (evil-paste-before nil ?r))
          (evil-paste-before nil ?t))))))

(defun +amos/paste-from-gui ()
  (interactive)
  (if (+amos-insert-state-p)
      (insert-for-yank (gui-get-primary-selection))
    (let ((uri-list
           (condition-case nil
               (x-get-selection-internal 'PRIMARY 'text/uri-list nil nil)
             (error nil))))
      (unless (and uri-list (+amos-dispatch-uri-list uri-list))
        (with-temp-buffer
          (insert-for-yank (gui-get-primary-selection))
          (let ((lines (list nil)))
            (evil-apply-on-rectangle #'+amos-extract-rectangle-line (point-min) (point-max) lines)
            (setq lines (nreverse (cdr lines)))
            (let* ((yank-handler (list #'evil-yank-block-handler
                                       lines
                                       t
                                       'evil-delete-yanked-rectangle))
                   (text (propertize (mapconcat #'identity lines "\n")
                                     'yank-handler yank-handler)))
              (evil-set-register ?r text)))
          (evil-set-register ?t (buffer-substring-no-properties (point-min) (point-max))))
        (if (evil-multiedit-state-p)
            (evil-multiedit--delete-occurrences))
        (if current-prefix-arg
            (progn
              (if (and (= 2 current-prefix-arg) (not (evil-visual-state-p)))
                  (forward-char))
              (evil-paste-before nil ?r))
          (evil-paste-before nil ?t))))))

(defun +amos-get-frame-by-name (fname)
  (require 'dash)
  (-some (lambda (frame)
           (when (equal fname (frame-parameter frame 'name))
             frame))
         (frame-list)))

(after! tex
  (setq-default TeX-master t)
  (setq-default TeX-command-extra-options "-shell-escape"))

(defun +amos*evil-insert (&rest _)
  (evil-insert-state))
(advice-add #'speed-type--setup :after #'+amos*evil-insert)

(eldoc-add-command-completions
 "c-electric-"
 "+amos/backward-"
 "+amos/forward-"
 "+amos/delete-"
 "+amos/complete"
 "evil-insert"
 "evil-append"
 "kill-region"
 "company-"
 )

(defun +amos-evil-yank-a (beg end &optional type register yank-handler)
  "Saves the characters in motion into the kill-ring."
  (interactive
   (let*
       ((evil-operator-range-motion
         (if (evil-has-command-property-p 'evil-yank :motion)
             (or
              (evil-get-command-property 'evil-yank :motion)
              (function undefined))))
        (evil-operator-range-type
         (evil-get-command-property 'evil-yank :type))
        (orig (point))
        evil-operator-range-beginning evil-operator-range-end evil-inhibit-operator)
     (setq evil-inhibit-operator-value nil evil-this-operator this-command)
     (prog1
         (append
          (evil-operator-range t)
          (list evil-this-register
                (evil-yank-handler)))
       (setq orig (point)
             evil-inhibit-operator-value evil-inhibit-operator)
       (if (or (evil-visual-state-p) (region-active-p))
           (setq deactivate-mark t))
       (cond
        ((evil-get-command-property 'evil-yank :move-point)
         (goto-char
          (or evil-operator-range-beginning orig)))
        (t
         (goto-char orig))))))
  (unwind-protect
      (let ((evil-inhibit-operator evil-inhibit-operator-value))
        (unless (and evil-inhibit-operator
                     (called-interactively-p 'any))
          (let
              ((evil-was-yanked-without-register
                (and evil-was-yanked-without-register
                     (not register))))
            (cond
             ((and
               (fboundp 'cua--global-mark-active)
               (fboundp 'cua-copy-region-to-global-mark)
               (cua--global-mark-active))
              (cua-copy-region-to-global-mark beg end))
             ((eq type 'block)
              (evil-yank-rectangle beg end register yank-handler))
             ((eq type 'line)
              (evil-yank-lines beg end register yank-handler))
             (t
              (evil-yank-characters beg end register yank-handler))))))
    (setq evil-inhibit-operator-value nil)))
(advice-add #'evil-yank :override #'+amos-evil-yank-a)

(defun +amos--minibuffer-yank-by (fn &rest args)
  (require 'ivy)
  (let (text)
    (with-selected-window (minibuffer-selected-window)
      (let ((beg (point))
            (bol (line-beginning-position))
            (eol (line-end-position))
            end)
        (unwind-protect
            (progn (apply fn args)
                   (setq end (goto-char (max bol (min (point) eol))))
                   (setq text (buffer-substring-no-properties beg end))
                   (ivy--pulse-region beg end))
          (unless text
            (goto-char beg)))))
    (when text
      (insert (replace-regexp-in-string "  +" " " text t t)))))

(defun +amos/minibuffer-yank-word (&optional arg)
  (interactive "p")
  (+amos--minibuffer-yank-by #'forward-word arg))

;; candidate is (_ _ pos buffer)
(defun +amos/delete-mark ()
  (interactive)
  (defun compare (x y)
    (if (markerp (car x))
        (and (equal (marker-position (car x)) (car y))
             (equal (marker-buffer (car x)) (cadr y)))
      (equal (car x) (cons (car y) (buffer-file-name (cadr y))))))
  (let* ((collection (ivy-state-collection ivy-last))
         (current (ivy-state-current ivy-last))
         (key (cddr (let ((idx (get-text-property 0 'idx current)))
                      (if idx
                          (nth idx collection)
                        (assoc current collection))))))
    (setq +amos-marker-list (--remove (compare it key) +amos-marker-list))
    (project-local-setq +amos-marker-list
                        (--remove (compare it key)
                                  (project-local-getq +amos-marker-list)))
    (let ((cands (+amos-get-mark-cands)))
      (if (not cands)
          (abort-recursive-edit)
        (setf (ivy-state-collection ivy-last) (+amos-get-mark-cands))
        (setf (ivy-state-preselect ivy-last) ivy--index)
        (ivy--reset-state ivy-last)))))

(defun +amos-get-mark-cands ()
  (let* ((all-markers
          (--filter (or (markerp (car it))
                        (file-exists-p (cadar it)))
                    (append (project-local-getq +amos-marker-list) +amos-marker-list)))
         (all-cands
          (mapcar (lambda (m)
                    (with-current-buffer (if (markerp (car m)) (marker-buffer (car m))
                                           (find-file-noselect (cadar m)))
                      (save-excursion
                        (save-restriction
                          (widen)
                          (goto-char (if (markerp (car m)) (marker-position (car m)) (caar m)))
                          (back-to-indentation)
                          (list (format "%s:%-8d   %s"
                                        (buffer-name) (line-number-at-pos) (buffer-substring (point) (line-end-position)))
                                (point)
                                (line-beginning-position)
                                (current-buffer))))))
                  all-markers))
         (-compare-fn (lambda (x y) (string= (nth 0 x) (nth 0 y)))))
    (-distinct all-cands)))

(defun +amos/counsel-view-marks ()
  (interactive)
  (let* ((cands (+amos-get-mark-cands)))
    (if cands
        (let ((buffer (current-buffer))
              (pos (point)))
          (ivy-read "Marks: " cands
                    :require-match t
                    :action (lambda (cand)
                              (let ((pos (nth 1 cand))
                                    (buf (nth 3 cand)))
                                (switch-to-buffer buf)
                                (when pos
                                  (unless (<= (point-min) pos (point-max))
                                    (if widen-automatically
                                        (widen)
                                      (error "Position of selected mark outside accessible part of buffer")))
                                  (goto-char pos))))
                    :unwind (lambda ()
                              (unless success
                                (switch-to-buffer buffer)
                                (goto-char pos)))
                    :caller '+amos/counsel-view-marks))
      (message "Mark ring is empty"))))

(defun +amos-swap-out-markers-h ()
  "Turn markers into file references when the buffer is killed."
  (when buffer-file-name
    (dolist ((car entry) +amos-marker-list)
      (and (markerp (car entry))
           (eq (marker-buffer (car entry)) (current-buffer))
           (setcar entry (cons (marker-position (car entry)) buffer-file-name))))
    (let ((marker-list (project-local-getq +amos-marker-list))
          (modified))
      (dolist (entry marker-list)
        (when (and (markerp (car entry))
                   (eq (marker-buffer (car entry)) (current-buffer)))
          (setcar entry (cons (marker-position (car entry)) buffer-file-name))
          (setq modified t)))
      (if modified
          (project-local-setq +amos-marker-list marker-list)))))

(defvar +amos-marker-list nil)
(defun +amos/push-mark (&optional global)
  (interactive)
  (+amos/recenter)
  (add-hook! 'kill-buffer-hook :local #'+amos-swap-out-markers-h)
  (save-excursion
    (move-beginning-of-line 1)
    (let ((marker-list (if global +amos-marker-list (project-local-getq +amos-marker-list)))
          (-compare-fn (lambda (y x)
                         (if (markerp (car x)) (and (equal (marker-position (car x)) (car y)) (equal (marker-buffer (car x)) (cdr y)))
                           (equal (car x) y)))))
      (when (not (-contains? marker-list (cons (point) (current-buffer))))
        (let ((marker (make-marker)))
          (if global
              (cl-pushnew `(,marker) +amos-marker-list)
            (project-local-setq +amos-marker-list (push `(,marker) marker-list)))
          (set-marker marker (point)))))))

;; do not truncate the last dir
(defun +amos-shrink-path--dirs-internal-a (full-path &optional truncate-all)
  (let* ((home (getenv "HOME"))
         (path (replace-regexp-in-string
                (s-concat "^" home) "~" full-path))
         (split (s-split "/" path 'omit-nulls))
         (split-len (length split))
         shrunk)
    (->> split
         (--map-indexed (if (= it-index (1- split-len))
                            it
                          (shrink-path--truncate it)))
         (s-join "/")
         (setq shrunk))
    (s-concat (unless (s-matches? (rx bos (or "~" "/")) shrunk) "/")
              shrunk
              (unless (s-ends-with? "/" shrunk) "/"))))
(advice-add #'shrink-path--dirs-internal :override #'+amos-shrink-path--dirs-internal-a)

(after! doom-modeline
  (setq doom-modeline-icon nil)
  (setq doom-modeline-buffer-file-name-style 'truncate-with-project)
  (advice-add #'doom-modeline--active :override (lambda () t)))

(evil-define-motion +amos/evil-next-visual-line (count)
  "Move the cursor COUNT screen lines down."
  :type exclusive
  (let ((line-move-visual t)
        (temporary-goal-column))
    (evil-line-move (or count 1))))

(evil-define-motion +amos/evil-previous-visual-line (count)
  "Move the cursor COUNT screen lines up."
  :type exclusive
  (let ((line-move-visual t)
        (temporary-goal-column))
    (evil-line-move (- (or count 1)))))

(defun +amos/swiper-isearch-forward ()
  (interactive)
  (when (timerp swiper--isearch-highlight-timer)
    (cancel-timer swiper--isearch-highlight-timer)
    (setq swiper--isearch-highlight-timer nil))
  (ivy-next-line-or-history))

(defun +amos/swiper-isearch-backward ()
  (interactive)
  (when (timerp swiper--isearch-highlight-timer)
    (cancel-timer swiper--isearch-highlight-timer)
    (setq swiper--isearch-highlight-timer nil))
  (ivy-previous-line-or-history 1))

(setq scratch-file-name (concat "~/.emacs.d/persistent-scratch-" server-name))

(defun +amos-save-persistent-scratch-h ()
  "Write the contents of *scratch* to the file name
`persistent-scratch-file-name'."
  (with-current-buffer (get-buffer-create "*scratch*")
    (let ((inhibit-message t))
      (write-region (point-min) (point-max) scratch-file-name))))

(defun +amos-load-persistent-scratch-h ()
  "Load the contents of `persistent-scratch-file-name' into the
  scratch buffer, clearing its contents first."
  (if (file-exists-p scratch-file-name)
      (with-current-buffer (get-buffer "*scratch*")
        (delete-region (point-min) (point-max))
        (insert-file-contents scratch-file-name))))

(add-hook! 'after-init-hook '+amos-load-persistent-scratch-h)
(add-hook! 'kill-emacs-hook '+amos-save-persistent-scratch-h)
(if (not (boundp 'my/save-persistent-scratch-timer))
    (setq my/save-persistent-scratch-timer (run-with-idle-timer 300 t '+amos-save-persistent-scratch-h)))

(defun +amos/count-buffers (&optional display-anyway)
  "Display or return the number of buffers."
  (interactive)
  (let ((buf-count (length (buffer-list))))
    (if (or (interactive-p) display-anyway)
        (message "%d buffers in this Emacs" buf-count)) buf-count))

(defun +amos/revert-buffer ()
  (interactive)
  (revert-buffer :ignore-auto (not (buffer-modified-p))))

(defun +amos/revert-all-buffers ()
  "Refresh all open buffers from their respective files."
  (interactive)
  (dolist (buffer (buffer-list))
    (let ((filename (buffer-file-name buffer)))
      (if (or (eq 'dired-mode (buffer-local-value 'major-mode buffer))
              (and filename
                   (file-exists-p filename)
                   (not (verify-visited-file-modtime))))
          (with-demoted-errors "Error: %S"
            (with-current-buffer buffer
              (+amos/revert-buffer)))))))

;; important! to make keymap take effect
(after! edebug
  (add-hook! 'edebug-mode-hook #'evil-normalize-keymaps))
(after! magit-files
  (add-hook! 'magit-blob-mode-hook #'evil-normalize-keymaps))

;; (setq-local +amos-window-start nil)
;; (add-hook! 'minibuffer-setup-hook #'+amos|record-window-start)
;; (add-hook! 'minibuffer-exit-hook #'+amos|restore-window-start)

;; (defun +amos|record-window-start ()
;;   (let ((windows (window-list)))
;;     (dolist (window windows)
;;       (let ((buffer (window-buffer (car windows))))
;;         (unless (minibufferp buffer)
;;           (with-current-buffer buffer
;;             (setq-local +amos-window-start (window-start))))))))

;; (defun +amos|restore-window-start ()
;;   (let ((windows (window-list)))
;;     (dolist (window windows)
;;       (let ((buffer (window-buffer (car windows))))
;;         (unless (minibufferp buffer)
;;           (with-current-buffer buffer
;;             (set-window-start +amos-window-start)))))))

(defun +amos-xterm--pasted-text-a ()
  "Handle the rest of a terminal paste operation.
Return the pasted text as a string."
  (let ((end-marker-length (length xterm-paste-ending-sequence)))
    (with-temp-buffer
      (set-buffer-multibyte nil)
      (while (not (search-backward xterm-paste-ending-sequence
                                   (- (point) end-marker-length) t))
        (let ((event (read-event nil nil
                                 ;; Use finite timeout to avoid glomming the
                                 ;; event onto this-command-keys.
                                 most-positive-fixnum)))
          (when (eql event ?\r)
            (setf event ?\n))
          (insert event)))
      (let* ((last-coding-system-used)
             (text (decode-coding-region (point-min) (point) (keyboard-coding-system) t)))
        (if (string= "\e[290~" (this-command-keys))
            (setq xterm-paste-urllist text)
          (setq xterm-paste-urllist nil)
          text)))))

(advice-add #'xterm--pasted-text :override #'+amos-xterm--pasted-text-a)
(after! xterm
  (define-key xterm-rxvt-function-map "\e[290~" #'xterm-translate-bracketed-paste))

(defun +amos/make-ignore ()
  (interactive)
  (shell-command! "makeignore")
  (setq projectile-project-root nil)
  (setq projectile-project-root-cache (make-hash-table :test 'equal)))

(defun +amos*yes (&rest _) t)

(defvar-local +amos-git-timemachine-revision nil)
(defvar-local +amos-git-timemachine-file nil)
(defvar-local +amos-git-timemachine--revisions-cache nil)

(defun +amos-git-timemachine--revisions (default-directory file)
  (with-temp-buffer
    (unless (zerop (git-timemachine--process-file "log" "--name-only" "--follow" "--pretty=format:%H%x00%ar%x00%ad%x00%s%x00%an" "--" file))
      (error "Git log command exited with non-zero exit status for file: %s" file))
    (goto-char (point-min))
    (let ((lines)
          (commit-number (/ (1+ (count-lines (point-min) (point-max))) 3)))
      (while (not (eobp))
        (let ((line (buffer-substring-no-properties (line-beginning-position) (line-end-position))))
          (string-match "\\([^\0]*\\)\0\\([^\0]*\\)\0\\([^\0]*\\)\0\\(.*\\)\0\\(.*\\)" line)
          (let ((commit (match-string 1 line))
                (date-relative (match-string 2 line))
                (date-full (match-string 3 line))
                (subject (match-string 4 line))
                (author (match-string 5 line)))
            (forward-line 1)
            (let ((file-name (buffer-substring-no-properties (line-beginning-position) (line-end-position))))
              (push (list commit file-name commit-number date-relative date-full subject author) lines))))
        (setq commit-number (1- commit-number))
        (forward-line 2))
      (nreverse lines))))

(defun +amos/git-timemachine-ediff-current-revision ()
  (interactive)
  (require 'magit)
  (require 'git-timemachine)
  (+amos-git-timemachine-validate (buffer-file-name))
  (let* ((git-directory (expand-file-name (vc-git-root (buffer-file-name))))
         (file-name (magit-file-relative-name))
         (cache (+amos-git-timemachine--revisions git-directory (buffer-file-name))))
    (+amos-git-timemachine-ediff-revision (car cache) cache file-name)))

(defun +amos-git-timemachine-ediff-revision (revision-log &optional cache file-name)
  (lexical-let ((cache (or cache +amos-git-timemachine--revisions-cache))
                (file-name (or file-name +amos-git-timemachine-file))
                (revision-log revision-log))
    (defun +amos|ediff-startup-hook ()
      (setq
       +amos-git-timemachine--revisions-cache cache
       +amos-git-timemachine-file file-name
       +amos-git-timemachine-revision revision-log)
      (remove-hook 'ediff-startup-hook #'+amos|ediff-startup-hook))
    (add-hook 'ediff-startup-hook #'+amos|ediff-startup-hook)
    (if (eq major-mode 'ediff-mode)
        (cl-letf (((symbol-function 'y-or-n-p) #'+amos*yes)
                  ((symbol-function 'yes-or-no-p) #'+amos*yes))
          (ediff-quit nil)))
    (magit-ediff-compare (car revision-log) nil file-name file-name)))

(defun +amos-git-timemachine--next-revision (revisions)
  (or (cadr (cl-member (car +amos-git-timemachine-revision) revisions :key #'car :test #'string=))
      (car (reverse revisions))))

(defun +amos-git-timemachine-show-revision-a (revision)
  (when revision
    (let ((current-position (point))
          (commit (car revision))
          (revision-file-name (nth 1 revision))
          (commit-index (nth 2 revision))
          (date-relative (nth 3 revision))
          (date-full (nth 4 revision))
          (subject (nth 5 revision))
          (old-size (buffer-size)))
      (setq buffer-read-only nil)
      (setq inhibit-modification-hooks t)
      (run-hook-with-args 'before-change-functions (point-min) (point-max))
      (erase-buffer)
      (let ((default-directory git-timemachine-directory)
            (process-coding-system-alist (list (cons "" (cons buffer-file-coding-system default-process-coding-system)))))
        (git-timemachine--process-file "show" (concat commit ":" revision-file-name)))
      (run-hook-with-args 'after-change-functions (point-min) (point-max) old-size)
      (setq inhibit-modification-hooks nil)
      (setq buffer-read-only t)
      (set-buffer-modified-p nil)
      (let* ((revisions (git-timemachine--revisions))
             (n-of-m (format "(%d/%d %s)" commit-index (length revisions) date-relative)))
        (setq mode-line-buffer-identification
              (list (propertized-buffer-identification "%12b") "@"
                    (propertize (git-timemachine-abbreviate commit) 'face 'git-timemachine-commit) " name:" revision-file-name" " n-of-m)))
      (setq git-timemachine-revision revision)
      (goto-char current-position)
      (when git-timemachine-show-minibuffer-details
        (git-timemachine--show-minibuffer-details revision))
      (git-timemachine--erm-workaround))))
(advice-add #'git-timemachine-show-revision :override #'+amos-git-timemachine-show-revision-a)

(defun +amos/ediff-previous-revision ()
  (interactive)
  (let ((curr-revision +amos-git-timemachine-revision)
        (new-revision (+amos-git-timemachine--next-revision +amos-git-timemachine--revisions-cache)))
    (+amos-git-timemachine-ediff-revision new-revision)))

(defun +amos/ediff-next-revision ()
  (interactive)
  (let ((curr-revision +amos-git-timemachine-revision)
        (new-revision (+amos-git-timemachine--next-revision (reverse +amos-git-timemachine--revisions-cache))))
    (+amos-git-timemachine-ediff-revision new-revision)))

(defun +amos-git-timemachine-validate (file)
  (unless file
    (error "This buffer is not visiting a file"))
  (unless (vc-git-registered file)
    (error "This file is not git tracked")))

(defun +amos/ediff-copy-A-to-C (ofun &rest args)
  (interactive "P")
  (mkr! (apply ofun args)))
(advice-add #'ediff-copy-A-to-C :around #'+amos/ediff-copy-A-to-C)

(defun +amos/ediff-copy-B-to-C (ofun &rest args)
  (interactive "P")
  (mkr! (apply ofun args)))
(advice-add #'ediff-copy-B-to-C :around #'+amos/ediff-copy-B-to-C)

(defun +amos/ediff-restore-diff-in-merge-buffer (ofun &rest args)
  (interactive "P")
  (mkr! (apply ofun args)))
(advice-add #'ediff-restore-diff-in-merge-buffer :around #'+amos/ediff-restore-diff-in-merge-buffer)


(defun +amos/ediff-copy-both-to-C ()
  (interactive)
  (mkr!
   (ediff-copy-diff ediff-current-difference nil 'C nil
                    (concat
                     (ediff-get-region-contents ediff-current-difference 'A ediff-control-buffer)
                     (ediff-get-region-contents ediff-current-difference 'B ediff-control-buffer)))))

(after! ediff
  (add-hook! 'ediff-keymap-setup-hook
    (define-key ediff-mode-map "k" #'ediff-previous-difference)
    (define-key ediff-mode-map "j" #'ediff-next-difference)
    (define-key ediff-mode-map "c" #'+amos/ediff-copy-both-to-C)
    (define-key ediff-mode-map "K" #'+amos/ediff-previous-revision)
    (define-key ediff-mode-map "J" #'+amos/ediff-next-revision)
    ))

(defun +amos*flycheck-error-line-region (err)
  (flycheck-error-with-buffer err
    (save-restriction
      (save-excursion
        (widen)
        (goto-char (point-min))
        (forward-line (- (flycheck-error-line err) 1))
        (let ((end (line-end-position)))
          (skip-syntax-forward " " end)
          (backward-prefix-chars)
          (cons (point) (if (eolp) (+ 1 end) end)))))))

(defun +amos*flycheck-error-column-region (err)
  (flycheck-error-with-buffer err
    (save-restriction
      (save-excursion
        (-when-let (column (flycheck-error-column err))
          (widen)
          (goto-char (point-min))
          (forward-line (- (flycheck-error-line err) 1))
          (cond
           ((eobp)                    ; Line beyond EOF
            (cons (- (point-max) 1) (point-max)))
           ((eolp)                    ; Empty line
            nil)
           (t
            (let ((end (min (+ (point) column)
                            (+ (line-end-position) 1))))
              (cons (- end 1) end)))))))))

(advice-add #'flycheck-error-line-region :override #'+amos*flycheck-error-line-region)
(advice-add #'flycheck-error-column-region :override #'+amos*flycheck-error-column-region)

(defun +amos/yank-flycheck-error ()
  (interactive)
  (catch 'return
    (let ((overlays (overlays-at (point))))
      (cl-loop for overlay in overlays
               do (when-let (str (overlay-get overlay 'flycheck-error))
                    (kill-new (flycheck-error-message str))
                    (throw 'return nil)))
      (cl-loop for overlay in overlays
               do (when-let (str (overlay-get overlay 'flycheck-warning))
                    (kill-new (flycheck-error-message str))
                    (throw 'return nil))))))

(defvar project-local--obarrays nil
  "Plist of obarrays for each project.")

(defvar project-local--cache nil
  "Cons of project and obarray currently used.
This avoid to search the obarray in `project-local--obarrays' on every request.")

(defun project-local--get-obarray-1 (project)
  (if (plist-member project-local--obarrays project)
      (plist-get project-local--obarrays project)
    (let ((obarray (make-vector 32 0)))
      (setq project-local--obarrays (plist-put project-local--obarrays project obarray))
      obarray)))

(defun project-local--get-obarray (project)
  "Return the obarray associated to PROJECT.
If there is no obarray and CREATE is non-nil, a new obarray is created."
  (setq project (or project (doom-project-root) "global"))
  (if (eq project (car project-local--cache))
      (cdr project-local--cache)
    (let ((obarray (project-local--get-obarray-1 project)))
      (setq project-local--cache (cons project obarray))
      obarray)))

(defun project-local-set (name value &optional project)
  "Set the symbol NAME's value to VALUE in PROJECT.
If PROJECT is nil, set the symbol in the current project.
Return VALUE."
  (let* ((obarray (project-local--get-obarray project))
         (sym (intern (symbol-name name) obarray)))
    (set sym value)))

(defun project-local-get (name &optional project)
  "Return symbol NAME's value in PROJECT.
Or in the current project if PROJECT is nil."
  (let* ((obarray (project-local--get-obarray project)))
    (symbol-value (intern-soft (symbol-name name) obarray))))

(defmacro project-local-setq (name value &optional project)
  "Similar to `project-local-set' but NAME must not be quoted.
See `project-local-set' for the parameters VALUE and PROJECT."
  `(project-local-set ',name ,value ,project))

(defmacro project-local-getq (name &optional project)
  "Similar to `project-local-get' but NAME must not be quoted.
See `project-local-get' for the parameter PROJECT."
  `(project-local-get ',name ,project))

;; invalide cache?
(defun project-local--on-delete (project)
  "Delete the obarray associated to PROJECT, if any."
  (when (and (projectp project)
             (plist-member project-local--obarrays project))
    (let ((obarray (plist-get project-local--obarrays project)))
      (setq project-local--obarrays
            (delq project (delq obarray project-local--obarrays))))))

(defun +amos-kill-buffer-a (orig-func &rest args)
  (interactive)
  (if server-buffer-clients
      (cl-letf* (((symbol-function 'y-or-n-p) #'+amos*yes))
        (apply orig-func args))
    (apply orig-func args)))
(advice-add #'kill-buffer :around #'+amos-kill-buffer-a)

(defun +amos-server-switch-h ()
  (when (string= "emacs-editor" (frame-parameter nil 'name))
    (when (current-local-map)
      (use-local-map (copy-keymap (current-local-map))))
    (when server-buffer-clients
      (setq display-line-numbers 'relative)
      (setq-local require-final-newline nil)
      (local-set-key (kbd "C-c C-c")
                     (lambda!
                      (evil-normal-state)
                      (cl-letf (((symbol-function 'y-or-n-p) #'+amos*yes)
                                ((symbol-function 'y-or-n-p-with-timeout) #'+amos*yes)
                                ((symbol-function 'map-y-or-n-p) #'+amos*yes)
                                ((symbol-function 'yes-or-no-p) #'+amos*yes))
                        (call-interactively #'server-edit))))
      (local-set-key (kbd "C-c C-k")
                     (lambda!
                      (evil-normal-state)
                      (cl-letf (((symbol-function 'y-or-n-p) #'+amos*yes)
                                ((symbol-function 'y-or-n-p-with-timeout) #'+amos*yes)
                                ((symbol-function 'map-y-or-n-p) #'+amos*yes)
                                ((symbol-function 'yes-or-no-p) #'+amos*yes))
                        (call-interactively #'delete-frame)))))))
(add-hook! 'server-switch-hook #'+amos-server-switch-h)

(defun +amos-server-visit-h ()
  (when (or (string= "emacs-editor" (frame-parameter nil 'name))
            (string= "popup" (frame-parameter nil 'name)))
    (setq-local server-visit-file t)))
(add-hook! 'server-visit-hook #'+amos-server-visit-h)

(after! latex
  ;; (remove-hook 'TeX-mode-hook #'visual-line-mode)
  (dolist (env '("itemize" "enumerate" "description"))
    (delete `(,env +latex/LaTeX-indent-item) LaTeX-indent-environment-list)))

(setq-default whitespace-style '(face tabs tab-mark trailing))

(setq whitespace-display-mappings
      '(
        (space-mark   ?\     [?·]     [?.])		; space - middle dot
        (space-mark   ?\xA0  [?¤]     [?_])		; hard space - currency sign
        (newline-mark ?\n    [?$ ?\n])			; eol - dollar sign
        )
      )

;; TODO font face for space characters?
(defun +amos*whitespace-space-after-tab-regexp (&optional kind)
  (format (car whitespace-space-after-tab-regexp) 1))
(advice-add #'whitespace-space-after-tab-regexp :override #'+amos*whitespace-space-after-tab-regexp)

(defun prevent-whitespace-mode-for-magit ()
  (not (derived-mode-p 'magit-mode)))
(after! whitespace
  (add-function :before-while whitespace-enable-predicate 'prevent-whitespace-mode-for-magit))
(global-whitespace-mode +1)

(advice-add #'doom-highlight-non-default-indentation-h :override #'ignore)

(defun +amos/upload-wandbox ()
  (interactive)
  (let ((url (string-trim-right (shell-command-to-string "wandbox . snippet.cpp"))))
    (kill-new url)
    (osc-command "notify-send OSC52Command '\nWandBox Uploaded'")))

(defun +amos/swiper-isearch-backward ()
  (interactive)
  (let ((i (- ivy--index 1))
        (min-index 0)
        (cands  ivy--old-cands)
        (current (ivy-state-current ivy-last)))
    (with-current-buffer (ivy-state-buffer ivy-last)
      (while (and (>= i 0)
                  (swiper--isearch-same-line-p
                   (swiper--line-at-point (nth i cands))
                   (swiper--line-at-point current)))
        (cl-decf i)))
    (if (< i min-index)
        (if ivy-wrap
            (ivy-end-of-buffer)
          (ivy-set-index min-index))
      (ivy-set-index i))))

(defun +amos/swiper-isearch-forward ()
  (interactive)
  (let ((i (+ ivy--index 1))
        (max-index (1- ivy--length))
        (cands  ivy--old-cands)
        (current (ivy-state-current ivy-last)))
    (with-current-buffer (ivy-state-buffer ivy-last)
      (while (and (< i ivy--length)
                  (swiper--isearch-same-line-p
                   (swiper--line-at-point (nth i cands))
                   (swiper--line-at-point current)))
        (cl-incf i))
      (if (> i max-index)
          (if ivy-wrap
              (ivy-beginning-of-buffer)
            (ivy-set-index max-index))
        (ivy-set-index i)))))

(defun +amos-ediff-copy-diff-a (func &rest args)
  (mkr! (apply func args)))
(advice-add #'ediff-copy-diff :around #'+amos-ediff-copy-diff-a)

;; (use-package! lsp-python-ms
;;   :hook (python-mode . lsp)
;;   :config
;;   ;; for dev build of language server
;;   (setq lsp-python-ms-dir
;;         (expand-file-name "~/git/python-language-server/output/bin/release/"))
;;   ;; for executable of language server, if it's not symlinked on your PATH
;;   (setq lsp-python-ms-executable
;;         "~/git/python-language-server/output/bin/release/Microsoft.Python.LanguageServer"))

;; (setq font-lock-maximum-decoration '((c-mode . 1) (c++-mode . 1) (t . t)))

(defun +amos-set-evil-move-beyond-eol-nil-h (&rest _)
  (setq evil-move-beyond-eol nil)
  (evil-adjust-cursor)
  (advice-remove #'flycheck-perform-deferred-syntax-check #'+amos-set-evil-move-beyond-eol-nil-h))

(defun +amos/flycheck-next-error ()
  (interactive)
  (setq evil-move-beyond-eol t)
  (call-interactively #'flycheck-next-error)
  (advice-add #'flycheck-perform-deferred-syntax-check :after #'+amos-set-evil-move-beyond-eol-nil-h))

(defun +amos/flycheck-previous-error ()
  (interactive)
  (setq evil-move-beyond-eol t)
  (call-interactively #'flycheck-previous-error)
  (advice-add #'flycheck-perform-deferred-syntax-check :after #'+amos-set-evil-move-beyond-eol-nil-h))

(defun +amos-flycheck-display-error-at-point-soon-a ()
  (when (flycheck-overlays-at (point))
    (with-demoted-errors "Flycheck error display error: %s"
      (when flycheck-mode
        (-when-let (errors (flycheck-overlay-errors-at (point)))
          (flycheck-display-errors errors))))))
(advice-add #'flycheck-display-error-at-point-soon :override #'+amos-flycheck-display-error-at-point-soon-a)

(defun +amos-ivy-scroll-up-command-a ()
  "Scroll the candidates upward by the minibuffer height."
  (interactive)
  (let ((cand (1- (+ ivy--index ivy-height))))
    (ivy-set-index (if (/= ivy--index (1- ivy--length)) (min (1- ivy--length) cand)
                     (if ivy-wrap 0 (1- ivy--length))))))
;; (advice-add #'ivy-scroll-up-command :override #'+amos-ivy-scroll-up-command-a)

(defun +amos-ivy-scroll-down-command-a ()
  "Scroll the candidates downward by the minibuffer height."
  (interactive)
  (let ((cand (1+ (- ivy--index ivy-height))))
    (ivy-set-index (if (/= 0 ivy--index) (max 0 cand)
                     (if ivy-wrap (1- ivy--length) 0)))))
;; (advice-add #'ivy-scroll-down-command :override #'+amos-ivy-scroll-down-command-a)

(defun +amos-git-link (cand)
  (cl-destructuring-bind (remote branch) (split-string cand "~")
    (let ((git-link-default-remote remote)
          (git-link-default-branch branch))
      (call-interactively #'git-link))))

(defun +amos/git-link ()
  (interactive)
  (require 'git-link)
  (let ((l (split-string (string-trim-right (shell-command-to-string "gittrackedremote")) "\n")))
    (if (< (length l) 2)
        (--map (+amos-git-link it) l)
      (ivy-read "Remote branch: " (split-string (shell-command-to-string "gittrackedremote") "\n")
                :action (lambda (cand)
                          (cl-destructuring-bind (remote branch) (split-string cand "~")
                            (let ((git-link-default-remote remote)
                                  (git-link-default-branch branch))
                              (call-interactively #'git-link))))
                :caller '+amos/git-link))))

(defun +amos/yank-pop()
  (interactive)
  (let ((kill-ring my-kill-ring))
    (if (eq last-command 'yank)
        (yank-pop)
      (yank))))

(use-package! rmsbolt
  :defer
  :config
  (add-hook! 'rmsbolt-mode-hook (setq-local rmsbolt-command (shell-command-to-string "printf \"%s %s\" \"$CXX\" \"$CXXFLAGS\""))))

(use-package! centered-cursor-mode
  :defer)

(defun +amos-swiper-isearch-a (orig-fn &rest args)
  "Don't look into .authinfo for local sudo TRAMP buffers."
  (let (evil-ex-search-persistent-highlight)
    (apply orig-fn args)))
(advice-add #'swiper-isearch :around #'+amos-swiper-isearch-a)

(defmacro leapify! (command)
  `(progn
     (defun ,(intern (concat "+amos-" (symbol-name command) "-a")) (orig-func &rest args)
       (let ((origin (point-marker)))
         (apply orig-func args)
         (unless (equal (point-marker) origin)
           (with-current-buffer (marker-buffer origin)
             (leap-set-jump origin)))))
     (advice-add #',command :around #',(intern (concat "+amos-" (symbol-name command) "-a")))))

(leapify! goto-last-change)
(leapify! evil-insert-resume)

(electric-indent-mode -1)

(defun +amos/google-translate ()
  (interactive)
  (require 'google-translate)
  (require 'google-translate-smooth-ui)
  (setq google-translate-translation-direction-query
        (if (use-region-p)
            (google-translate--strip-string
             (buffer-substring-no-properties (region-beginning) (region-end)))
          (buffer-substring-no-properties (line-beginning-position) (line-end-position))))
  (setq google-translate-current-translation-direction 0)
  (let* (
         ;; (text (google-translate-query-translate-using-directions)) ;;
         (text google-translate-translation-direction-query) ;;
         (source-language (google-translate--current-direction-source-language))
         (target-language (google-translate--current-direction-target-language)))
    (when (null source-language)
      (setq source-language (google-translate-read-source-language)))
    (when (null target-language)
      (setq target-language (google-translate-read-target-language)))
    (let* ((json (google-translate-request source-language target-language text)))
      (if (null json) (message "Nothing to translate.")
        (let* ((detailed-translation
                (google-translate-json-detailed-translation json))
               (detailed-definition
                (google-translate-json-detailed-definition json))
               (translation (google-translate-json-translation json)))
          (when (use-region-p)
            (goto-char (region-end))
            (evil-normal-state))
          (evil-insert-newline-below)
          (evil-insert-newline-below)
          (save-excursion
            (insert translation)))))))

(defun +amos-ignore-repeat (&rest names)
  (dolist (name names)
    (dolist (command (all-completions name obarray 'commandp))
      (evil-declare-ignore-repeat (intern command)))))

(remove-hook 'text-mode-hook #'auto-fill-mode)

;; should be at last
(+amos-ignore-repeat
 "+amos/align"
 "+amos/all-substitute"
 "+amos/avy"
 "+amos/counsel"
 "+amos/decrease-zoom"
 "+amos/dired"
 "+amos/direnv-reload"
 "+amos/dump-evil-jump-list"
 "+amos/exec-shell-command"
 "+amos/format-buffer"
 "+amos/flycheck"
 "+amos/increase-zoom"
 "+amos/kill-current-buffer"
 "+amos/launch"
 "+amos/line-substitute"
 "+amos/lsp"
 "+amos/maybe-add-end-of-statement"
 "+amos/other-window"
 "+amos/paste-from-gui"
 "+amos/projectile"
 "+amos/redisplay-and-recenter"
 "+amos/region-substitute"
 "+amos/rename-current-buffer-file"
 "+amos/replace"
 "+amos/reset"
 "+amos/revert"
 "+amos/shell"
 "+amos/smart-jumper"
 "+amos/swiper"
 "+amos/switch-buffer"
 "+amos/tmux"
 "+amos/toggle-mc"
 "+amos/wipe-current-buffer"
 "+amos/workspace"
 "+amos/yank"
 "+eval/buffer"
 "+eval/region-and-replace"
 "+evil:delete-this-file"
 "cc-playground"
 "ccls"
 "counsel"
 "dired"
 "direnv"
 "doom/sudo-this-file"
 "doom/toggle-fullscreen"
 "easy-hugo"
 "editorconfig-find-current-editorconfig"
 "eval-defun"
 "evil-commentary-line"
 "evil-multiedit"
 "evil-next-line"
 "evil-previous-line"
 "+amos/evil-previous-visual-line"
 "+amos/evil-next-visual-line"
 "execute-extended-command"
 "find-file"
 "flycheck"
 "git-gutter"
 "git-timemachine"
 "highlight-indentation-"
 "ivy-resume"
 "lsp"
 "magit"
 "move-text"
 "pp-eval-last-sexp"
 "rainbow"
 "rotate-text"
 "save-buffer"
 "split-window"
 "switch-to-buffer"
 "toggle-truncate-lines"
 "undo-tree"
 "vc-revert"
 "whitespace-mode"
 "yasdcv-translate-at-point"
 "zygospore-toggle-delete-other-windows")
