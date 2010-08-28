package tls.utils.der;

extern interface IAsn1Type {
	function getLength() : UInt;
	function getType() : UInt;
}
