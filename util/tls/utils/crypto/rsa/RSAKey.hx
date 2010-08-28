package tls.utils.crypto.rsa;

extern class RSAKey {
	var coeff : tls.utils.math.BigInteger;
	var d : tls.utils.math.BigInteger;
	var dmp1 : tls.utils.math.BigInteger;
	var dmq1 : tls.utils.math.BigInteger;
	var e : Int;
	var n : tls.utils.math.BigInteger;
	var p : tls.utils.math.BigInteger;
	var q : tls.utils.math.BigInteger;
	function new(p0 : tls.utils.math.BigInteger, p1 : Int, ?p2 : tls.utils.math.BigInteger, ?p3 : tls.utils.math.BigInteger, ?p4 : tls.utils.math.BigInteger, ?p5 : tls.utils.math.BigInteger, ?p6 : tls.utils.math.BigInteger, ?p7 : tls.utils.math.BigInteger) : Void;
	function decrypt(p0 : flash.utils.ByteArray, p1 : flash.utils.ByteArray, p2 : UInt, ?p3 : Dynamic) : Void;
	function dispose() : Void;
	function dump() : String;
	function encrypt(p0 : flash.utils.ByteArray, p1 : flash.utils.ByteArray, p2 : UInt, ?p3 : Dynamic) : Void;
	function getBlockSize() : UInt;
	function toString() : String;
	private var canDecrypt : Bool;
	private var canEncrypt : Bool;
	private function doPrivate(p0 : tls.utils.math.BigInteger) : tls.utils.math.BigInteger;
	private function doPrivate2(p0 : tls.utils.math.BigInteger) : tls.utils.math.BigInteger;
	private function doPublic(p0 : tls.utils.math.BigInteger) : tls.utils.math.BigInteger;
	static function generate(p0 : UInt, p1 : String) : RSAKey;
	static function parsePrivateKey(p0 : String, p1 : String, p2 : String, ?p3 : String, ?p4 : String, ?p5 : String, ?p6 : String, ?p7 : String) : RSAKey;
	static function parsePublicKey(p0 : String, p1 : String) : RSAKey;
}
