Class Scheme.Procedure Extends %RegisteredObject
{

Property parms As %DynamicArray;

Property body As %DynamicArray;

Property env As Environment;

Method %OnNew(parms As %DynamicArray, body As %DynamicArray, env As Environment) As %Status [ Private, ServerOnly = 1 ]
{
	set ..parms = parms
	set ..body = body
	set ..env = env
	Quit $$$OK
}

Method call(args As %DynamicArray)
{
	return ##class(Scheme.Main).eval(..body, ##class(Scheme.Environment).%New(..parms, args, ..env))
}

}
