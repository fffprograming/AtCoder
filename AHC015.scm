(define (read-n n)
  (if (= n 0) '()
      (let ((ele (read)))
        (cons ele (read-n (- n 1))))))
(define ColorVec (list->vector (read-n 100)))
(define Table (make-vector 100 0))
(define checkedv (make-vector 100 0))
(define (simple-solve)
  (define (sub i)
    (if (>= i 100) 0
        (let ((inp (read)))
          (begin
            (vector-set! Table (color-set-index Table inp) (vector-ref ColorVec i))
            (display "F")
            (newline)
            (flush-all-ports)
            (set! Table (fore-shift Table))
            (sub (+ i 1))))))
  (sub 0))
(define (color-set-index v i)
  (define (sub index count)
    (cond ((and (= (vector-ref v index) 0) (= count 1)) index)
          ((= (vector-ref v index) 0) (sub (+ index 1) (- count 1)))
          (#t (sub (+ index 1) count))))
  (sub 0 i))
(define (right-shift v);50min
  (define (remove0 l)
    (cond ((null? l) '())
          ((= (car l) 0) (remove0 (cdr l)))
          (#t (cons (car l) (remove0 (cdr l))))))
  (define (fill0 l i)
    (if (= i 0) l
        (fill0 (cons 0 l) (- i 1))))
  (define (get-ith-10 i)
    (define (get-n modulo-index)
      (if (>= modulo-index 10) '()
          (cons (vector-ref v (+ (* i 10) modulo-index)) (get-n (+ modulo-index 1)))))
    (get-n 0))
  (define (sub i)
    (if (>= i 10) '()
        (let ((removed (remove0 (get-ith-10 i))))
          (append (fill0 removed (- 10 (length removed))) (sub (+ i 1))))))
  (list->vector (sub 0)))
(define (rotate-90-left v);56min
  (define (sub junokurai ichinokurai)
    (cond ((< ichinokurai 0) '())
          ((>= junokurai 10) (sub 0 (- ichinokurai 1)))
          (#t (cons (vector-ref v (+ (* junokurai 10) ichinokurai)) (sub (+ junokurai 1) ichinokurai)))))
  (list->vector (sub 0 9)))
(define (rotate-90-right v)
  (define (sub junokurai ichinokurai)
    (cond ((>= ichinokurai 10) '())
          ((< junokurai 0) (sub 9 (+ ichinokurai 1)))
          (#t (cons (vector-ref v (+ (* junokurai 10) ichinokurai)) (sub (- junokurai 1) ichinokurai)))))
  (list->vector (sub 9 0)))
(define (rotate-180 v) (list->vector (reverse (vector->list v))))
;(right-shift v)
(define (fore-shift v);65min
  (rotate-90-left (right-shift (rotate-90-right v))))
(define (back-shift v)
  (rotate-90-right (right-shift (rotate-90-left v))))
(define (left-shift v)
  (rotate-180 (right-shift (rotate-180 v))))
(define (display10 v)
  (define (sub i)
    (cond ((>= i 100) (newline))
          ((= (modulo i 10) 9)
           (begin (display (vector-ref v i)) (newline) (sub (+ i 1))))
          (#t (begin (display (vector-ref v i))( display " ") (sub (+ i 1))))))
  (sub 0))
(define (calc-score v);117min
  (define (sub startindex nowcolor nextchecklist nowvolume score)
    (cond ((>= startindex 100) score)
          ((= nowcolor 0) (sub (+ startindex 1) (if (= startindex 99) 0 (vector-ref v (+ startindex 1))) (list (+ startindex 1)) 1 score))
          ((null? nextchecklist) (sub (+ startindex 1) (if (= startindex 99) 0 (vector-ref v (+ startindex 1))) (list (+ startindex 1)) 1 (+ score (* nowvolume nowvolume))))
          (#t (let* ((nowpoint (car nextchecklist))
                     (nowlist (cdr nextchecklist))
                     (fpoint (- nowpoint 10))(bpoint (+ nowpoint 10))(lpoint (- nowpoint 1))(rpoint (+ nowpoint 1))
                     (fcan (and (>= fpoint 0) (= (vector-ref checkedv fpoint) nowcolor)))
                     (bcan (and (< bpoint 100) (= (vector-ref checkedv bpoint) nowcolor)))
                     (lcan (and (= (quotient lpoint 10) (quotient nowpoint 10)) (>= lpoint 0) (= (vector-ref checkedv lpoint) nowcolor)))
                     (rcan (and (= (quotient rpoint 10) (quotient nowpoint 10)) (= (vector-ref checkedv rpoint) nowcolor)))
                     (fdlist (if fcan (cons fpoint nowlist) nowlist))
                     (bdlist (if bcan (cons bpoint fdlist) fdlist))
                     (ldlist (if lcan (cons lpoint bdlist) bdlist))
                     (rdlist (if rcan (cons rpoint ldlist) ldlist))
                     (nextvolume (+ (if fcan 1 0) (if bcan 1 0) (if lcan 1 0) (if rcan 1 0) nowvolume))
                     (checked! (begin (if fcan (vector-set! checkedv fpoint 0) 0) (if bcan (vector-set! checkedv bpoint 0) 0)
                                      (if lcan (vector-set! checkedv lpoint 0) 0) (if rcan (vector-set! checkedv rpoint 0) 0))) 
                     )
                (sub startindex nowcolor rdlist nextvolume score)))))
  (begin
    (set! checkedv (vector-copy v));checkedv というvectorを別に作る
    (sub 0 (vector-ref checkedv 0) (list 0) 1 0)))

(define (donyoku-solve);133min
  (define (sub i)
    (if (>= i 100) 0
        (let ((inp (read)))
          (begin
            (vector-set! Table (color-set-index Table inp) (vector-ref ColorVec i))
            (let* ((fscore (calc-score (fore-shift Table)))
                   (bscore (calc-score (back-shift Table)))
                   (lscore (calc-score (left-shift Table)))
                   (rscore (calc-score (right-shift Table)))
                   (max-score (max fscore bscore lscore rscore)))
              (if (= fscore max-score) (begin (display "F") (newline) (flush-all-ports) (set! Table (fore-shift Table)))
                  (if (= bscore max-score) (begin (display "B") (newline) (flush-all-ports) (set! Table (back-shift Table)))
                      (if (= lscore max-score) (begin (display "L") (newline) (flush-all-ports) (set! Table (left-shift Table)))
                          (begin (display "R") (newline) (flush-all-ports) (set! Table (right-shift Table)))))))
            (sub (+ i 1))))))
  (sub 0))
;(donyoku-solve)
(define for-donyoku2-v (make-vector 100 0))
(define (calc-next-kitaichi v left0count nextcolor)
  (define (sub i score)
    (if (> i left0count) score
        (begin
          (set! for-donyoku2-v (vector-copy v))
          (vector-set! for-donyoku2-v i nextcolor)
          (sub (+ i 1) (+ score (max (calc-score (left-shift for-donyoku2-v)) (calc-score (right-shift for-donyoku2-v))
                                      (calc-score (back-shift for-donyoku2-v)) (calc-score (fore-shift for-donyoku2-v))))))))
  (sub 1 0))
(define (donyoku2-solve);160min, TLE
  (define (sub i)
    (if (>= i 99) 0
        (let ((inp (read)))
          (begin
            (vector-set! Table (color-set-index Table inp) (vector-ref ColorVec i))
            (let* ((fscore (calc-next-kitaichi (fore-shift Table) (- 99 i) (vector-ref ColorVec (+ i 1))))
                   (bscore (calc-next-kitaichi (back-shift Table) (- 99 i) (vector-ref ColorVec (+ i 1))))
                   (lscore (calc-next-kitaichi (left-shift Table) (- 99 i) (vector-ref ColorVec (+ i 1))))
                   (rscore (calc-next-kitaichi (right-shift Table) (- 99 i) (vector-ref ColorVec (+ i 1))))
                   (max-score (max fscore bscore lscore rscore)))
              (if (= fscore max-score) (begin (display "F") (newline) (flush-all-ports) (set! Table (fore-shift Table)))
                  (if (= bscore max-score) (begin (display "B") (newline) (flush-all-ports) (set! Table (back-shift Table)))
                      (if (= lscore max-score) (begin (display "L") (newline) (flush-all-ports) (set! Table (left-shift Table)))
                          (begin (display "R") (newline) (flush-all-ports) (set! Table (right-shift Table)))))))
            (sub (+ i 1))))))
  (sub 0))
;(donyoku2-solve)
(define (donyoku-half-solve)
  (define (sub i)
    (cond ((>= i 99) 0)
          ((>= i 70) ; 50->166min, 80->172min
           (let ((inp (read)))
           (begin
             (vector-set! Table (color-set-index Table inp) (vector-ref ColorVec i))
             (let* ((fscore (calc-next-kitaichi (fore-shift Table) (- 99 i) (vector-ref ColorVec (+ i 1))))
                    (bscore (calc-next-kitaichi (back-shift Table) (- 99 i) (vector-ref ColorVec (+ i 1))))
                    (lscore (calc-next-kitaichi (left-shift Table) (- 99 i) (vector-ref ColorVec (+ i 1))))
                    (rscore (calc-next-kitaichi (right-shift Table) (- 99 i) (vector-ref ColorVec (+ i 1))))
                    (max-score (max fscore bscore lscore rscore)))
               (if (= fscore max-score) (begin (display "F") (newline) (flush-all-ports) (set! Table (fore-shift Table)))
                   (if (= bscore max-score) (begin (display "B") (newline) (flush-all-ports) (set! Table (back-shift Table)))
                       (if (= lscore max-score) (begin (display "L") (newline) (flush-all-ports) (set! Table (left-shift Table)))
                           (begin (display "R") (newline) (flush-all-ports) (set! Table (right-shift Table)))))))
             (sub (+ i 1)))))
          (#t
           (let ((inp (read)))
            (begin
             (vector-set! Table (color-set-index Table inp) (vector-ref ColorVec i))
             (let* ((fscore (calc-score (fore-shift Table)))
                    (bscore (calc-score (back-shift Table)))
                    (lscore (calc-score (left-shift Table)))
                    (rscore (calc-score (right-shift Table)))
                    (max-score (max fscore bscore lscore rscore)))
               (if (= fscore max-score) (begin (display "F") (newline) (flush-all-ports) (set! Table (fore-shift Table)))
                   (if (= bscore max-score) (begin (display "B") (newline) (flush-all-ports) (set! Table (back-shift Table)))
                       (if (= lscore max-score) (begin (display "L") (newline) (flush-all-ports) (set! Table (left-shift Table)))
                           (begin (display "R") (newline) (flush-all-ports) (set! Table (right-shift Table)))))))
             (sub (+ i 1)))))))
  (sub 0))

(define for-donyoku2-v (make-vector 100 0))
(define (calc-next-kitaichi-with-rand v input-list nextcolor)
  (define (sub l score)
    (if (null? l) score
        (begin
          (set! for-donyoku2-v (vector-copy v))
          (vector-set! for-donyoku2-v (car l) nextcolor)
          (sub (cdr l) (+ score (max (calc-score (left-shift for-donyoku2-v)) (calc-score (right-shift for-donyoku2-v))
                                      (calc-score (back-shift for-donyoku2-v)) (calc-score (fore-shift for-donyoku2-v))))))))
  (sub input-list 0))
(define (donyoku-with-rand-solve);180min
  (define (gene-10s maxindex)
    (define (hojo i)
      (if (> i maxindex) '()
          (cons i (hojo (+ i (max (quotient maxindex 13) 1))))))
    (hojo 1))
  (define (sub i)
    (if (>= i 99) 0
        (let ((inp (read))
              (kouhol (gene-10s (- 99 i))))
          (begin
            (vector-set! Table (color-set-index Table inp) (vector-ref ColorVec i))
            (let* ((fscore (calc-next-kitaichi-with-rand (fore-shift Table) kouhol (vector-ref ColorVec (+ i 1))))
                   (bscore (calc-next-kitaichi-with-rand (back-shift Table) kouhol (vector-ref ColorVec (+ i 1))))
                   (lscore (calc-next-kitaichi-with-rand (left-shift Table) kouhol (vector-ref ColorVec (+ i 1))))
                   (rscore (calc-next-kitaichi-with-rand (right-shift Table) kouhol (vector-ref ColorVec (+ i 1))))
                   (max-score (max fscore bscore lscore rscore)))
              (if (= fscore max-score) (begin (display "F") (newline) (flush-all-ports) (set! Table (fore-shift Table)))
                  (if (= bscore max-score) (begin (display "B") (newline) (flush-all-ports) (set! Table (back-shift Table)))
                      (if (= lscore max-score) (begin (display "L") (newline) (flush-all-ports) (set! Table (left-shift Table)))
                          (begin (display "R") (newline) (flush-all-ports) (set! Table (right-shift Table)))))))
            (sub (+ i 1))))))
  (sub 0))
(donyoku-with-rand-solve)
;(donyoku-half-solve)           
;(display10 Table)(newline)
;(display (calc-score Table)) (newline)
;(display (rotate-90-left (rotate-90-left (rotate-90-left (rotate-90-left Table)))))(newline)
;(display (rotate-90-left Table))(newline)