package tls.utils.crypto.prng;

extern interface IPRNG {
	function dispose() : Void;
	function getPoolSize() : UInt;
	function init(p0 : flash.utils.ByteArray) : Void;
	function next() : UInt;
	function toString() : String;
}
