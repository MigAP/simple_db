(import (chicken port)
	(chicken process-context)
	(chicken io)
	(chicken load))

(include-relative "./db-utils.scm")

(define *l-param* "-l")
(define *a-param* "-a")
(define *s-param* "-s")
(define *p-param* "-p")
(define *e-param* "-e")
(define *g-param* "-g")
(define *h-param* "-h")

(define h-param? #t)
(define l-param? #f)
(define a-param? #f)
(define s-param? #f)
(define p-param? #f)
(define e-param? #f)
(define g-param? #f)

(define a-args '())
(define s-args '())
(define e-args '())
(define g-args '())

(define *help-string*
  "NAME
	sdb - simple data base

SYNOPSIS
	sdb -l [PATH TO DB] [OPTIONS]


DESCRIPTION
	-h
	  prints this help

	-l PATH
	    load the databse specified by PATH

	-s [FIELD]
	   search for a specific entry in the databse with the same
	   FIELD. For example, -s title -> searches an entry with the
	   same title. Currently supported fields are: title, url,
	   tags, tags-or (searches an entry with at least one common
	   tag), description.

	-e [FORMAT]
	   exports to format, default is tsv

	-p
	   plots the number of tags used

	-g FIELD
	  prints all the fields for each entry in the database

	-a
	   Asks the user to prompt a new entry and then prints the new database.")

(define (print-help)
  (display *help-string*))

(define (h-param-f arg)
  (set! h-param? #t)
  (print-help)
  (exit))

(define (l-param-f arg)
  (set! l-param? #t)
  (if (null? arg)
      (begin
	(display "Error: please specify a PATH to the database.\n")
	(exit))
      (load-relative arg)))

;; TODO: Allow to add an entry from the command line without the prompt
(define (a-param-f arg)
  (set! a-param? #t)
  (if (not (null? arg))
      (set! a-args arg)))

(define (s-param-f search-field)
  (if (null? search-field)
      (display "Please enter a search field\n")
      (begin
	(set! s-param? #t)
	(set! s-args search-field))))

(define (p-param-f)
  (set! p-param? #t))

(define (e-param-f format)
  (set! e-param? #t)
  (cond
   ((null? format)
    (set! e-args 'tsv))
   ((string=? format "tsv")
    (set! e-args 'tsv))
   ((string=? format "csv")
    (set! e-args 'csv))))

(define (g-param-f field)
  (if (null? field)
      (display "Please enter a field\n")
      (begin
	(set! g-param? #t)
	(set! g-args field))))


(define (is-param? arg)
  (if (char=? #\- (string-ref arg 0))
      #t
      #f))

(define (arg->param arg)
  (string-ref arg 1))

(define (next-arg list-args)
  (car list-args))

(define (rest-args list-args)
  (cdr list-args))

(define (command-line-arguments-alist list-args)
  (cond
   ((null? list-args) '())
   ((is-param? (next-arg list-args))
    (cond
     ((null? (rest-args list-args)) ; no further arguments
      (cons (cons (next-arg list-args)
		  '())
	    (command-line-arguments-alist (rest-args list-args))))

     ((is-param? (next-arg (rest-args list-args)))
      (cons (cons (next-arg list-args)
		  '())
	    (command-line-arguments-alist (rest-args list-args))))
     (else
      (cons (cons (next-arg list-args)
		  (next-arg (rest-args list-args)))
	    (command-line-arguments-alist (rest-args (rest-args list-args)))))))
   (else
    (display "Error: please use a dash '-' to specify a parameter\n")
    (exit))))

(define (param-key param-alist)
  (car (car param-alist)))

(define (param-value param-alist)
  (cdr (car param-alist)))

;; iteratively call the apropriate functions depending on the values
;; of param-alist
(define (params-handler param-alist)
  (if (null? param-alist)
      #t
      (cond
       ((equal? (param-key param-alist) *h-param*)
	(h-param-f (param-value param-alist))
	(params-handler (cdr param-alist)))

       ((equal? (param-key param-alist) *l-param*)
	(l-param-f (param-value param-alist))
	(params-handler (cdr param-alist)))

       ((equal? (param-key param-alist) *a-param*)
	(a-param-f (param-value param-alist))
	(params-handler (cdr param-alist)))

       ((equal? (param-key param-alist) *s-param*)
	(s-param-f (param-value param-alist))
	(params-handler (cdr param-alist)))

       ((equal? (param-key param-alist) *p-param*)
	(p-param-f)
	(params-handler (cdr param-alist)))

       ((equal? (param-key param-alist) *e-param*)
	(e-param-f (param-value param-alist))
	(params-handler (cdr param-alist)))

       ((equal? (param-key param-alist) *g-param*)
	(g-param-f (param-value param-alist))
	(params-handler (cdr param-alist)))

       (else
	(display "Error: unknown parameter ")
	(display (param-key param-alist))
	(newline)
	(display "Usage: sdb -l [PATH TO DB] [OPTIONS]\n")
	#f))))

(define (prompt-entry)
  (let ((title "")
	(url "")
	(tags '())
	(description ""))
    (display "Enter title: ")
    (set! title (read-line))

    (display "Enter url: ")
    (set! url (read-line))

    (display "Enter tags separated by a space: ")
    (set! tags (map string->symbol
		    (string-split (read-line))))

    (display "Enter description: ")
    (set! description (read-line))

    (mk-entry title url tags description)))

(define (prompt-search search-field)
  (let ((search-entry (mk-entry "" "" '() "")))
    (cond
     ((string=? search-field "title")
      (display "Enter title: ")
      (set-title! search-entry (read-line))
      (lookup-entry-by-title *db* search-entry))

     ((string=? search-field "url")
      (display "Enter url: ")
      (set-url! search-entry (read-line))
      (lookup-entry-by-url *db* search-entry))

     ((string=? search-field "tags")
      (display "Enter tags separated by a space: ")
      (set-tags! search-entry
		 (map string->symbol (string-split (read-line))))
      (lookup-entry-by-tags *db* search-entry))

     ((string=? search-field "tags-or")
      (display "Enter tags separated by a space: ")
      (set-tags! search-entry
		 (map string->symbol (string-split (read-line))))
      (lookup-entries-with-common-tags *db* search-entry))

     ((string=? search-field "description")
      (display "Enter description: ")
      (set-description! search-entry (read-line))
      (lookup-entry-by-description search-entry))

     (else
      (display "Error: unknown search field, allowed search fields are: title, url, tags, tags-or, description\n")))))
