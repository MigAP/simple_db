(import (prefix gnuplot-pipe gp:))

(define (plot-bar-graph labels values)
  (gp:call/gnuplot
   (gp:send "set xlabel 'tags'")
   (gp:send "set yrange [0:*]")
   ;; (gp:send "set ylabel 'occurrences'")
   (gp:send "set boxwidth 0.1")
   (gp:send "set style fill solid")
   (gp:plot "using 2: xtic(1) with boxes notitle"
            labels values)))

;(plot-bar-graph '(label1 label2 label3) '(100 450 75 ))
;(plot-bar-graph '(label1 label2 label3) '(2 1 3))

(define (get-alist-keys alist)
  (if (null? alist)
      '()
      (cons (car (car alist))
	    (get-alist-keys (cdr alist)))))

;(get-alist-keys '((a . 1) (b . 2) (c . 3)))

(define (get-alist-values alist)
  (if (null? alist)
      '()
      (cons (cdr (car alist))
	    (get-alist-values (cdr alist)))))

;(get-alist-values '((a . 1) (b . 2) (c . 3)))

(define (plot-tags-stats tag-stats)
  (plot-bar-graph (get-alist-keys tag-stats)
		  (get-alist-values tag-stats)))

;(plot-tags-stats (get-tags-stats entries))
;(plot-tags-stats (get-tags-stats *urls*))
