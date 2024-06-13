Class Scheme.Environment Extends %RegisteredObject
{

Property outer As Scheme.Environment;

Property data As %DynamicAbstractObject;

Method %OnNew(parms As %DynamicArray, args As %DynamicArray, outer As Scheme.Environment = "") As %Status
{
	set ..data = {}
	
	if $Data(parms) {
		set iter = parms.%GetIterator()
		while iter.%GetNext(.key , .value ) {
	   		do ..data.%Set(value, args.%Get(key))
		}
	}
	set ..outer = outer
	quit $$$OK
}

Method find(var) As Environment [ CodeMode = expression ]
{
$case(..data.%IsDefined(var),1:$this,:..outer.find(var))
}

Method get(x) As %String [ CodeMode = expression ]
{
..data.%Get(x)
}

Method put(var As %String, val)
{
	do ..data.%Set(var, val)
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
	do res.put("car","(x) return x.%Get(0)")
	do res.put("cdr","(x) set r=[], iter = x.%GetIterator() do iter.%GetNext()  while iter.%GetNext(.key , .value ) {do r.%Push(value)} return r")
	do res.put("cons","(x,y) set r=[] do r.%Push(x) set iter = y.%GetIterator()  while iter.%GetNext(.key , .value ) {do r.%Push(value)} return r")
	do res.put("equal?","(x,y) return (x = y) || ($isobject(x) && $isobject(y) && (x.%ToJSON() = y.%ToJSON()))")
	do res.put("procedure?","(x) return $isobject(x) && x.%IsA(""Scheme.Procedure"")")
	return res
}

}
