package jabber.file.io;

#if neko
import neko.Lib;
import neko.net.Host;
import neko.net.Socket;
import neko.vm.Thread;
#elseif cpp
import cpp.Lib;
import cpp.net.Host;
import cpp.net.Socket;
import cpp.vm.Thread;
#elseif php
import php.Lib;
import php.net.Host;
import php.net.Socket;
#elseif flash
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;
import flash.net.Socket;
#end

/* TODO
typedef Buffer = {
	//var bufSize : Int;
	var maxSize : Int;
	var input : haxe.io.Input;
	var data : haxe.io.Bytes;
	var length : Int;
}
*/

/**
	flash9,neko,cpp,php.
	Socket bytestream input.
	! PHP does not support threads, means, this class blocks until transfer has ended.
*/
class ByteStreamInput {
	
	public var __onFail : Void->Void;
	public var __onConnect : Void->Void;
	public var __onComplete : Void->Void;
	
	public var data(getData,null) : haxe.io.Bytes;
	
	var socket : Socket;
	var host : String;
	var port : Int;
	
	public function new( host : String, port : Int ) {
		this.host = host;
		this.port = port;
	}
	
	function getData() : haxe.io.Bytes {
		#if (cpp||neko||php)
		return data;
		#elseif flash
		return haxe.io.Bytes.ofData( _data );
		#end
	}
	
	public function connect() {
		socket = new Socket();
		#if flash
		socket.addEventListener( Event.CONNECT, handleSocketConnect  );
		socket.addEventListener( Event.CLOSE, handleSocketDisconnect );
		socket.addEventListener( IOErrorEvent.IO_ERROR, handleSocketError );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, handleSocketError );
		socket.connect( host, port );
		#else
		try {
			socket.connect( new Host( host ), port );
		} catch( e : Dynamic ) {
			__onFail();
		}
		__onConnect();
		#end
		#if (cpp||neko)
		var t = Thread.create( tread );
		t.sendMessage( Thread.current() );
		t.sendMessage( socket.input );
		t.sendMessage( handleInputComplete );
		#elseif php
		input = socket.input;
		buffer = haxe.io.Bytes.alloc( 1024 );
		bytes = 0;
		while( readData() ) {}
		handleInputComplete( buffer );
		#end
	}
	
	#if flash
	
	var _data : flash.utils.ByteArray;
	
	function handleSocketConnect( e : Event ) {
		_data = new flash.utils.ByteArray();
		socket.addEventListener( ProgressEvent.SOCKET_DATA, handleSocketData );
		__onConnect();
	}
	
	function handleSocketDisconnect( e : Event ) {
		socket.close();
		__onComplete();
	}
	
	function handleSocketError( e : Event ) {
		__onFail();
	}
	
	function handleSocketData( e : ProgressEvent ) {
		socket.readBytes( _data, _data.length, e.bytesLoaded );
	}
	
	#elseif (cpp||neko||php)
	
	function handleInputComplete( t : haxe.io.Bytes ) {
		this.data = t;
		__onComplete();
	}
	
	//var bufSize : Int;
	var maxBufSize : Int;
	var input : haxe.io.Input;
	var buffer : haxe.io.Bytes;
	var bytes : Int;
	
	function readData() : Bool {
		var available = buffer.length-bytes;
		if( available == 0 ) {
			//TODO
			//trace("DOUBLE SIZE");
			var nsize = buffer.length*2;
			//TODO
			//if( newsize > config.maxReadBufferSize ) {
			//}
			var nbuf = haxe.io.Bytes.alloc( nsize );
			nbuf.blit( 0, buffer, 0, bytes );
			buffer = nbuf;
			available = nsize-bytes;
		}
		try {
			bytes += input.readBytes( buffer, bytes, available );
		} catch( e : Dynamic ) {
			if( !Std.is( e, haxe.io.Eof ) && !Std.is( e, haxe.io.Error ) )
				Lib.rethrow( e );
			return false;
		}
		return true;
	}

	#end // cpp||neko||php
	
	#if (cpp||neko)
	
	function tread() {
		var main : Thread = Thread.readMessage( true );
		input = Thread.readMessage( true );
		//buffer = Thread.readMessage( true );
		var cb : haxe.io.Bytes->Void = Thread.readMessage( true );
		buffer = haxe.io.Bytes.alloc( 1024 );
		bytes = 0;
		while( readData() ) {};
		cb( buffer );
	}
	
	#end // cpp||neko
	
}
