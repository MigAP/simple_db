(import (chicken string))
(import (chicken load))
(import utf8)

(load-relative "./db-utils.scm")
(load-relative "./cli.scm")
(load-relative "./plot.scm")
(load-relative "./db-example.scm") ; where *db* is defined


;;; Creating entries

(define ex-entry (mk-entry "Super Title"
			   "https://url.com"
			   '(tag1 tag2)
			   "This is a description"))

(define ex-entry-2 (mk-entry "Google"
			   "https://google.com"
			   '(search internet)
			   "Google used to be good"))

(define ex-entry-3 (mk-entry "Duckduckgo"
			   "https://duckduckgo.com"
			   '(search internet)
			   "Like google but better"))

(print-entry ex-entry)

;; A databse is simply a list of entries
(define ex-db (mk-db ex-entry ex-entry-2 ex-entry-3))

;;; Equality tests

(tag-inside? 'search (get-tags ex-entry-2))
(tags-or-comparison? (get-tags ex-entry-2)
		    (get-tags ex-entry-3))

(common-tag? ex-entry-2
	     (mk-entry "" "" '(search) ""))

;;; Lookup functions tests

(lookup-entry ex-db ex-entry-3)
(lookup-entry-by-title ex-db ex-entry-3)
(lookup-entry-by-tags ex-db ex-entry-3)
(length (lookup-entry-by-tags-or ex-db (mk-entry "" "" '(internet) "")))


(lookup-entry ex-db ex-entry-3)
(lookup-entry ex-db (mk-entry "Title test" "www.com" '(hello world) "description string"))

(lookup-and-collect-by-title ex-db ex-entry-3 length)
(lookup-and-collect-by-tags ex-db ex-entry-3 (lambda (x) x))

;;; Cool lookup examples with collectors

(lookup-and-collect-by-tags *db*
			    (mk-entry "tu" "" '(lisp) "")
			    get-db-titles)

(lookup-and-collect-by-tags *db*
			    (mk-entry "tu" "" '(lisp) "")
			    length)

(lookup-and-collect-by-tags-or *db*
			    (mk-entry "tu" "" '(lisp) "")
			    length)


;;; Functions to extract information from a database

(get-db-titles ex-db)
(get-db-urls ex-db)
(get-db-tags ex-db)
(flatten (get-db-tags ex-db)) ; useful to have the tags as lists
(get-db-descriptions ex-db)

;;; Tags statistics from the database

(get-tag-set ex-db)

(occurrences 'a '(a b f a d a))

(occurrences-alist '(a b f c) '(a b f a d a))

;; returns how many times each tag appears:
(occurrences-alist (get-tag-set ex-db)
		   (flatten (get-db-tags ex-db)))

(get-tags-stats *db*)
(get-tags-stats ex-db)

;; Plot tags function
(plot-tags-stats (get-tags-stats ex-db))

;;; IO database functions

(write-tags-stats *db* "./tags.csv")

(write-database ex-db "/test.scm")
