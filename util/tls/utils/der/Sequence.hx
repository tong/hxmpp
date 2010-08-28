package tls.utils.der;

extern class Sequence extends Array<Dynamic>, implements IAsn1Type {
	function new(p0 : UInt, p1 : UInt) : Void;
	function findAttributeValue(p0 : String) : IAsn1Type;
	function getLength() : UInt;
	function getType() : UInt;
	function toString() : String;
	private var len : UInt;
	private var type : UInt;
}
