;;; config.el -*- lexical-binding: t; -*-

(setq doom-font (font-spec :family "FiraCode Nerd Font" :size 14))

(setq doom-theme 'doom-one
      display-line-numbers-type 'relative
      org-directory "~/org/")

(setq browse-url-browser-function #'eww-browse-url)

(defun my/project-root ()
  (or (when (fboundp 'doom-project-root)
        (doom-project-root))
      (when-let* ((project (project-current nil)))
        (project-root project))
      default-directory))

(defun my/terminal-directory ()
  "Return the current file's directory, or this buffer's directory."
  (if-let* ((file (buffer-file-name)))
      (file-name-directory file)
    default-directory))

(defun my/vterm-right (&optional command buffer-name)
  (interactive)
  (require 'vterm)
  (let* ((default-directory (my/terminal-directory))
         (buffer (get-buffer-create (or buffer-name "*vterm-right*")))
         (window (or (get-buffer-window buffer)
                     (split-window-right (floor (* 0.58 (window-total-width)))))))
    (select-window window)
    (unless (eq (buffer-local-value 'major-mode buffer) 'vterm-mode)
      (with-current-buffer buffer
        (vterm-mode)))
    (switch-to-buffer buffer)
    (when command
      (goto-char (point-max))
      (vterm-send-string command)
      (vterm-send-return))))

(defun my/vterm-run (command &optional buffer-name)
  (my/vterm-right command (or buffer-name (format "*%s*" command))))

(defun my/lazygit ()
  (interactive)
  (my/vterm-run "lazygit" "*lazygit*"))

(defun my/ai-open (command buffer-name)
  (interactive)
  (if (executable-find command)
      (my/vterm-run command buffer-name)
    (user-error "%s not found in PATH" command)))

(defun my/claude-toggle ()
  (interactive)
  (my/ai-open "claude" "*claude*"))

(defun my/claude-resume ()
  (interactive)
  (my/vterm-run "claude --resume" "*claude*"))

(defun my/claude-continue ()
  (interactive)
  (my/vterm-run "claude --continue" "*claude*"))

(defun my/codex-toggle ()
  (interactive)
  (my/ai-open "codex" "*codex*"))

(defun my/gemini-toggle ()
  (interactive)
  (my/ai-open "gemini" "*gemini*"))

(defun my/relative-buffer-file-reference ()
  (if-let* ((file (buffer-file-name)))
      (concat "@" (file-relative-name file (my/project-root)))
    (user-error "Current buffer is not visiting a file")))

(defun my/send-current-file-reference-to-vterm (buffer-name)
  (let ((reference (my/relative-buffer-file-reference)))
    (if-let* ((buffer (get-buffer buffer-name)))
        (with-current-buffer buffer
          (goto-char (point-max))
          (vterm-send-string reference))
      (kill-new reference)
      (message "Copied %s; open %s first to send it there" reference buffer-name))))

(defun my/codex-add-current-buffer ()
  (interactive)
  (my/send-current-file-reference-to-vterm "*codex*"))

(defun my/claude-add-current-buffer ()
  (interactive)
  (my/send-current-file-reference-to-vterm "*claude*"))

(defun my/search-todo ()
  (interactive)
  (consult-ripgrep (my/project-root) "\\b(TODO|FIX|FIXME|HACK|REVIEW)\\b"))

;; Single-file C++ commands share the same executable and debug flags.
(defvar my/cpp-compile-flags '("-std=c++17" "-g" "-O0" "-Wall" "-Wextra")
  "Compiler flags for the single-file C++ run and debug commands.")

(defun my/cpp-source-file ()
  (unless (and buffer-file-name
               (derived-mode-p 'c++-mode 'c++-ts-mode)
               (member (downcase (or (file-name-extension buffer-file-name) ""))
                       '("cpp" "cc" "cxx" "c++" "c")))
    (user-error "Open a C++ source file first"))
  (when (file-remote-p buffer-file-name)
    (user-error "This command supports local C++ files"))
  (expand-file-name buffer-file-name))

(defun my/cpp-output-file (source)
  (concat (file-name-sans-extension source) ".out"))

(defun my/cpp-build-command (source)
  (let ((compiler (or (executable-find "g++")
                      (executable-find "clang++")
                      (user-error "No C++ compiler found"))))
    (mapconcat #'shell-quote-argument
               (append (list compiler) my/cpp-compile-flags
                       (list source "-o" (my/cpp-output-file source)))
               " ")))

(defun my/cpp-save-source ()
  ;; Save immediately; an asynchronous formatter must not race the compiler.
  (let ((apheleia-mode nil))
    (save-buffer)))

(defun compile-and-run-cpp ()
  (interactive)
  (let* ((source (my/cpp-source-file))
         (default-directory (file-name-directory source)))
    (my/cpp-save-source)
    (compile (concat (my/cpp-build-command source) " && "
                     (shell-quote-argument (my/cpp-output-file source)))
             t)))

(defun my/cpp-debug-config (config)
  "Save and build the current source before launching its executable."
  (let ((source (my/cpp-source-file)))
    (my/cpp-save-source)
    ;; Dape re-enters after compilation, potentially in the compilation buffer.
    (setq config (plist-put config 'fn nil))
    (setq config (plist-put config 'compile (my/cpp-build-command source)))
    (setq config (plist-put config :program (my/cpp-output-file source)))
    (setq config (plist-put config :cwd (file-name-directory source)))
    config))

(defun my/python-project-executable ()
  "Use the project's Python for the debuggee, with a global debugpy adapter."
  (or (when (fboundp 'lsp-pyright-locate-python)
        (lsp-pyright-locate-python))
      (executable-find "python")
      (executable-find "python3")
      (user-error "No Python interpreter found")))

(map! "C-c 2" #'neotree-toggle
      :leader
      :desc "Compile and run C++ file" "c R" #'compile-and-run-cpp)

(defun my/dape-start-or-continue ()
  (interactive)
  (if (and (featurep 'dape)
           (fboundp 'dape--live-connection)
           (ignore-errors (dape--live-connection 'stopped t)))
      (call-interactively #'dape-continue)
    (call-interactively #'+debugger/start)))

;; Keep inherited NO_COLOR from disabling colors in interactive terminals.
(setenv "NO_COLOR" nil)

;; Help GUI Emacs find Homebrew, Python user scripts, and debugger binaries.
(dolist (dir '("/opt/homebrew/bin"
               "/opt/homebrew/sbin"
               "/usr/local/bin"
               "/usr/local/sbin"
               "/usr/local/opt/llvm/bin"
               "~/.local/bin"
               "/Library/TeX/texbin"
               "/opt/homebrew/opt/llvm/bin"
               "~/.local/share/emacs-config/debugpy/bin"))
  (let ((expanded-dir (expand-file-name dir)))
    (when (file-directory-p expanded-dir)
      (add-to-list 'exec-path expanded-dir)
      (setenv "PATH" (concat expanded-dir path-separator (getenv "PATH"))))))

;; Save-time formatting is limited to C/C++ and Python.
(after! apheleia
  (dolist (mode '(c-mode c-ts-mode c++-mode c++-ts-mode))
    (setf (alist-get mode apheleia-mode-alist) 'clang-format))
  (dolist (mode '(python-mode python-ts-mode))
    (setf (alist-get mode apheleia-mode-alist) '(ruff-isort ruff)))
  (add-hook 'apheleia-inhibit-functions
            (lambda ()
              (not (derived-mode-p 'c-mode 'c-ts-mode 'c++-mode 'c++-ts-mode
                                   'python-mode 'python-ts-mode)))))

;; uv-mode's default unset leaves old bin directories on PATH. Use pyvenv's
;; paired activation/deactivation so switching projects restores the environment.
(after! uv-mode
  (require 'pyvenv)
  (defun my/uv-activate ()
    (when-let* ((root (uv-mode-root))
                (venv (uv-mode-full-path root)))
      (pyvenv-activate venv)
      (pythonic-activate venv)))
  (defun my/uv-deactivate ()
    (pyvenv-deactivate)
    (pythonic-deactivate))
  (advice-add 'uv-mode-set :override #'my/uv-activate)
  (advice-add 'uv-mode-unset :override #'my/uv-deactivate))

;; telega uses TDLib. Homebrew installs TDLib under /opt/homebrew/opt/tdlib,
;; and the bridge server is built into ~/.telega/telega-server.
(autoload 'telega "telega" nil t)
(after! telega
  (setq telega-server-command "~/.telega/telega-server"
        telega-server-libs-prefix
        (if (file-directory-p "/opt/homebrew/opt/tdlib")
            "/opt/homebrew/opt/tdlib" "/usr/local/opt/tdlib")))

;; Prefer clangd for C/C++ and make it useful out of the box.
(after! lsp-clangd
  (setq lsp-clients-clangd-args
        '("--background-index"
          "--clang-tidy"
          "--completion-style=detailed"
          "--header-insertion=never"
          "--header-insertion-decorators=0"))
  (set-lsp-priority! 'clangd 2))

;; Dape is Doom's debugger frontend. These entries make the common Python and
;; C/C++ launch paths explicit, while keeping Dape's built-in configs available.
(after! dape
  (add-to-list 'dape-configs
               `(python-debugpy
                 modes (python-mode python-ts-mode)
                 command ,(or (let ((python (expand-file-name
                                             "~/.local/share/emacs-config/debugpy/bin/python")))
                                (when (file-executable-p python) python))
                              (executable-find "python3") "python3")
                 :python my/python-project-executable
                 command-args ("-m" "debugpy.adapter")
                 :type "python"
                 :request "launch"
                 :program dape-buffer-default
                 :cwd dape-cwd
                 :justMyCode t))
  (add-to-list 'dape-configs
               `(cpp-lldb-dap
                 modes (c++-mode c++-ts-mode)
                 ensure dape-ensure-command
                 fn my/cpp-debug-config
                 command ,(or (executable-find "lldb-dap")
                              (when (file-executable-p "/Library/Developer/CommandLineTools/usr/bin/lldb-dap")
                                "/Library/Developer/CommandLineTools/usr/bin/lldb-dap")
                              "lldb-dap")
                 :type "lldb-dap"
                 :request "launch"
                 :args [])))

(when (keymapp (lookup-key doom-leader-map (kbd "p")))
  (define-key doom-leader-map (kbd "P")
              (copy-keymap (lookup-key doom-leader-map (kbd "p")))))

(map! :leader
      :desc "Floating terminal" "2" #'+vterm/toggle
      :desc "Right terminal" "3" #'my/vterm-right
      :desc "Yank history" "p" #'consult-yank-pop
      (:prefix ("g" . "Git / AI")
       :desc "Lazygit" "g" #'my/lazygit
       :desc "Magit diff" "V" #'magit-diff-buffer-file
       :desc "Current file history" "H" #'magit-log-buffer-file
       :desc "Gemini" "e" #'my/gemini-toggle)
      (:prefix ("d" . "debug")
       :desc "Toggle breakpoint" "b" #'dape-breakpoint-toggle
       :desc "Conditional breakpoint" "B" #'dape-breakpoint-expression)
      (:prefix-map ("z" . "custom")
       (:prefix ("x" . "Codex / Todo")
        :desc "Toggle Codex" "c" #'my/codex-toggle
        :desc "Focus Codex" "f" #'my/codex-toggle
        :desc "Add current buffer" "b" #'my/codex-add-current-buffer
        :desc "Todo" "t" #'my/search-todo
        :desc "Todo/Fix/Fixme" "T" #'my/search-todo)
       (:prefix ("a" . "AI")
        :desc "Toggle Claude" "c" #'my/claude-toggle
        :desc "Focus Claude" "f" #'my/claude-toggle
        :desc "Resume Claude" "r" #'my/claude-resume
        :desc "Continue Claude" "C" #'my/claude-continue
        :desc "Add current buffer" "b" #'my/claude-add-current-buffer)))

(map! :n [f5] #'my/dape-start-or-continue
      :n [f1] #'dape-step-in
      :n [f2] #'dape-next
      :n [f3] #'dape-step-out
      :n [f7] #'dape-info)

(after! pdf-tools
  (pdf-tools-install-noverify))

;; Compact CyberCode ASCII dashboard.
(defun my/dashboard-ascii-banner ()
  (concat
    (mapconcat #'identity
      (list
      (concat (propertize "   ____      _             " 'face '(:inherit fixed-pitch :height 1.0 :weight normal :foreground "#51afef"))
              (propertize " ____          _         " 'face '(:inherit fixed-pitch :height 1.0 :weight normal :foreground "#a9a1e1")))
      (concat (propertize "  / ___|   _| |__   ___ _ _" 'face '(:inherit fixed-pitch :height 1.0 :weight normal :foreground "#51afef"))
              (propertize "_/ ___|___   __| | ___   " 'face '(:inherit fixed-pitch :height 1.0 :weight normal :foreground "#a9a1e1")))
      (concat (propertize " | |  | | | | '_ \\ / _ \\ '_" 'face '(:inherit fixed-pitch :height 1.0 :weight normal :foreground "#51afef"))
              (propertize "_| |   / _ \\ / _` |/ _ \\ " 'face '(:inherit fixed-pitch :height 1.0 :weight normal :foreground "#a9a1e1")))
      (concat (propertize " | |__| |_| | |_) |  __/ | " 'face '(:inherit fixed-pitch :height 1.0 :weight normal :foreground "#51afef"))
              (propertize " | |__| (_) | (_| |  __/ " 'face '(:inherit fixed-pitch :height 1.0 :weight normal :foreground "#a9a1e1")))
      (concat (propertize "  \\____\\__, |_.__/ \\___|_| " 'face '(:inherit fixed-pitch :height 1.0 :weight normal :foreground "#51afef"))
              (propertize "  \\____\\___/ \\__,_|\\___| " 'face '(:inherit fixed-pitch :height 1.0 :weight normal :foreground "#a9a1e1")))
      (concat (propertize "       |___/               " 'face '(:inherit fixed-pitch :height 1.0 :weight normal :foreground "#51afef"))
              (propertize "                         " 'face '(:inherit fixed-pitch :height 1.0 :weight normal :foreground "#a9a1e1"))))
      "\n")
    "\n"))

(setq +dashboard-banner-vertical-padding '(1 . 2)
      +dashboard-ascii-banner-fn #'my/dashboard-ascii-banner)

(defun my/dashboard-text-banner ()
  (let ((fancy-splash-image nil))
    (+dashboard-widget-banner)))

(setq +dashboard-functions
      '(my/dashboard-text-banner
        +dashboard-widget-shortmenu))

(custom-set-faces!
  '(+dashboard-menu-title :foreground "#51afef")
  '(+dashboard-menu-desc :foreground "#a9a1e1"))

(defun my/dashboard-clean-appearance ()
  (setq-local mode-line-format nil
              cursor-type nil))
(add-hook '+dashboard-mode-hook #'my/dashboard-clean-appearance)

;; Shared everyday keys with the local LazyVim configuration.
(defun my/search-config ()
  (interactive)
  (consult-ripgrep doom-user-dir))

(defun my/search-todo-fix ()
  (interactive)
  (consult-ripgrep (my/project-root) "\\b(TODO|FIX|FIXME)\\b"))

(map! :n "C-h" #'evil-window-left
      :n "C-j" #'evil-window-down
      :n "C-k" #'evil-window-up
      :n "C-l" #'evil-window-right
      :n "H" #'previous-buffer
      :n "L" #'next-buffer
      :nv "gr" #'+lookup/references)

(map! :leader
      :desc "Project files" "f f" #'projectile-find-file
      :desc "Files from current directory" "f F" #'+default/find-file-under-here
      :desc "Recent files" "f r" #'recentf-open-files
      :desc "Projects" "f p" #'projectile-switch-project
      :desc "Configuration files" "f c" #'doom/find-file-in-private-config
      :desc "Rename file" "f N" #'doom/move-this-file
      :desc "File tree" "e" #'neotree-toggle
      :desc "Previous buffer" "b b" #'evil-switch-to-windows-last-buffer
      :desc "Kill other buffers" "b o" #'doom/kill-other-buffers
      :desc "Project search" "s g" #'+default/search-project
      :desc "Current directory search" "s G" #'+default/search-cwd
      :desc "Search configuration" "s p" #'my/search-config
      :desc "TODO comments" "s t" #'my/search-todo
      :desc "TODO / FIX / FIXME" "s T" #'my/search-todo-fix
      :desc "Rename symbol" "c r" #'lsp-rename
      :desc "Compile and run C++" "c R" #'compile-and-run-cpp
      :desc "Split below" "-" #'evil-window-split
      :desc "Split right" "|" #'evil-window-vsplit
      (:prefix-map ("a" . "AI")
       :desc "Claude" "c" #'my/claude-toggle
       :desc "Focus Claude" "f" #'my/claude-toggle
       :desc "Resume Claude" "r" #'my/claude-resume
       :desc "Continue Claude" "C" #'my/claude-continue
       :desc "Send file to Claude" "b" #'my/claude-add-current-buffer
       (:prefix ("o" . "Codex")
        :desc "Codex" "c" #'my/codex-toggle
        :desc "Focus Codex" "f" #'my/codex-toggle
        :desc "Send file to Codex" "b" #'my/codex-add-current-buffer)
       (:prefix ("g" . "Gemini")
        :desc "Gemini" "t" #'my/gemini-toggle
        :desc "Gemini CLI" "c" #'my/gemini-toggle)))

(after! which-key
  (which-key-add-key-based-replacements "SPC P" "project"))

;; Machine-specific overrides stay private and are never required by the repo.
(load! "local" doom-user-dir t)
