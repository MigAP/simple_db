(import (chicken string))
(import (chicken load))
(import utf8)

(load-relative "./db-utils.scm")
(load-relative "./cli.scm")
(load-relative "./plot.scm")
(load-relative "./db-example.scm") ;database containing all the websites

;; Entries example
(define ex-entry (mk-entry "Super Title"
			   "https://url.com"
			   '(tag1 tag2)
			   "This is a description"))

;(set-tags! ex-entry '(a b c))

(define ex-entry-2 (mk-entry "Google"
			   "https://google.com"
			   '(search internet)
			   "Google used to be good"))

(define ex-entry-3 (mk-entry "Duckduckgo"
			   "https://duckduckgo.com"
			   '(search internet)
			   "Like google but better"))

; Association lists built-in function
(assoc 'tags ex-entry)

(print-entry ex-entry)
(define ex-db (mk-db ex-entry ex-entry-2 ex-entry-3))

;; equality tests
(tag-inside? 'search (get-tags ex-entry-2))
(tags-or-comparison? (get-tags ex-entry-2)
		    (get-tags ex-entry-3))

(common-tag? ex-entry-2
	     (mk-entry "" "" '(search) ""))

;; lookup functions tests
(lookup-entry ex-db ex-entry-3)
(lookup-entry-by-title ex-db ex-entry-3)
(lookup-entry-by-tags ex-db ex-entry-3)
(length (lookup-entry-by-tags-or ex-db (mk-entry "" "" '(internet) "")))


(lookup-entry ex-db ex-entry-3)
(lookup-entry ex-db (mk-entry "Title test" "www.com" '(hello world) "description string"))


(add-entry (mk-entry "Title test" "www.com" '(hello world) "description string")
	   ex-db)


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


;; Functions to extract parameters from a list of entries
(get-db-titles ex-db)
(get-db-urls ex-db)
(get-db-tags ex-db)
(flatten (get-db-tags ex-db)) ; useful to have the tags as lists
(get-db-descriptions ex-db)

;; Tags statistics from the database
(get-tag-set ex-db)

(occurrences 'a '(a b f a d a))

(occurrences-alist '(a b f c) '(a b f a d a))

;;;; gets how many times each tag appears:
(occurrences-alist (get-tag-set ex-db)
		   (flatten (get-db-tags ex-db)))

(get-tags-stats *db*)
(get-tags-stats ex-db)

;; Plot tags function
(plot-tags-stats (get-tags-stats ex-db))
;(plot-tags-stats (get-tags-stats *db*))

;; IO database functions

;; (write-tags-stats *db*
;;		  "/home/migap/repos/mine/scratch/scheme/simple_db/tags.csv")


;; (begin
;;   (write-database ex-db
;;		  "/home/migap/repos/mine/scratch/scheme/simple_db/test.scm")
;;   (set! ex-db (add-entry ex-entry-4 entries))
;;   (write-database entries
;;		  "/home/migap/repos/mine/scratch/scheme/simple_db/test2.scm"))
