/*
 * Copyright (c) disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package jabber;

import haxe.io.Bytes;

/**
	Abstract base class for XMPP stream connections.
*/
class StreamConnection {
	
	/** Succesfully connected callback */
	public var __onConnect : Void->Void;
	
	/** Disconnected callback. Parameter is an optional error message  */
	public var __onDisconnect : String->Void;
	
	/** Bytes recieved callback */
	public var __onData : Bytes->Bool;
	
	/** String recieved callback */
	public var __onString : String->Bool;

	/** TLS negotiation complete callback */
	public var __onSecured : String->Void;
	
	/** Hostname or IP address of the XMPP server. */
	public var host(default,set_host) : String;
	
	/** Indicates if connected and ready to read and write. */
	public var connected(default,null) : Bool;
	
	/** Indicates if this is a secure connection (TLS negotiation complete) */
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
	
	function set_host( t : String ) : String {
		if( connected )
			throw "cannot change hostname on active xmpp connection" ;
		return host = t;
	}
	
	/**
	*/
	public function connect() {
		#if jabber_debug trace( 'abstract method', 'error' ); #end
	}
	
	/**
	*/
	public function disconnect() {
		#if jabber_debug trace( 'abstract method', 'error' ); #end
	}
	
	/**
	*/
	public function setSecure() {
		#if jabber_debug trace( 'Connection.setSecure not implemented', 'error' ); #end
	}
	
	/**
		Starts/Stops reading data input, returns true if successfully started
	*/
	public function read( ?yes : Bool = true ) : Bool {
		#if jabber_debug trace( 'abstract method', 'error' ); #end
		return false;
	}
	
	/**
		Send a string, returns true on succeess
	*/
	public function write( t : String ) : Bool {
		#if jabber_debug trace( 'abstract method', 'error' ); #end
		return false;
	}
	
	/**
		Send raw bytes, returns true on succeess
	*/
	public function writeBytes( b : Bytes ) : Bool {
		#if jabber_debug trace( 'abstract method', 'error' ); #end
		return false;
	}
	
}
