package tls.utils.crypto.prng;

extern class TLSPRF implements IPRF {
	function new(p0 : flash.utils.ByteArray, p1 : String, p2 : flash.utils.ByteArray) : Void;
	function dispose() : Void;
	function nextByte() : Int;
	function nextBytes(p0 : flash.utils.ByteArray, p1 : Int) : Void;
	function toString() : String;
}
