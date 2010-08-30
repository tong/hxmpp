package tls.utils.der;

extern class Integer extends tls.utils.math.BigInteger, implements IAsn1Type {
	function new(p0 : UInt, p1 : UInt, p2 : flash.utils.ByteArray) : Void;
	function getLength() : UInt;
	function getType() : UInt;
}
