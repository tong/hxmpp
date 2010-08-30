package tls.utils;

extern class ByteConverterUtils {
	static function convertByteArrayToInt(p0 : flash.utils.ByteArray, ?p1 : Int) : Int;
	static function convertByteArrayToShort(p0 : flash.utils.ByteArray, ?p1 : Int) : Int;
	static function convertByteArrayToUInt24(p0 : flash.utils.ByteArray, ?p1 : Int) : UInt;
	static function convertIntToByteArray(p0 : Int, ?p1 : flash.utils.ByteArray, ?p2 : Int) : flash.utils.ByteArray;
	static function convertShortToByteArray(p0 : UInt, ?p1 : flash.utils.ByteArray, ?p2 : Int) : flash.utils.ByteArray;
	static function convertUInt24ToByteArray(p0 : UInt, ?p1 : flash.utils.ByteArray, ?p2 : Int) : flash.utils.ByteArray;
	static function convertULongToByteArray(p0 : Int, ?p1 : flash.utils.ByteArray, ?p2 : Int) : flash.utils.ByteArray;
}
