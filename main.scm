(import utf8)
(import (chicken string)
	(chicken load)
	(chicken port)
	(chicken process-context)
	(chicken io)
	(chicken load))

(load-relative "./db-utils.scm")
(load-relative "./cli.scm")
(load-relative "./plot.scm")
(load-relative "./db-example.scm") ;example database where *db* is defined

(cond
 ((null? (command-line-arguments))
  (display "No arguments where given\n")
  (display "Usage: sdb -l [PATH TO DB] [OPTIONS]\n")
  (exit))
 (else
  (params-handler
   (command-line-arguments-alist (command-line-arguments)))))

(when a-param?
  (if (null? a-args)
      (set! *db* (add-entry (prompt-entry) *db*))
      (display "Sorry, feature not yet implemented\n"))
  (print-db *db*))

(when s-param?
  (let ((search-results (prompt-search s-args)))
    (newline)
    (if (null? search-results)
	(display "No results found.")
	(begin
	  (display "Search results\n")
	  (display "=================\n")
	  (newline)
	  (cond
	   ((string=? s-args "tags-or")
	    (display "Entries found:\n")
	    (print-db search-results))
	   (else
	    (display "Entry found:\n")
	    (print-entry search-results)))))))

(when p-param?
  (plot-tags-stats (get-tags-stats *db*)))

(when e-param?
  (cond
   ((null? e-args)
    (print-db-tsv *db*))
   ((eq? e-args 'tsv)
    (print-db-tsv *db*))
   ((eq? e-args 'csv)
    (print-db-csv *db*))))

;; TODO: better print the results
(when g-param?
  (cond
   ((null? g-args)
    (exit))

   ((string=? g-args "title")
    (display (get-entries-titles *db*)))

   ((string=? g-args "url")
    (display (get-entries-urls *db*)))

   ((string=? g-args "tags")
    (display (get-entries-tags *db*)))

   ((string=? g-args "description")
    (display (get-entries-descriptions *db*)))

   (else
    (display "Error: unknown field, allowed fields are: title, url, tags, description\n"))))
