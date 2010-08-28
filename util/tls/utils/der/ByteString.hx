package tls.utils.der;

extern class ByteString extends flash.utils.ByteArray, implements IAsn1Type {
	function new(p0 : UInt, p1 : UInt) : Void;
	function getLength() : UInt;
	function getType() : UInt;
}
