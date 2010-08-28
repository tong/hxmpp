package tls.utils.crypto.hash;

extern interface IMAC {
	function compute(p0 : flash.utils.ByteArray, ?p1 : flash.utils.ByteArray, ?p2 : IHash) : flash.utils.ByteArray;
	function dispose() : Void;
	function toString() : String;
}
