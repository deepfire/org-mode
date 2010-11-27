;;; ob-clojure.el --- org-babel functions for clojure evaluation

;; Copyright (C) 2009, 2010  Free Software Foundation, Inc.

;; Author: Joel Boehland, Eric Schulte
;; Keywords: literate programming, reproducible research
;; Homepage: http://orgmode.org
;; Version: 7.3

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;; support for evaluating clojure code, relies on slime for all eval

;;; Requirements:

;;; A working clojure install. This also implies a working java executable
;;; - clojure-mode
;;; - slime
;;; - swank-clojure

;;; By far, the best way to install these components is by following
;;; the directions as set out by Phil Hagelberg (Technomancy) on the
;;; web page: http://technomancy.us/126

;;; Code:
(require 'ob)

(declare-function slime-eval "ext:slime" (sexp &optional package))

(add-to-list 'org-babel-tangle-lang-exts '("clojure" . "clj"))

(defvar org-babel-default-header-args:clojure '())

(defun org-babel-expand-body:clojure (body params)
  "Expand BODY according to PARAMS, return the expanded body."
  (let* ((vars (mapcar #'cdr (org-babel-get-header params :var)))
	 (print-level nil) (print-length nil)
	 (body (org-babel-trim
		(if (> (length vars) 0)
		    (concat "(let ["
			    (mapconcat
			     (lambda (var)
			       (format "%S (quote %S)" (car var) (cdr var)))
			     vars "\n      ")
			    "]\n" body ")")
		  body))))
    (if (or (member "code" result-params)
	    (member "pp" result-params))
	(format (concat "(let [org-mode-print-catcher (java.io.StringWriter.)]"
			"(with-pprint-dispatch %s-dispatch"
			"(clojure.pprint/pprint %s org-mode-print-catcher)"
			"(str org-mode-print-catcher)))")
		(if (member "code" result-params) "code" "simple") body)
      body)))

(defun org-babel-execute:clojure (body params)
  "Execute a block of Clojure code with Babel."
  (require 'slime) (require 'swank-clojure)
  (with-temp-buffer
    (insert (org-babel-expand-body:clojure body params))
    (read
     (slime-eval
      `(swank:interactive-eval-region
        ,(buffer-substring-no-properties (point-min) (point-max)))
      (cdr (assoc :package params))))))

(provide 'ob-clojure)

;; arch-tag: a43b33f2-653e-46b1-ac56-2805cf05b7d1

;;; ob-clojure.el ends here
