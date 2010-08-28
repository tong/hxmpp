package tls.utils.crypto.symmetric;

extern class IVMode {
	var IV : flash.utils.ByteArray;
	function new(p0 : ISymmetricKey, ?p1 : IPad) : Void;
	function dispose() : Void;
	function getBlockSize() : UInt;
	private var blockSize : UInt;
	private var iv : flash.utils.ByteArray;
	private var key : ISymmetricKey;
	private var lastIV : flash.utils.ByteArray;
	private var padding : IPad;
	private var prng : tls.utils.crypto.prng.Random;
	private function getIV4d() : flash.utils.ByteArray;
	private function getIV4e() : flash.utils.ByteArray;
}
