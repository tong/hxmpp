package tls.utils.der;

extern class UTCTime implements IAsn1Type {
	function new(p0 : UInt, p1 : UInt) : Void;
	function getLength() : UInt;
	function getType() : UInt;
	function setUTCTime(p0 : String) : Void;
	function toString() : String;
	private var date : Date;
	private var len : UInt;
	private var type : UInt;
}
