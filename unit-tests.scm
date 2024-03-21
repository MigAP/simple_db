(import test)
(import (chicken string))
(import (chicken load))
(import utf8)


(load-relative "./db-utils.scm")

(test-group "Constructor, getters, setters and comparisons"
  (define test-entry-title "Test Entry Title")
  (define test-entry-url "https://url.com")
  (define test-entry-tags '(tag1 tag2))
  (define test-entry-description "This is a description")

  (define test-entry (mk-entry test-entry-title
			       test-entry-url
			       test-entry-tags
			       test-entry-description))

  ;; Getters
  (test "Title getter test"
	test-entry-title
	(get-title test-entry))

  (test "Url getter test"
	test-entry-url
	(get-url test-entry))

  (test "Tags getter test"
	test-entry-tags
	(get-tags test-entry))

  (test "Description getter test"
	test-entry-description
	(get-description test-entry))

  ;; Setters
  (define test-entry-setter-title "New title")
  (define test-entry-setter-url "https://url2.com")
  (define test-entry-setter-tags '(a b c))
  (define test-entry-setter-description "New description")

  (set-title! test-entry test-entry-setter-title)
  (set-url! test-entry test-entry-setter-url)
  (set-tags! test-entry test-entry-setter-tags)
  (set-description! test-entry test-entry-setter-description)

  (test "Title setter test"
	test-entry-setter-title
	(get-title test-entry))

  (test "Url setter test"
	test-entry-setter-url
	(get-url test-entry))

  (test "Tags setter test"
	test-entry-setter-tags
	(get-tags test-entry))

  (test "Description setter test"
	test-entry-setter-description
	(get-description test-entry))

  ;; Comparison between entries
  (test-assert "Titles should match"
    (same-title? test-entry test-entry))

  (test-assert "Urls should match"
    (same-url? test-entry test-entry))

  (test-assert "Tags should match"
    (same-tags? test-entry test-entry))

  (test-assert "Descriptions should match"
    (same-description? test-entry test-entry))

  (test-assert "Entries should be equal"
    (same-entries? test-entry test-entry))

  ;; Tags specific comparisons
  (test-assert "Returns true when tag belong to the list of tags"
    (tag-inside? 'tag2 '(tag1 tag2 tag3)))

  (test-assert "Should return true because there is at least one common tag"
    (tags-or-comparison? (get-tags test-entry) '(c)))

  (test-assert "Should return true because there is at least one common tag"
    (common-tag? test-entry (mk-entry "" "" '(b e f) "")))


  )

(test-group "Database construction functions"
  ;; Data base constructor
  (define test-entry-1 (mk-entry "Test Entry Title"
				 "https://url.com"
				 '(tag1 tag2 tag3)
				 "First entry description"))

  (define test-entry-2 (mk-entry "Second Entry Title"
				 "https://second-entry.com"
				 '(tag1 tag3 tag4)
				 "Second test entry description"))

  (define test-entry-3 (mk-entry "Third Entry Title"
				 "https://third-entry.com"
				 '(tag1 tag4 tag5)
				 "Third test entry description"))

  (define test-entry-0 (mk-entry "Zero Entry Title"
				 "https://zero-entry.com"
				 '(tag0 tag5)
				 "Zero test entry description"))

  (define db (mk-db test-entry-1 test-entry-2 test-entry-3))

  (test-assert "The entries should be equal"
    (same-entries? test-entry-1 (next-entry db)))

  (test-assert "The entries shoudld be equal"
    (same-entries? test-entry-0 (next-entry (add-entry test-entry-0 db))))

  ;;; Database getters

  (test-assert "Titles should be equal"
    (equal? (get-db-titles db) (list (get-title test-entry-1)
				     (get-title test-entry-2)
				     (get-title test-entry-3))))

  (test-assert "Urls should be equal"
    (equal? (get-db-urls db) (list (get-url test-entry-1)
				   (get-url test-entry-2)
				   (get-url test-entry-3))))

  (test-assert "Tags should be equal"
    (equal? (get-db-tags db) (list (get-tags test-entry-1)
				   (get-tags test-entry-2)
				   (get-tags test-entry-3))))

  (test-assert "Description should be equal"
    (equal? (get-db-descriptions db) (list (get-description test-entry-1)
					   (get-description test-entry-2)
					   (get-description test-entry-3)))))

(test-group "Lookup functions"
  ;; Data base constructor

  (define test-entry-0 (mk-entry "Zero Entry Title"
				 "https://zero-entry.com"
				 '(tag0 tag5)
				 "Zero test entry description"))

  (define test-entry-1 (mk-entry "Test Entry Title"
				 "https://url.com"
				 '(tag1 tag2 tag3)
				 "First entry description"))

  (define test-entry-2 (mk-entry "Second Entry Title"
				 "https://second-entry.com"
				 '(tag1 tag3 tag4)
				 "Second test entry description"))

  (define test-entry-3 (mk-entry "Third Entry Title"
				 "https://third-entry.com"
				 '(tag1 tag4 tag5)
				 "Third test entry description"))


  (define db (mk-db test-entry-0 test-entry-1 test-entry-2 test-entry-3))
  ;;; Lookup functions

  (test-assert "Search by title, entries should be equal"
    (same-entries? test-entry-2 (lookup-entry-by-title db test-entry-2)))

  (test-assert "Search by url, entries should be equal"
    (same-entries? test-entry-2 (lookup-entry-by-url db test-entry-2)))

  (test-assert "Search by tags, entries should be equal"
    (same-entries? test-entry-2 (lookup-entry-by-tags db test-entry-2)))

  (test-assert "Search by tags (at least one common tag), Entries should be equal"
    (common-tag? test-entry-2 (lookup-entry-by-tags-or db
						       (mk-entry "" "" '(tag3) ""))))

  (test "Lookup and collect by title"
	1
	(lookup-and-collect-by-title db test-entry-3 length))

  (test "Lookup and collect by tags"
	1
	(lookup-and-collect-by-tags db test-entry-1 length))

  (test "Lookup and collect by tags or "
	3
	(lookup-and-collect-by-tags-or db test-entry-1 length))

  (test-assert "The titles should match"
    (equal? (get-db-titles (lookup-entries-with-common-tags db test-entry-1))
	    (list (get-title test-entry-1)
		  (get-title test-entry-2)
		  (get-title test-entry-3)))))

(test-group "Tag statistics functions"
  (define test-entry-0 (mk-entry "Zero Entry Title"
				 "https://zero-entry.com"
				 '(tag0 tag5)
				 "Zero test entry description"))

  (define test-entry-1 (mk-entry "Test Entry Title"
				 "https://url.com"
				 '(tag1 tag2 tag3)
				 "First entry description"))

  (define test-entry-2 (mk-entry "Second Entry Title"
				 "https://second-entry.com"
				 '(tag1 tag3 tag4)
				 "Second test entry description"))

  (define test-entry-3 (mk-entry "Third Entry Title"
				 "https://third-entry.com"
				 '(tag1 tag4 tag5)
				 "Third test entry description"))


  (define db (mk-db test-entry-0 test-entry-1 test-entry-2 test-entry-3))


  (test-assert "Set member function test"
    (member 'b '(a b c d)))

  (test-assert "Make a set from a list of atoms"
    (equal? (make-set '(a a b c b c d d d e f f))
	    '(a b c d e f)) )

  (test-assert "Set equality test"
    (same-set? '(c a b) '(a b c)))

  (test-assert "Get the set of tags in a database"
    (same-set? (get-tag-set db)
	       '(tag0 tag1 tag2 tag3 tag4 tag5)))

  (test "Occurrence of an atom in a set"
	3
	(occurrences 'a '(a b f a d a)))

  (test "Occurrences association list"
	(occurrences-alist '(a b c) '(a a a b b b c b c))
	'((a . 3) (b . 4) (c . 2)))

  (test "Database tags statistics"
	(get-tags-stats db)
	'((tag0 . 1) (tag2 . 1) (tag3 . 2) (tag1 . 3) (tag4 . 2) (tag5 . 2)))
  )

;; IMPORTANT! The following ensures nightly automated tests can
;; distinguish failure from success.  Always end tests/run.scm with this.
					;(test-exit)
