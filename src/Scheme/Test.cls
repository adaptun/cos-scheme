Class Scheme.Test Extends %Base
{

/// do ##class(Scheme.Test).run()
ClassMethod run(verbose As %Boolean = 0)
{
	set testjson = ##class(%Dictionary.XDataDefinition).%OpenId(..%ClassName(1) _ "||test").Data
	set json = {}.%FromJSON(testjson)
	set iter = json.%GetIterator()
	while iter.%GetNext(.key , .value ) {
	    set cmd = value.%Get(0)
	    set res = value.%Get(1)
	    
	    write:verbose ">",cmd,!
	    set val = ##class(Scheme.Main).eval(##class(Scheme.Main).parse(cmd), .env)
		set:val'="" val=##class(Scheme.Main).schemestr(val)
		if val'=res {
			write cmd,!
			write "expected:", res,!
			write "received:", val,!
			write "====================",!
		}elseif verbose {
			write val,!
		}
	}
}

XData test [ MimeType = application/json ]
{
[
	["(define circle-area (lambda (r) (* pi (* r r))))",""],
	["(define fact (lambda (n) (if (<= n 1) 1 (* n (fact (- n 1))))))",""],
	["(fact 10)","3628800"],
	["(define twice (lambda (x) (* 2 x)))",""],
	["(define repeat (lambda (f) (lambda (x) (f (f x)))))",""],
	["((repeat twice) 10)",40],
	["((repeat (repeat twice)) 10)",160],
	["((repeat (repeat (repeat twice))) 10)",2560],
	["(define fib (lambda (n) (if (< n 2) 1 (+ (fib (- n 1)) (fib (- n 2))))))",""],
	["(fib 9)","55"],
	["(define x 7)",""],
	["(set! x 10)",""],
	["(+ x 1)","11"],
	["(quote (the more the merrier the bigger the better))","(the more the merrier the bigger the better)"],
	["(define first car)",""],
	["(define rest cdr)",""],
	["(equal? 2 ())",0],
	["(define count (lambda (item L) (if L (+ (equal? item (first L)) (count item (rest L))) 0)))",""],
	["(count 0 (quote (0 1 2 3 0 0)))",3],
	["(count (quote the) (quote (the more the merrier the bigger the better)))",4],
	["(define range (lambda (a b) (if (= a b) (quote ()) (cons a (range (+ a 1) b)))))",""],
	["(range 0 10)","(0 1 2 3 4 5 6 7 8 9)"],
	["(define map (lambda (fun L) (if L (cons (fun (car L)) (map fun (cdr L))) () )))",""],
	["(map fib (range 0 10))","(1 1 2 3 5 8 13 21 34 55)"]
	]
}

}
