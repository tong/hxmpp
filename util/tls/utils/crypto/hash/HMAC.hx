package tls.utils.crypto.hash;

extern class HMAC implements IMAC {
	function new(p0 : IHash, ?p1 : UInt, ?p2 : flash.utils.ByteArray) : Void;
	function compute(p0 : flash.utils.ByteArray, ?p1 : flash.utils.ByteArray, ?p2 : IHash) : flash.utils.ByteArray;
	function dispose() : Void;
	function toString() : String;
}
