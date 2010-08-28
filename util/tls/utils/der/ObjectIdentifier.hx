package tls.utils.der;

extern class ObjectIdentifier implements IAsn1Type {
	function new(p0 : UInt, p1 : UInt, p2 : flash.utils.ByteArray) : Void;
	function dump() : String;
	function getLength() : UInt;
	function getType() : UInt;
	function toString() : String;
}
