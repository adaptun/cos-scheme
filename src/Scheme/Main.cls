/// ideas are taken from 
/// http://norvig.com/lispy.html
Class Scheme.Main Extends %RegisteredObject
{

Parameter trace = 0;

ClassMethod tokenize(chars As %String) As %DynamicArray
{
	set str = $replace($replace(chars,"("," ( "),")"," ) ")
	set res = []
	for i=1:1:$Length(str, " ") {
		set item = $Piece(str, " ", i)
		if item'="" {
			do res.%Push(item)
		}
	}
	return res
}

ClassMethod parse(program As %String) As %DynamicArray
{
	return ..readFromTokens(..tokenize(program))
}

ClassMethod readFromTokens(ByRef tokens As %DynamicArray) As %DynamicArray
{
	if tokens.%Size() = 0 {
		throw ##class(%Exception.General).%New("unexpected EOF while reading",100)
	}
	set token = tokens.%Get(0) 
	do tokens.%Remove(0)
	if token = "(" {
		set L = []
		while tokens.%Get(0) '= ")" {
			do L.%Push(..readFromTokens(.tokens))
		}
		do tokens.%Remove(0)
		return L
	} elseif token = ")" {
		throw ##class(%Exception.General).%New("unexpected )",101,,tokens.%ToJSON())
	} else {
		return ..atom(token)
	}
}

ClassMethod isNumber(s As %String) As %Boolean [ CodeMode = expression, Private ]
{
s = +s
}

ClassMethod atom(token As %String)
{
	if ..isNumber(token) {
		quit +token
	} else {
		quit token
	}
}

ClassMethod eval(x, env As Scheme.Environment = {##class(Scheme.Environment).standard()}) As %String
{
	if ..#trace = 1 {
		write "evaluating: ",$case($isobject(x),1:x.%ToJSON(),:x),!
	}
	if ..isNumber(x) {  //constant literal
		write:..#trace "it is constant",!
		set res = x
	}elseif '$isobject(x) { //variable reference
		write:..#trace "it is var ref",!
		set res = env.find(x).get(x)
	}elseif x.%Size() = 0 {
		write:..#trace "it is constant",!
		set res = x
	}elseif x.%Get(0) = "quote" { // (quote exp)
		set res = x.%Get(1)
	}elseif x.%Get(0) = "if" { // (if test conseq alt)
		set test = x.%Get(1)
		set conseq = x.%Get(2)
		set alt = x.%Get(3)
		set testres = ..eval(test, env)
		//we treat empty list () as false!
		if testres && ('$isobject(testres) || testres.%Size()) {
			set exp = conseq
		} else {
			set exp = alt
		}
		set res = ..eval(exp, env)
	}elseif x.%Get(0) = "define" { // (define var exp)
		set var = x.%Get(1)
		set exp = x.%Get(2)
		do env.put(var, ..eval(exp, .env))
		set res = "" // TODO: or what should define return?
	}elseif x.%Get(0) = "set!" { // (set! var exp)
		set var = x.%Get(1)
		set exp = x.%Get(2)
		do env.find(var).put(var, ..eval(exp, .env))
		set res = "" // TODO: or what should set! return?
	}elseif x.%Get(0) = "lambda" { //(lambda (var...) body)
		set parms = x.%Get(1)
		set body = x.%Get(2)
		set res = ##class(Scheme.Procedure).%New(parms, body, env)
	} else {
		set proc = ..eval(x.%Get(0), env)
		kill args
		set args=0
		
		set iter = x.%GetIterator()
		while iter.%GetNext(.key , .value ) {
			continue:key=0
			set args = args+1
			set args(args) = ..eval(value, env)
		}
		
		if ..#trace {
			write "===calling proc==",!
			write $isobject(proc),!
			zwrite proc
			write "===with args==",!
			zwrite args
		}
		
		if $isobject(proc) {
			//convert args from multidimensional to $Array
			set normargs = []
			for i=1:1:args {
				do normargs.%Push(args(i))
			}
			set res = proc.call(normargs)
		} else {
			set res = $xecute(proc,args...)
		}
	}
	return res
}

/// do ##class(Scheme.Main).repl()
ClassMethod repl(prompt As %String = "lisp> ")
{
	while 1 {
		write prompt
		read x,!
		if x=":q" {
			quit
		}
		set val = ..eval(..parse(x),.env)
		write:val'="" ..schemestr(val),!
	}
}

ClassMethod schemestr(exp As %DynamicArray) As %String
{
	if $isobject(exp) {
		set res = "("
		set iter = exp.%GetIterator()
	    while iter.%GetNext(.key , .value ) {
		    if $isobject(value) {
			    set res = res _ ..schemestr(value)
		    } else {
			    set res = res _ value
		    }
		    set res = res _ " " 
	    }
		set:res'="(" $Extract(res,*)=""
		return res _ ")"
	} else {
		return exp
	}
}

/// do ##class(Scheme.Main).test()
ClassMethod test()
{
	set p=5
	set p(1) = "(define map (lambda (fun L) (if L (cons (fun (car L)) (map fun (cdr L))) () )))"
	set p(2) = "(define fact (lambda (n) (if (<= n 1) 1 (* n (fact (- n 1))))))"
	set p(3) = "(define range (lambda (a b) (if (= a b) (quote ()) (cons a (range (+ a 1) b)))))"
	set p(4) = "(range 0 10)"
	set p(5) = "(map fact (range 0 10))"
	

		for i=1:1:p {
			write ">>",p(i),!
			set val = ..eval(..parse(p(i)), .env)
			write:val'="" ..schemestr(val),!
		}
}

}
