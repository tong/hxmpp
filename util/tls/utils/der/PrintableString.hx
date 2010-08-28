package tls.utils.der;

extern class PrintableString implements IAsn1Type {
	function new(p0 : UInt, p1 : UInt) : Void;
	function getLength() : UInt;
	function getString() : String;
	function getType() : UInt;
	function setString(p0 : String) : Void;
	function toString() : String;
	private var len : UInt;
	private var str : String;
	private var type : UInt;
}
