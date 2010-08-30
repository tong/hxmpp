package tls.utils;

extern class Memory {
	static var used(default,null) : UInt;
	static function gc() : Void;
}
