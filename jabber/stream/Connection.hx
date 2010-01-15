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

/**
	Abstract base for XMPP stream connections.
*/
class Connection {
	
	/** Callback for connecting event */
	public var __onConnect : Void->Void;
	
	/** Callback for disconnecting event */
	public var __onDisconnect : Void->Void;
	
	/** Callback data recieved event */
	//public var onData : String->Void;
	public var __onData : haxe.io.Bytes->Int->Int->Int;
	
	/** Callback connection level errors */
	public var __onError : String->Void; //TODO remove, use: __onDisconnect(?e)
	
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
	}
	
	/**
		Try to connect the stream data connection.
	*/
	public function connect() {
		#if JABBER_DEBUG
		throw "Abstract method";
		#end
	}
	
	/**
		Disconnects stream connection.
	*/
	public function disconnect() { //: Bool
		#if JABBER_DEBUG
		throw "Abstract method";
		#end
	}
	
	/**
		Starts/Stops reading data input.
	*/
	public function read( ?yes : Bool = true ) : Bool {
		return false;
	}
	
	/**
		Send string.
	*/
	public function write( t : String ) : Bool {
		#if JABBER_DEBUG
		return throw "Abstract method";
		#end
		return false;
	}
	
	//TODO
	/**
		Send raw bytes.
	*/
	/*
	public function writeBytes( t : haxe.io.Bytes ) : haxe.io.Bytes {
		return throw new error.AbstractError();
	}
	*/
	
}
