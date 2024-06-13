Class Scheme.Procedure Extends %RegisteredObject
{

Property parms As %Array;

Property body As %Array;

Property env As Environment;

Method %OnNew(parms As %Array, body As %Array, env As Environment) As %Status [ Private, ServerOnly = 1 ]
{
	set ..parms = parms
	set ..body = body
	set ..env = env
	Quit $$$OK
}

Method call(args As %Array)
{
	return ##class(Scheme.Main).eval(..body, ##class(Scheme.Environment).%New(..parms, args, ..env))
}

}
