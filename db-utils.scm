(import (chicken string))
(import (chicken load))
(import utf8)
(import (list-utils basic))

;; Entries constructors
(define (mk-entry title url tags description)
  (list (cons 'title title)
	(cons 'url url)
	(cons 'tags (list tags))
	(cons 'description description)))

;; Entries getters and setters
(define (get-title entry)
  (cdr (list-ref entry 0)))

(define (get-url entry)
  (cdr (list-ref entry 1)))

(define (get-tags entry)
  (cadr (list-ref entry 2)))

(define (get-description entry)
  (cdr (list-ref entry 3)))

(define (set-title! entry title)
  (list-set! entry 0
	     (cons 'title title)))

(define (set-url! entry url)
  (list-set! entry 1
	     (cons 'url url)))

(define (set-tags! entry tags)
  (list-set! entry 2
	     (cons 'tags (list tags))))

(define (set-description! entry desc)
  (list-set! entry 3
	     (cons 'description desc)))

;; Comparison between entries
(define (compair-entries-f getter-f predicate-f)
  (lambda (e1 e2)
    (predicate-f (getter-f e1)
		 (getter-f e2))))

(define same-title? (compair-entries-f get-title string=?))
(define same-url? (compair-entries-f get-url string=?))
(define same-tags? (compair-entries-f get-tags equal?))
(define same-description? (compair-entries-f get-description string=?))

(define (same-entries? e1 e2)
  (and
   (same-title? e1 e2)
   (same-url? e1 e2)
   (same-tags? e1 e2)
   (same-description? e1 e2)))

; returns true if tag is inside ltags
(define (tag-inside? tag ltags)
  (cond
   ((null? ltags) #f )
   ((eq? tag (car ltags)) #t)
   (else
    (or (tag-inside? tag (cdr ltags))))))

;(tag-inside? 'c '(a b d e))

;; returns true if there is a common tag between the lists of tags
(define (tags-or-comparison? ltags1 ltags2)
  (cond
   ((null? ltags1) #f)
   ((tag-inside? (car ltags1) ltags2) #t)
   (else
    (or (tags-or-comparison? (cdr ltags1) ltags2)))))

;; returns true if e1 and e2 have at least one common tag
(define (common-tag? e1 e2)
  (tags-or-comparison? (get-tags e1) (get-tags e2)))

;; Database constructors
(define mk-db list)
(define next-entry car)
(define db-rest cdr)
(define (add-entry entry db)
  (cons entry db))

;; Print entries and database
(define (print-title entry)
  (display "title:\t")
  (display (get-title entry))
  (newline))

(define (print-url entry)
  (display "url:\t")
  (display (get-url entry))
  (newline))

(define (print-tags entry)
  (display "tags:\t")
  (display (get-tags entry))
  (newline))

(define (print-description entry)
  (display "description:\t")
  (display (get-description entry))
  (newline))

(define (print-entry entry)
  (print-title entry)
  (print-url entry)
  (print-tags entry)
  (print-description entry))

(define (print-entry-csv entry)
  (display (get-title entry))
  (display ",")
  (display (get-url entry))
  (display ",")
  (display (get-tags entry))
  (display ",")
  (display (get-description entry))
  (newline))

(define (print-entry-tsv entry)
  (display (get-title entry))
  (display "\t")
  (display (get-url entry))
  (display "\t")
  (display (get-tags entry))
  (display "\t")
  (display (get-description entry))
  (newline))

(define (print-db db)
  (map print-entry db))

(define (print-db-csv db)
  (map print-entry-csv db))

(define (print-db-tsv db)
  (map print-entry-tsv db))

;; Functions to extract parameters from a list of entries
(define (get-db-f getter-f)
  (lambda (db)
    (if (null? db)
	'()
	(add-entry (getter-f (next-entry db))
		   ((get-db-f getter-f)
		    (db-rest db))))))

(define get-db-titles (get-db-f get-title))
(define get-db-urls (get-db-f get-url))
(define get-db-tags (get-db-f get-tags))
(define get-db-descriptions (get-db-f get-description))

;; Lookup database functions
(define (lookup-entry-f comparison-f)
  (lambda (db entry)
    (cond
     ((null? db) '())
     ((comparison-f entry
		    (next-entry db))
      (next-entry db))
     (else ((lookup-entry-f comparison-f)
	    (db-rest db)
	    entry)))))

(define lookup-entry-by-title (lookup-entry-f same-title?))
(define lookup-entry-by-url (lookup-entry-f same-url?))
(define lookup-entry-by-tags (lookup-entry-f same-tags?))
(define lookup-entry-by-tags-or (lookup-entry-f common-tag?)) ; one common tag
(define lookup-entry-by-description (lookup-entry-f same-description?))
(define lookup-entry (lookup-entry-f same-entries?))

(define (lookup-and-collect-f comparison-f)
  (lambda (db entry collector)
    (cond
     ((null? db)
      (collector '()))

     ((comparison-f (next-entry db)
		    entry)
      ((lookup-and-collect-f comparison-f)
       (db-rest db)
       entry
       (lambda (collected)
	 (collector (add-entry (next-entry db) collected )))))

     (else ((lookup-and-collect-f comparison-f)
	    (db-rest db)
	    entry
	    (lambda (collected)
	      (collector collected)))))))

(define lookup-and-collect-by-title (lookup-and-collect-f same-title?))
(define lookup-and-collect-by-tags (lookup-and-collect-f same-tags?))
(define lookup-and-collect-by-tags-or (lookup-and-collect-f common-tag?))

; returns all the entries that have at least one matching tag with
; entry
(define (lookup-entries-with-common-tags db entry)
  (lookup-and-collect-by-tags-or db entry (lambda (x) x)))


;; Tags statistics from the database

;;; test if atom a is part of the list of atoms lat (Little schemer chap 2)
(define (member? a lat)
  (cond
   ((null? lat) #f)
   (else (or (eq? (car lat) a)
	      (member? a (cdr lat))))))


;;; make a set from a list of atoms (Little Schemer chap7)
(define (make-set lat)
  (cond
   ((null? lat) '())
   ((member? (car lat) (cdr lat))
    (make-set (cdr lat)))
   (else (add-entry (car lat)
		    (make-set (cdr lat))))))

(define (get-tag-set db)
  (make-set
   (flatten (get-db-tags db))))

;;; returns the number of times an atom "a" appears in a list of atoms
;;; "lat"
(define (occurrences a lat)
  (cond
   ((null? lat) 0)
   ((eq? (car lat) a)
    (add1 (occurrences a (cdr lat))))
   (else (occurrences a (cdr lat)))))

;(occurrences 'a '(a b f a d a))

;;; returns an alist whose keys are the lat-to-search and the values
;;; correspond to the number of times each atom appeart on lat
(define (occurrences-alist lat-to-search lat)
  (cond
   ((null? lat-to-search) '())
   (else
    (cons (cons (car lat-to-search)
		(occurrences (car lat-to-search) lat))
	  (occurrences-alist (cdr lat-to-search) lat)))))



;;; returns an alist with the number of times a tag appears in the
;;; database
(define (get-tags-stats db)
  (occurrences-alist (get-tag-set db)
		     (flatten (get-db-tags db))))


;; IO database functions

;;; write database to a file
(define (write-database db path)
  (call-with-output-file path
    (lambda (path)
      (write db path))))

(define (write-tags-stats db path)
  (let ((stats (get-tags-stats db)))
    (call-with-output-file path
      (lambda (path)
	(for-each (lambda (pair)
		    (display (car pair) path)
		    (display "\t" path)
		    (display (cdr pair) path)
		    (newline path))
		  stats)))))
