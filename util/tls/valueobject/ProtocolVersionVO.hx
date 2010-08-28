package tls.valueobject;

extern class ProtocolVersionVO {
	var major : UInt;
	var minor : UInt;
	function new(p0 : UInt, p1 : UInt) : Void;
	function getVersionInt() : Int;
	function toString() : String;
}
