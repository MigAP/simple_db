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

  (get-db-titles db) 

  )


;; IMPORTANT! The following ensures nightly automated tests can
;; distinguish failure from success.  Always end tests/run.scm with this.
(test-exit)
