# cos-scheme
basic implementation of Scheme in Caché ObjectScript

Algorithm is taken from 
http://norvig.com/lispy.html

    USER>do ##class(Scheme.Main).repl()
    lisp> (define circle-area (lambda (r) (* pi (* r r))))
    lisp> (circle-area 3)
    28.27433388230813914
    lisp> (define fact (lambda (n) (if (<= n 1) 1 (* n (fact (- n 1))))))
    lisp> (fact 10)
    3628800
    lisp> (circle-area (fact 10))
    41369087205782.69341
    lisp> (define twice (lambda (x) (* 2 x)))
    lisp> (define repeat (lambda (f) (lambda (x) (f (f x)))))
    lisp> ((repeat twice) 10)
    40
    lisp> ((repeat (repeat twice)) 10)
    160
    lisp> ((repeat (repeat (repeat twice))) 10)
    2560
    lisp>:q
    USER>

Supported special forms:
 1. (quote exp)
 2. (if test conseq alt)
 3. (define var exp)
 4. (set! var exp)
 5. (lambda (var...) body)

Embedded functions:
 1. (abs num)
 2. (car list)
 3. (cdr list)
 4. (cons x y)
 5. (equal? x y)
 6. (procedure? x)
