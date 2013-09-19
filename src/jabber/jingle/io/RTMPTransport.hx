/*
 * Copyright (c) 2012, disktree.net
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
package jabber.jingle.io;

#if flash

import flash.events.NetStatusEvent;
import flash.net.NetConnection;
import flash.net.NetStream;

@:require(flash) class RTMPTransport extends Transport {
	
	public var name(default,null) : String;
	public var host(default,null) : String;
	public var port(default,null) : Int;
	public var id(default,null) : String;
	public var ns(default,null) : NetStream;
	
	var nc : NetConnection;
	
	function new( name : String, host : String, port : Int = 1935, id : String ) {
		super();
		this.name = name;
		this.host = host;
		this.port = port;
		this.id = id;
	}
	
	public override function connect() {
		nc = new NetConnection();
		nc.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
		try nc.connect( "rtmp://"+host+":"+port ) catch( e : Dynamic ) {
			__onFail( e );
		}
	}
	
	public override function close() {
		if( ns != null ) ns.close();
		if( nc != null && nc.connected ) nc.close();
	}
	
	public override function toXml() : Xml {
		var x = Xml.createElement( "candidate" );
		x.set( "name", name );
		x.set( "host", host );
		x.set( "port", Std.string( port ) );
		x.set( "id", id );
		return x;
	}
	
	function netStatusHandler( e : NetStatusEvent ) {
		if( StringTools.startsWith( e.info.code, "NetStream.Buffer" ) )
			return;
		switch( e.info.code ) {
		case "NetConnection.Connect.Failed" :
			//connected = false;
			__onFail( e.info.code );
		case "NetConnection.Connect.Success" :
			ns = new NetStream( nc );
			ns.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
			//connected = true;
			__onConnect();
		case "NetConnection.Connect.Closed" :
			//connected = false;
			__onDisconnect();
		}
	}
	
}

/* TODO jingle flash bridge
#elseif (js&&JINGLE_BRIDGE)

@:require(JINGLE_BRIDGE) class RTMPTransport extends Transport {
	
	static var transports = new IntHash<RTMPTransport>();
	
	public var name(default,null) : String;
	public var host(default,null) : String;
	public var port(default,null) : Int;
	public var id(default,null) : String;
	
	var bridgeId : Int;
	
	function new( name : String, host : String, port : Int = 1935, id : String ) {
		
		super();
		this.name = name;
		this.host = host;
		this.port = port;
		this.id = id;

		transports.set( bridgeId = Lambda.count(transports), this );
	}
	
	public override function connect() {
		//nc = new NetConnection();
		//nc.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
		//try nc.connect( "rtmp://"+host+":"+port ) catch( e : Dynamic ) {
		//	__onFail( e );
		//}
		swf.connectRTMPTranport( bridgeId, host, port );
	}
	
	public override function close() {
		swf.closeRTMPTransport( bridgeId );
	}
	
	public override function toXml() : Xml {
		var x = Xml.createElement( "candidate" );
		x.set( "name", name );
		x.set( "host", host );
		x.set( "port", Std.string( port ) );
		x.set( "id", id );
		return x;
	}
	
	static function __onConnect( id : Int ) {
		transports.get( id ).__onConnect;
	}
	
	static function __onDisconnect( id : Int ) {
		transports.get( id ).__onDisconnect;
	}
	
	static function __onFail( id : Int, info : String ) {
		transports.get( id ).__onFail( info );
	}
	
}
*/

#end
