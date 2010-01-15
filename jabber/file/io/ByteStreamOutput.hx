/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package jabber.file.io;

#if neko
import neko.net.Socket;
import neko.vm.Thread;
#elseif cpp
import cpp.net.Socket;
import cpp.vm.Thread;
#end


enum SOCKS5State {
	waitInit;
	waitResponse;
	complete;
}


	//TODO SOCKS5 server
/**
	
	neko,cpp.
*/
class ByteStreamOutput {
	
	public var udp(default,null) : Bool;
	
	var socket : Socket;
	var client : Socket;
	var host : String;
	var port : Int;
	
	public function new( host : String, port : Int, ?udp = false ) {
		this.host = host;
		this.port = port;
		this.udp = udp;
	}
	
	public function connect() {
		socket = (udp) ? Socket.newUdpSocket() : new Socket();
		socket.bind( new neko.net.Host( host ), port );
        socket.listen( 1 );
	}
	
	public function write( input : haxe.io.Input ) {
		client = Thread.readMessage( false );
		var ok = Thread.readMessage( false );
		trace(ok);
		if( client == null )
			throw "Client not connected";
		client.output.write( input.readAll() );
	}
	
	public function close() {
		if( client != null ) client.close();
		socket.close();
	}
	
	public function wait() {
		var t = Thread.create( t_wait );
		t.sendMessage( Thread.current() );
		t.sendMessage( socket );
	}
	
	function t_wait() {
		var main : Thread = Thread.readMessage ( true );
		var socket : Socket = Thread.readMessage ( true );
		while( true ) {
			var c = socket.accept();
			trace("CLIENT CONNECTED");
			i = c.input;
			o = c.output;
			main.sendMessage( c );
			break;
		}
		maxBufSize = (1<<18);
		buffer = haxe.io.Bytes.alloc( 1024 );
		bytes = 0;
		state = waitInit;
		trace("READIND SOCKS5 input ");
		while( read() ) {
			//processData();
		}
		trace("FINISHEd SOCKS 5");
		main.sendMessage( true );
	}
	
	var state : SOCKS5State;
	var maxBufSize : Int;
	var i : haxe.io.Input;
	var o : haxe.io.Output;
	var buffer : haxe.io.Bytes;
	var bytes : Int;
	
	function read() {
		switch( state ) {
		case waitInit :
			//? i.bigEndian = true;
			if( i.readByte() != 5 )
				throw "Invalid socks5 protocol";
			trace( i.readByte() );
			trace( i.readByte() );
			//o.writeByte( 0x05 );
			//o.writeByte( 0x00 );
			var b = haxe.io.Bytes.alloc(2);
			b.set(0,5);
			b.set(1,0);
			o.write(b);
			//? o.bigEndian = true;
			trace("kk");
			state = complete;
			return true;
			
		case waitResponse :	
			trace("##############");
			//trace( i.readByte() );
			//trace( i.readByte() );
			return true;
			
		case complete :
			trace("complete");
			return false;
		}
		return false;
	}
	
	
	
}
