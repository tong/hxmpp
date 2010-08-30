package tls.valueobject.cert;

extern class CertificateVO {
	var rsaPublicKey : tls.utils.crypto.rsa.RSAKey;
	function new() : Void;
	static function createFromBytes(p0 : flash.utils.ByteArray, ?p1 : UInt, ?p2 : Int) : CertificateVO;
}
