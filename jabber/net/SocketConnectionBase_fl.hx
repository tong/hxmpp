package jabber.net;

import flash.net.Socket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;
import flash.utils.ByteArray;
import haxe.io.Bytes;

class SocketConnectionBase_fl extends jabber.StreamConnection {

	public static var defaultBufSize = #if php 65536 #else 256 #end; //TODO php buf
	public static var defaultMaxBufSize = 1<<22; // 4MB
	public static var defaultTimeout = 10;

	public var port(default,null) : Int;
	public var maxbufsize(default,null) : Int;
	public var timeout(default,null) : Int;
	public var socket(default,null) : Socket;

	var buf : Bytes;
	var bufpos : Int;
	var bufsize : Int;

	function new( host : String, port : Int, secure : Bool,
				  bufsize : Int = -1, maxbufsize : Int = -1,
				  timeout : Int = -1 ) {

		super( host, secure, false );
		this.port = port;
		this.bufsize = ( bufsize == -1 ) ? defaultBufSize : bufsize;
		this.maxbufsize = ( maxbufsize == -1 ) ? defaultMaxBufSize : maxbufsize;
		this.timeout = ( timeout == -1 ) ? defaultTimeout : timeout;
	}

}
