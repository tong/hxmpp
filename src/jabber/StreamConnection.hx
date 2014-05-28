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
	Abstract base class for stream connections.
*/
class StreamConnection {

	/** Succesfully connected callback */
	@:allow(jabber.Stream)
	var onConnect : Void->Void;
	
	/** Disconnect callback. Parameter is a optional error message  */
	@:allow(jabber.Stream)
	var onDisconnect : String->Void;
	
	/** Bytes recieved callback */
	//@:allow(jabber.Stream)
	//var onData : Bytes->Bool;
	
	/** String recieved callback */
	@:allow(jabber.Stream)
	var onData : String->Bool;

	/** SSL negotiation complete callback, optional argument indicates an ssl error */
	public var onSecured : String->Void;

	/** Hostname or IP address of the XMPP server. */
	public var host(default,set_host) : String;
	
	/** Indicates if connected and ready to read and write. */
	public var connected(default,null) : Bool;
	
	/** Indicates if this is a secure connection (SSL negotiation complete) */
	public var secure(default,null) : Bool;
	
	/** Indicates if SSL is negotiation is complete and data transfered is encrypted */
	public var secured(default,null) : Bool;
	
	/** Indicates if this data connection is a HTTP (BOSH) connection (default is false) */
	public var http(default,null) : Bool;

	function new( host : String, secure : Bool, http : Bool = false ) {
		this.host = host;
		this.secure = secure;
		this.http = http;
		connected = secured = false;
	}
	
	function set_host( s : String ) : String {
		if( connected )
			return throw "cannot change hostname for active connection" ;
		return host = s;
	}
	
	/**
	*/
	public function connect() {
		#if jabber_debug
		trace( 'not implemented' );
		#end
	}
	
	/**
	*/
	public function disconnect() {
		#if jabber_debug
		trace( 'not implemented' );
		#end
	}
	
	/**
		Start ssl negotiation
	*/
	public function setSecure() {
		#if jabber_debug
		trace( 'not implemented' );
		#end
	}
	
	/**
		Start/Stop reading data input
	*/
	public function read( ?yes : Bool = true ) : Bool {
		#if jabber_debug
		trace( 'not implemented' );
		#end
		return false;
	}

	/**
		Send raw bytes
	*/
	/*
	public function writeData( data : Bytes ) : Bool {
		#if jabber_debug
		trace( 'not implemented' );
		#end
		return false;
	}
	*/
	
	/**
		Send string
	*/
	public function write( s : String ) : Bool {
		#if jabber_debug
		trace( 'not implemented' );
		#end
		return false;
	}
	
}
