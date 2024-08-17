;; Packages helpful during development, but not needed for
;; core functionality.
(use-modules (guix packages)
             (guix download)
             (guix git-download)
             (guix hg-download)
             (guix build-system r)
             (guix build-system python)
             (guix build-system pyproject)
             (guix licenses))

(define-public r-vscdebugger
  (let ((commit "c2b5ab018a6936fe0fece7f066dccc85c50aa457")
        (revision "1"))
    (package
      (name "r-vscdebugger")
      (version (git-version "0.5.3" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://github.com/ManuelHentschel/vscDebugger")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "12cmppdbqfcxg95pn0wc7by8qj8jkswiia7wq7rwc3m9bfahjrv8"))))
      (properties `((upstream-name . "vscDebugger")))
      (build-system r-build-system)
      (propagated-inputs (list (specification->package "r-jsonlite")
                               (specification->package "r-r6")))
      (native-inputs (list (specification->package "r-knitr")))
      (home-page "https://github.com/ManuelHentschel/vscDebugger")
      (synopsis "Support for Visual Studio Code Debugger")
      (description
       "This package provides support for a visual studio code debugger.")
      (license expat))))


(specifications->manifest (list "r-httpgd"
                                "r-languageserver"))

