;;; init.el -*- lexical-binding: t; -*-

(doom! :input
       chinese

       :completion
       (corfu +orderless)
       vertico

       :ui
       doom
       dashboard
       hl-todo
       modeline
       neotree
       ophints
       (popup +defaults)
       (vc-gutter +pretty)
       vi-tilde-fringe
       workspaces

       :editor
       (evil +everywhere)
       file-templates
       fold
       (format +onsave)
       snippets
       (whitespace +guess +trim)

       :emacs
       dired
       electric
       eww
       tramp
       undo
       vc

       :term
       vterm

       :checkers
       syntax

       :tools
       debugger
       (eval +overlay)
       lookup
       (lsp +peek)
       magit
       pdf
       tree-sitter

       :os
       (:if (featurep :system 'macos) macos)

       :lang
       (cc +lsp +tree-sitter)
       emacs-lisp
       ess
       json
       latex
       markdown
       org
       (python +lsp +pyright +tree-sitter +uv)
       sh
       yaml

       :app
       calendar
       (rss +org)

       :config
       (default +bindings +smartparens))
