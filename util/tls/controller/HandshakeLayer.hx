package tls.controller;

extern class HandshakeLayer {
	var clientRandom : flash.utils.ByteArray;
	var clientTime : flash.utils.ByteArray;
	var masterSecret : flash.utils.ByteArray;
	var serverRandom : flash.utils.ByteArray;
	var serverTime : flash.utils.ByteArray;
	function new(p0 : RecordLayer) : Void;
	function processHandshakeRecord(p0 : tls.valueobject.RecordMessageVO) : Void;
	function startHandshake() : Void;
}
