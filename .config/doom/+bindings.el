;;; private/amos/+bindings.el -*- lexical-binding: t; -*-

(map!
 :g "<f12>"          (lambda! (evil-refresh-cursor) (realign-windows) (+amos/update-tmux-modeline)) ; also used to refresh terminal frames
 :g "M-x"            #'execute-extended-command
 :g "<f1>"           (lambda! (text-scale-set 0))
 :g "<f2>"           (lambda! (text-scale-increase 0.5))
 :g "<f3>"           (lambda! (text-scale-decrease 0.5))
 :g "M-w"            #'evil-wipeout-buffer
 :n "M-m"            #'evil-switch-to-windows-last-buffer
 :n "M-a"            #'+amos/mark-whole-buffer
 :n "M-g"            #'+amos/counsel-jumpdir-function
 :i "M-i"            #'yas-insert-snippet
 :n "M-,"            #'flycheck-previous-error
 :n "M-."            #'flycheck-next-error
 :n "M-p"            #'evil-multiedit-match-symbol-and-prev
 :n "M-n"            #'evil-multiedit-match-symbol-and-next
 :i "M-n"            #'next-line
 :i "M-p"            #'previous-line
 :m "N"              #'evil-ex-search-previous
 :m "E"              #'+amos/evil-forward-subword-end
 :m "B"              #'+amos/evil-backward-subword-begin
 :ni "M-b"           #'+amos/backward-word-insert
 :ni "M-B"           (lambda! (+amos/backward-word-insert t))
 :ni "M-f"           #'+amos/forward-word-insert
 :ni "M-F"           (lambda! (+amos/forward-word-insert t))
 :ni "M-d"           #'+amos/forward-delete-word
 :ni "M-D"           (lambda! (+amos/forward-delete-word t))
 :ni [M-backspace]   #'+amos/backward-delete-word
 :ni [134217855]     #'+amos/backward-delete-word ; M-DEL
 :ni "<f7>"          (lambda! (+amos/backward-delete-word t))
 :i "DEL"            #'+amos/backward-delete-char
 :i "C-w"            #'+amos/backward-delete-word
 :i "M-r"            #'sp-slurp-hybrid-sexp
 :i "M-R"            #'sp-forward-barf-sexp
 :n "M-e"            #'counsel-dash-at-point
 :n "M-i"            #'yasdcv-translate-at-point
 :v "M-i"            #'+amos/evil-visual-insert-snippet
 :n "M-o"            #'evil-open-folds
 :n "M-O"            #'evil-close-folds
 :n "M-h"            #'evil-window-left
 :n "M-j"            #'evil-window-down
 :n "M-k"            #'evil-window-up
 :n "M-l"            #'evil-window-right
 :n "C-p"            #'+amos/counsel-projectile-switch-project
 :n "C-f"            #'counsel-file-jump
 :n "C-l"            #'+amos/redisplay-and-recenter
 :n "C-s"            #'swiper
 :n "<f4>"           #'counsel-projectile-rg
 :n "C-S-s"          #'counsel-projectile-rg
 :n "<f5>"           #'+amos/counsel-rg-cur-dir
 :n "C-S-d"          #'+amos/counsel-rg-cur-dir
 :n "C-y"            #'+amos/yank-buffer-filename-with-line-position
 :i "C-y"            (lambda! (let ((kill-ring my-kill-ring)) (yank)))
 :i "M-y"            (lambda! (let ((kill-ring my-kill-ring)) (yank-pop)))
 :m "C-w"            #'bury-buffer
 :i "C-a"            #'evil-beginning-of-line
 :n "C-a"            #'evil-numbers/inc-at-pt
 :v "C-a"            #'+amos/ca
 :v "g C-a"          #'+amos/gca
 :i [remap newline]  #'newline-and-indent
 :n "C-e"            #'+amos/maybe-add-end-of-statement
 :i "C-e"            #'+amos/smart-eol-insert
 :i "M-e"            #'+amos/smart-eol-insert
 :i "C-u"            #'+amos/backward-kill-to-bol-and-indent
 :i "C-o"            #'+amos/kill-line
 :i "C-n"            #'next-line
 :i "C-p"            #'previous-line
 :i "C-d"            #'+amos/delete-char
 :n "C-j"            #'move-text-down
 :n "C-k"            #'move-text-up
 :n "C-SPC"          #'+amos/other-window
 :i "C-SPC"          #'+amos/complete
 :i "C-j"            #'company-dabbrev-code
 :v "R"              #'evil-multiedit-match-all
 :n "!"              #'rotate-text
 :v "H"              #'+amos/align-repeat-left
 :v "L"              #'+amos/align-repeat-right
 :v "u"              #'undo-tree-undo
 :v "C-r"            #'undo-tree-redo
 :n "s"              #'evil-substitute
 :n "S"              #'evil-change-whole-line
 :v "s"              #'evil-surround-region
 :v "S"              #'evil-substitute
 :o "s"              #'evil-surround-edit
 :v "v"              #'er/expand-region
 :v "V"              #'er/contract-region
 :n "p"              #'+amos@paste/evil-paste-after
 :n "P"              #'+amos@paste/evil-paste-before
 :m "("              #'+amos/smart-jumper-backward
 :m ")"              #'+amos/smart-jumper-forward
 :v "<"              #'+evil/visual-dedent
 :v ">"              #'+evil/visual-indent
 :v "@"              #'+evil:macro-on-all-lines
 :n "g@"             #'+evil:macro-on-all-lines
 :n "gx"             #'evil-exchange
 :n "gf"             #'+amos/evil-find-file-at-point-with-line
 :n "gd"             #'+lookup/definition
 :n "go"             #'+amos/evil-insert-line-below
 :n "gO"             #'+amos/evil-insert-line-above
 :n "gp"             #'+evil/reselect-paste
 :n "gr"             #'+lookup/references
 :n "gR"             #'cquery/callers
 :v "gR"             #'+eval:replace-region
 :m "gy"             #'evil-commentary-yank
 :m "gc"             #'evil-commentary
 :m "gl"             #'evil-commentary-line
 :n ",,"             #'+amos/projectile-find-other-file

 (:prefix "C-x"
   :g "1"       #'zygospore-toggle-delete-other-windows
   :g "e"       #'pp-eval-last-sexp
   :g "d"       #'+amos/direnv-reload
   :g "a"       #'direnv-edit
   :g "C-r"     #'+amos/replace-last-sexp
   :i "C-l"     #'+company/whole-lines
   :i "C-k"     #'+company/dict-or-keywords
   :i "C-f"     #'company-files
   :i "C-n"     #'company-dabbrev-code
   :i "C-p"     #'+company/dabbrev-code-previous
   :g "u"       #'link-hint-open-link
   :g "c"       #'+amos/tmux-new-window
   :g "k"       #'+amos/tmux-kill-window
   :g "o"       #'+amos/tmux-fork-window
   :g "r"       #'+amos/tmux-source
   :g "C-c"     #'+amos/tmux-detach
   :g "p"       #'doom/other-popup)

 (:prefix "C-c"
   "C-SPC" #'easy-hugo)

 (:prefix "SPC"
   :desc "Switch buffer"                   :nv "SPC" #'ivy-switch-buffer
   :desc "Find file in project"            :nv "."   #'+amos/projectile-find-file
   :desc "Find file in project (no cache)" :nv ">"   (lambda! (projectile-invalidate-cache nil) (projectile-find-file))
   :desc "Find recent file"                :nv ","   #'counsel-recentf
   :desc "Find recent file (no cache)"     :nv "<"   (lambda! (recentf-cleanup) (counsel-recentf))
   :desc "Shell command"                   :nv "e"   #'shell-command
   :desc "Blink cursor line"               :nv "DEL" #'doom/open-scratch-buffer
   :desc "Elisp command"                   :nv "RET" #'eval-expression
   :desc "Ivy resume"                      :nv "r"   #'ivy-resume
   :desc "Universal argument"              :nv "u"   #'universal-argument
   :desc "Save current file"               :nv "w"   #'save-buffer
   :desc "Next diff hunk"                  :nv "j"   #'git-gutter:next-hunk
   :desc "Previous diff hunk"              :nv "k"   #'git-gutter:previous-hunk
   :desc "Switch workspace buffer"         :nv "b"   #'switch-to-buffer

   (:desc "file" :prefix "f"
     :desc "File file"                     :nv "f" #'find-file
     :desc "Open project editorconfig"     :nv "c" #'editorconfig-find-current-editorconfig
     :desc "Delete current file"           :nv "D" #'+evil:delete-this-file
     :desc "Browse emacs.d"                :nv "E" #'doom/sudo-this-file
     :desc "Recent files"                  :nv "r" #'recentf-open-files
     :desc "Recent project files"          :nv "R" #'+amos/rename-current-buffer-file
     :desc "Yank filename"                 :nv "y" #'+amos/yank-buffer-filename
     :desc "Yank filename"                 :nv "Y" #'+amos/yank-buffer-filename-nondir)

   (:desc "git" :prefix "g"
     :desc "Git status"                    :nv "s" #'magit-status
     :desc "Git blame"                     :nv "b" #'magit-blame
     :desc "Git revert hunk"               :nv "r" #'git-gutter:revert-hunk
     :desc "Git revert buffer"             :nv "R" #'vc-revert)

   (:desc "help" :prefix "h"
     :desc "Apropos"                       :nv "a" #'apropos
     :desc "Reload theme"                  :nv "R" #'doom/reload-theme
     :desc "Find library"                  :nv "l" #'find-library
     :desc "Toggle Emacs log"              :nv "m" #'doom/popup-toggle-messages
     :desc "Command log"                   :nv "L" #'global-command-log-mode
     :desc "Describe function"             :nv "f" #'describe-function
     :desc "Describe key"                  :nv "k" #'describe-key
     :desc "Describe char"                 :nv "c" #'describe-char
     :desc "Describe mode"                 :nv "M" #'describe-mode
     :desc "Describe variable"             :nv "v" #'describe-variable
     :desc "Describe face"                 :nv "F" #'describe-face
     :desc "Describe DOOM setting"         :nv "s" #'doom/describe-setting
     :desc "Describe DOOM module"          :nv "d" #'doom/describe-module
     :desc "What face"                     :nv "'" #'doom/what-face
     :desc "What minor modes"              :nv ";" #'doom/what-minor-mode
     :desc "Info"                          :nv "i" #'info
     :desc "Toggle profiler"               :nv "p" #'doom/toggle-profiler)

   (:desc "notes" :prefix "n"
     :desc "Rust playground"               :nv "r" #'rust-playground
     :desc "Go playground"                 :nv "g" #'go-playground
     :desc "C++ playground"                :nv "c" (lambda! (+amos/tmux-new-window 'cc-playground))
     :desc "C++ playground"                :nv "l" #'cc-playground-find-snippet
     :desc "Elisp playground"              :nv "e" #'+amos/new-empty-elisp-buffer
     :desc "Browse script"                 :nv "s" #'+amos/browse-script
     :desc "Browse org"                    :nv "o" #'+amos/browse-org
     :desc "Browse note"                   :nv "n" #'+amos/browse-note
     :desc "Browse mode notes"             :nv "m" #'+org/browse-notes-for-major-mode
     :desc "Browse project notes"          :nv "p" #'+org/browse-notes-for-project)

   (:desc "open" :prefix "o"
     :desc "Default browser"               :nv "b" #'browse-url-of-file
     :desc "Dired"                         :nv "d" #'+amos/dired-jump
     :desc "REPL"                          :nv "r" #'+eval/open-repl
     :desc "APP: elfeed"                   :nv "E" #'=rss
     :desc "APP: email"                    :nv "m" #'=email
     :desc "APP: regex"                    :nv "X" #'=regex)

   (:desc "quit" :prefix "q"
     :desc "Quit"                          :nv "q" #'+amos/prompt-kill-emacs)

   (:desc "snippets" :prefix "s"
     :desc "New snippet"                   :nv "n" #'yas-new-snippet
     :desc "Insert snippet"                :nv "i" #'yas-insert-snippet
     :desc "Find snippet for mode"         :nv "s" #'yas-visit-snippet-file)

   (:desc "toggle" :prefix "t"
     :desc "Flycheck"                      :nv "f" #'flycheck-mode
     :desc "Rainbow"                       :nv "r" #'rainbow-mode
     :desc "Truncate lines"                :nv "l" #'toggle-truncate-lines
     :desc "Whitespace"                    :nv "w" #'whitespace-mode
     :desc "Fullscreen"                    :nv "f" #'doom/toggle-fullscreen
     :desc "Indent guides"                 :nv "i" #'highlight-indentation-mode
     :desc "Indent guides (column)"        :nv "I" #'highlight-indentation-current-column-mode))

 (:after company
   :map company-active-map
   "C-v"        #'company-next-page
   "M-v"        #'company-previous-page
   "C-j"        #'company-select-next
   "C-o"        #'company-search-kill-others
   "C-k"        #'company-select-previous
   "C-h"        #'company-quickhelp-manual-begin
   "C-S-h"      #'company-show-doc-buffer
   "C-S-s"      #'company-search-candidates
   "C-s"        #'company-filter-candidates
   "C-SPC"      #'company-complete-common
   "C-h"        #'company-quickhelp-manual-begin
   "C-w"        nil
   "RET"        nil
   "SPC"        nil
   [return]     nil
   [tab]        nil
   [backtab]    nil

   :map company-search-map
   "C-j"        #'company-search-repeat-forward
   "C-k"        #'company-search-repeat-backward
   "C-s"        (lambda! (company-search-abort) (company-filter-candidates))
   [escape]     #'company-search-abort)

 (:after swiper
   :map swiper-map
   "C-c o"    #'+ivy/wgrep-occur)

 (:after counsel
   :map counsel-ag-map
   "C-c o"    #'+ivy/wgrep-occur
   "C-i"      #'ivy-call
   "C-SPC"    #'counsel-git-grep-recenter
   "M-RET"    (+ivy-do-action! #'+ivy-git-grep-other-window-action))

 (:after dired
   :map dired-mode-map
   "SPC" nil
   "G"   nil
   "g"   nil
   "e"   nil
   "v"   nil
   "b"   nil
   "n"   nil
   "N"   nil
   "y"   nil
   "C-o" nil
   "C-i" nil
   :n "q"   #'quit-window
   :n "C-f" #'dired-omit-mode
   :n "C-i" #'peep-dired-toggle
   :n "C-v" #'peep-dired-scroll-page-down
   :n "E"   #'wdired-change-to-wdired-mode
   :n "I"   #'dired-kill-subdir
   :n "M-i" #'+amos/next-history
   :n "M-n" #'+amos/counsel-jumpfile-function
   :n "M-o" #'+amos/prev-history
   :n "M-v" #'peep-dired-scroll-page-up
   :n "S"   #'hydra-dired-quick-sort/body
   :n "S"   #'hydra-dired-quick-sort/body
   :n "W"   (lambda! (dired-copy-filename-as-kill 0))
   :n "Y"   #'+amos/dired-rsync
   :n "c"   (lambda! (dired-ranger-copy t))
   :n "d"   #'dired-flag-file-deletion
   :n "f"   #'counsel-find-file
   :n "h"   #'+amos/up-directory
   :n "j"   #'dired-next-line
   :n "k"   #'dired-previous-line
   :n "p"   #'dired-ranger-paste
   :n "r"   #'dired-ranger-move
   :n "y"   (lambda! (dired-ranger-copy nil))
   :n "RET" #'dired-open-file
   :n "l"   #'dired-open-file)

 (:after evil-magit
   :map (magit-status-mode-map magit-revision-mode-map)
   :n "C-j" nil
   :n [tab] #'magit-section-toggle
   :n "C-k" nil)

 (:after evil-multiedit
   :map evil-multiedit-state-map
   "M-d" #'evil-multiedit-match-and-next
   "M-D" #'evil-multiedit-match-and-prev
   "RET" #'evil-multiedit-toggle-or-restrict-region
   :map (evil-multiedit-state-map evil-multiedit-insert-state-map)
   "C-n" #'evil-multiedit-next
   "C-p" #'evil-multiedit-prev)

 ;; ivy
 (:after ivy
   :map ivy-minibuffer-map
   "C-a"    #'move-beginning-of-line
   "C-d"    #'+amos/delete-char
   "C-j"    #'ivy-next-line
   "C-k"    #'ivy-previous-line
   "C-l"    #'ivy-alt-done
   "C-o"    #'+amos/kill-line
   "C-r"    #'evil-paste-from-register
   "C-u"    #'+amos/backward-kill-to-bol-and-indent
   "C-w"    #'ivy-yank-word
   "C-y"    (lambda! (let ((kill-ring my-kill-ring)) (yank)))
   "M-B"    (lambda! (+amos/backward-word-insert t))
   "M-D"    (lambda! (+amos/forward-delete-word t))
   "M-F"    (lambda! (+amos/forward-word-insert t))
   "M-b"    #'+amos/backward-word-insert
   "M-d"    #'+amos/forward-delete-word
   "M-f"    #'+amos/forward-word-insert
   "M-g"    #'+amos/ivy-complete-dir
   "M-j"    #'ivy-immediate-done
   "M-r"    #'ivy-toggle-fuzzy
   "M-y"    (lambda! (let ((kill-ring my-kill-ring)) (yank-pop)))
   "M-z"    #'undo
   "TAB"    #'ivy-call
   [escape] #'keyboard-escape-quit

   :map ivy-occur-grep-mode-map
   "C-d"    nil
   "d"      #'ivy-occur-delete-candidate)

 ;; yasnippet
 (:after yasnippet
   :map yas-keymap
   "C-l"           #'yas-next-field

   :map yas-minor-mode-map
   :i "C-l" yas-maybe-expand)

 (:after cquery
   (:map cquery-tree-mode-map
     :m "C-i"      #'cquery-tree-toggle-expand
     :n "c"        #'cquery-tree-toggle-calling
     :n "f"        #'cquery-tree-press
     :n "h"        #'cquery-tree-collapse-or-select-parent
     :n "j"        #'cquery-tree-next-line
     :n "k"        #'cquery-tree-prev-line
     :n "J"        #'cquery-tree-next-sibling
     :n "K"        #'cquery-tree-prev-sibling
     :n "l"        #'cquery-tree-expand-or-set-root
     :n "oh"       #'cquery-tree-press-and-horizontal-split
     :n "ov"       #'cquery-tree-press-and-vertical-split
     :n "oo"       #'cquery-tree-press-and-switch
     :n "q"        #'cquery-tree-quit
     :n "<escape>" #'cquery-tree-quit
     :n "Q"        #'quit-window
     :n "yy"       #'cquery-tree-yank-path
     :n "RET"      #'cquery-tree-press-and-switch
     :n "<left>"   #'cquery-tree-collapse-or-select-parent
     :n "<right>"  #'cquery-tree-expand-or-set-root))

 (:after debug
   ;; For elisp debugging
   :map debugger-mode-map
   :n "q"   (lambda! (top-level) (doom/kill-this-buffer))
   :n "RET" #'debug-help-follow
   :n "e"   #'debugger-eval-expression
   :n "n"   #'debugger-step-through
   :n "c"   #'debugger-continue)

 (:after compile
   :map compilation-mode-map
   "SPC" nil
   "0" nil
   "g" nil)

 (:after edebug
   :map edebug-mode-map
   :gn "s"        #'edebug-step-mode
   :gn "n"        #'edebug-next-mode
   :gn "g"        #'edebug-go-mode
   :gn "G"        #'edebug-Go-nonstop-mode
   :gn "t"        #'edebug-trace-mode
   :gn "T"        #'edebug-Trace-fast-mode
   :gn "c"        #'edebug-continue-mode
   :gn "C"        #'edebug-Continue-fast-mode
   :gn "f"        #'edebug-forward-sexp
   :gn "N"        #'edebug-goto-here
   :gn "I"        #'edebug-instrument-callee
   :gn "i"        #'edebug-step-in
   :gn "o"        #'edebug-step-out
   :gn "q"        #'top-level
   :gn "Q"        #'edebug-top-level-nonstop
   :gn "a"        #'abort-recursive-edit
   :gn "S"        #'edebug-stop
   :gn "b"        #'edebug-set-breakpoint
   :gn "u"        #'edebug-unset-breakpoint
   :gn "B"        #'edebug-next-breakpoint
   :gn "x"        #'edebug-set-conditional-breakpoint
   :gn "X"        #'edebug-set-global-break-condition
   :gn "r"        #'edebug-previous-result
   :gn "e"        #'edebug-eval-expression
   :gn "C-x C-e" #'edebug-eval-last-sexp
   :gn "E"        #'edebug-visit-eval-list
   :gn "w"        #'edebug-where
   :gn "v"        #'edebug-view-outside ;; maybe obsolete??
   :gn "p"        #'edebug-bounce-point
   :gn "P"        #'edebug-view-outside ;; same as v
   :gn "W"        #'edebug-toggle-save-windows
   :gn "?"        #'edebug-help
   :gn "d"        #'edebug-backtrace
   :gn "-"        #'negative-argument
   :gn "="        #'edebug-temp-display-freq-count)

 (:after org
   :map org-mode-map
   :n "RET"       #'org-open-at-point
   :n "M-h"       #'evil-window-left
   :n "M-j"       #'evil-window-down
   :n "M-k"       #'evil-window-up
   :n "M-l"       #'evil-window-right
   :n "C-j"       #'org-metadown
   :n "C-k"       #'org-metaup
   :i "C-d"       #'delete-char
   :i "DEL"       #'org-delete-backward-char
   :n  "gj"       #'evil-next-visual-line
   :n  "gk"       #'evil-previous-visual-line
   :n "M-a"       #'+amos/mark-whole-buffer
   :g "C-c e"     #'+amos/org-babel-edit
   :g "C-c C-j"   #'counsel-org-goto
   :g "C-c C-S-l" #'+org/remove-link)

 (:after profiler
   :map profiler-report-mode-map
   :n "RET" #'profiler-report-expand-entry)

 (:after evil-snipe
   :map evil-snipe-parent-transient-map
   :g "n" #'evil-snipe-repeat
   :g "j" #'evil-snipe-repeat
   :g "k" #'evil-snipe-repeat-reverse
   :g "N" #'evil-snipe-repeat-reverse
   :g "p" #'evil-snipe-repeat-reverse)

 (:map key-translation-map
   "\035"          [escape]
   [S-iso-lefttab] [backtab]
   "C-1"           (kbd "1")
   "C-2"           (kbd "2")
   "C-3"           (kbd "3")
   "C-4"           (kbd "4")
   "C-5"           (kbd "5")
   "C-6"           (kbd "6")
   "C-7"           (kbd "7")
   "C-8"           (kbd "8")
   "C-9"           (kbd "9")
   "C-0"           (kbd "0")
   "C-@"           (kbd "C-SPC"))

 (:map (minibuffer-local-map
        minibuffer-local-ns-map
        minibuffer-local-completion-map
        minibuffer-local-must-match-map
        minibuffer-local-isearch-map
        evil-ex-completion-map
        evil-ex-search-keymap
        read-expression-map)
   [escape]      #'abort-recursive-edit
   "C-y"         (lambda! (let ((kill-ring my-kill-ring)) (yank)))
   "M-y"         (lambda! (let ((kill-ring my-kill-ring)) (yank-pop)))
   "C-r"         #'evil-paste-from-register
   "C-a"         #'move-beginning-of-line
   "M-b"         #'+amos/backward-word-insert
   "M-B"         (lambda! (+amos/backward-word-insert t))
   "M-f"         #'+amos/forward-word-insert
   "M-F"         (lambda! (+amos/forward-word-insert t))
   "M-d"         #'+amos/forward-delete-word
   "M-D"         (lambda! (+amos/forward-delete-word t))
   "DEL"         #'+amos/backward-delete-char
   [M-backspace] #'+amos/backward-delete-word
   [134217855]   #'+amos/backward-delete-word ; M-DEL
   "C-w"         #'ivy-yank-word
   "C-u"         #'+amos/backward-kill-to-bol-and-indent
   "C-k"         #'+amos/kill-line
   "C-o"         #'+amos/kill-line
   "C-d"         #'+amos/delete-char
   "M-z"         #'doom/minibuffer-undo)

 ;; --- Custom evil text-objects ---------------------
 :textobj "a" #'evil-inner-arg                    #'evil-outer-arg
 :textobj "j" #'+amos/any-object-inner            #'+amos/any-object-outer
 :textobj "i" #'evil-indent-plus-i-indent         #'evil-indent-plus-a-indent
 :textobj "I" #'evil-indent-plus-i-indent-up      #'evil-indent-plus-a-indent-up
 :textobj "J" #'evil-indent-plus-i-indent-up-down #'evil-indent-plus-a-indent-up-down)

(after! company
  (bind-keys :map company-active-map
             :filter (company-explicit-action-p)
             ("C-i" . company-complete-selection)))

(bind-keys :map emacs-lisp-mode-map
           ("C-x e" . macrostep-expand)
           ("#"     . endless/sharp)
           ("M-r"   . +eval/buffer)
           ("M-R"   . +eval/region-and-replace))