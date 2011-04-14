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

import haxe.io.Bytes;

/**
	Abstract base class for stream connections.
*/
class Connection {
	
	/** Succesfully connected callback */
	public var __onConnect : Void->Void;
	/** Disconnected callback */
	public var __onDisconnect : String->Void;
	/** Data recieved callback */
	public var __onData : Bytes->Int->Int->Int;
	/** String recieved callback */
	public var __onString : String->Int;
	/** TLS negotiation complete callback */
	@:keep public var __onSecured : String->Void;
	
	/** Hostname or IP address of the XMPP server. */
	public var host(default,setHost) : String;
	/** Indicates if connected and ready to read and write. */
	public var connected(default,null) : Bool;
	/** Indicates if this is a secure connection */
	public var secure(default,null) : Bool;
	/** Indicates if TLS is negotiation is complete and data transfered is encrypted */
	public var secured(default,null) : Bool;
	/** Indicates if this data connection is a HTTP (BOSH) connection (default is false) */
	public var http(default,null) : Bool;
	
	function new( host : String, secure : Bool, http : Bool = false ) {
		this.host = host;
		this.secure = secure;
		this.http = http;
		connected = secured = false;
	}
	
	function setHost( t : String ) : String {
		if( connected )
			throw "cannot change hostname on active connection" ;
		return host = t;
	}
	
	/** */
	public function connect() {
		#if JABBER_DEBUG trace( 'abstract method', 'warn' ); #end
	}
	
	/** */
	public function disconnect() {
		#if JABBER_DEBUG trace( 'abstract method', 'warn' ); #end
	}
	
	/** */
	@:keep public function setSecure() {
		#if JABBER_DEBUG
		trace( "Connection.setSecure not implemented", "warn" );
		#end
	}
	
	/** Starts/Stops reading data input, returns true if successfully started */
	public function read( ?yes : Bool = true ) : Bool {
		#if JABBER_DEBUG trace( 'abstract method', 'warn' ); #end
		return false;
	}
	
	/** Sends a string, returns true on succeess */
	public function write( t : String ) : Bool {
		#if JABBER_DEBUG trace( 'abstract method', 'warn' ); #end
		return false;
	}
	
	/** Send raw bytes */
	public function writeBytes( t : Bytes ) : Bool {
		#if JABBER_DEBUG trace( 'abstract method', 'warn' ); #end
		return false;
	}
	
	/***/
	@:keep public function reset() {
	}
	
}
