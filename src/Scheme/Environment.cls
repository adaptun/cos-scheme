Class Scheme.Environment Extends %RegisteredObject
{

Property outer As Scheme.Environment;

Property data As %Object;

Method %OnNew(parms As %Array, args As %Array, outer As Scheme.Environment = "") As %Status
{
	set ..data = {}
	
	if $Data(parms) {
		set iter = parms.$getIterator()
		while iter.$getNext(.key , .value ) {
	   		do ..data.$set(value, args.$get(key))
		}
	}
	set ..outer = outer
	quit $$$OK
}

Method find(var) As Environment [ CodeMode = expression ]
{
$case(..data.$isDefined(var),1:$this,:..outer.find(var))
}

Method get(x) As %String [ CodeMode = expression ]
{
..data.$get(x)
}

Method put(var As %String, val)
{
	do ..data.$set(var, val)
}

ClassMethod standard() As Scheme.Environment
{
	set res = ..%New()
	
	for op="+","-","*","/",">","<",">=","<=","=","**" {
		do res.put(op, "(x,y) return x "_op_" y")
	}
	do res.put("abs","(x) return $zabs(x)")
	do res.put("pi", $zpi)
	do res.put("begin","(x...) return x(x)") //return last expression
	do res.put("car","(x) return x.$get(0)")
	do res.put("cdr","(x) set r=[], iter = x.$getIterator() do iter.$getNext()  while iter.$getNext(.key , .value ) {do r.$push(value)} return r")
	do res.put("cons","(x,y) set r=[] do r.$push(x) set iter = y.$getIterator()  while iter.$getNext(.key , .value ) {do r.$push(value)} return r")
	do res.put("equal?","(x,y) return (x = y) || ($isobject(x) && $isobject(y) && (x.$toJSON() = y.$toJSON()))")
	do res.put("procedure?","(x) return $isobject(x) && x.%IsA(""Scheme.Procedure"")")
	return res
}

}
