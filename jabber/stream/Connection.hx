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
package jabber.stream;

/* TOFO
typedef TDataFilter = {
	function filterData( t : haxe.io.Bytes) : haxe.io.Bytes;
}
*/

typedef DataFilter = {
	/** Filters incoming data before further processing ( fe: uncompression ). */
	function filterData( t : haxe.io.Bytes) : haxe.io.Bytes;
}

typedef DataInterceptor = {
	/** Modifies raw data before sending ( fe: compression ). */
	function interceptData( t : haxe.io.Bytes ) : haxe.io.Bytes;
}

/**
	Abstract base for XMPP stream connections.
*/
class Connection {
	
	///// INTERNAL
	/** Callback for connecting event */
	public var onConnect : Void->Void;
	/** Callback for disconnecting event */
	public var onDisconnect : Void->Void;
	/** Callback data recieved event */
	//public var onData : String->Void;
	public var onData : haxe.io.Bytes->Int->Int->Int;
	/** Callback connection level errors */
	public var onError : String->Void;
	///// INTERNAL
	
	/** Server IP/hostname */
	public var host(default,null) : String;
	/** Server port to connect to */
	//public var port(default,null) : Int;
	/** Indicates whether is currently connected. */
	public var connected(default,null) : Bool;
	/** Raw data filters for outgoing data. */
	//public var interceptors : Array<DataInterceptor>;
	/** Raw data filters for incoming data. */
	//public var filters : Array<DataFilter>;
	
	function new( host : String ) {
		this.host = host;
		//this.port = port;
		connected = false;
		//interceptors = new Array();
		//filters = new Array();
	}
	
	/**
		Try to connect the stream data connection.
	*/
	public function connect() {
		throw "abstract";//new error.AbstractError();
	}
	
	/**
		Disconnects stream connection.
	*/
	public function disconnect() { //: Bool
		throw "abstract"; //new error.AbstractError();
	}
	
	/**
		Starts/Stops reading data input.
	*/
	public function read( ?yes : Bool = true ) : Bool {
		return throw "abstract";//throw new error.AbstractError();
	}
	
	/**
		Send string.
	*/
	public function write( t : String ) : String {
	//public function write( t : haxe.io.Bytes ) : haxe.io.Bytes {
		return throw "abstract";
	}
	
	/*
		Send raw bytes.
		TODO
	*/
	/*
	public function writeBytes( t : haxe.io.Bytes ) : haxe.io.Bytes {
		return throw new error.AbstractError();
	}
	*/
	
	/* 
	//TODO
	function interceptData( t : haxe.io.Bytes ) : haxe.io.Bytes {
	}
	
	TODO
	function handleData( t : haxe.io.Bytes, pos : Int, len : Int ) : Int {
		for( f in filters )
			t = f.filterData( t, pos, len );
		return onData( t, pos, len );
	}
	*/
}
