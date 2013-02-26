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

@:require(flash10) class RTMFPTransport extends Transport {

	public static var EREG_URL = ~/(rtmfp:\/\/)([A-Z0-9.-]+?)(\/([A-Z0-9\-]+))?/i;
	
	public var url(default,null) : String;
	public var id(default,null) : String;
	public var nc : NetConnection; // set with care !
	
	function new( url : String ) {
		if( !EREG_URL.match( url ) )
			throw "invalid rtmfp url";
		super();
		this.url = url;
	}
	
	public override function connect() {
		/*
		if( nc == null ) {
			nc = new NetConnection();
			nc.addEventListener( NetStatusEvent.NET_STATUS, netConnectionHandler, false, 0, true );
			try nc.connect( url ) catch( e : Dynamic ) {
				__onFail( "failed to connect to rtmfp service ["+url+"]" );
			}
		} else {
			if( nc.connected ) {
				id = nc.nearID;
				__onConnect();
			} else {
				try nc.connect( url ) catch( e : Dynamic ) {
					__onFail( "failed to connect to rtmfp service ["+url+"]" );
				}
			}
		}
		*/
		
		if( nc == null ) nc = new NetConnection();
		nc.addEventListener( NetStatusEvent.NET_STATUS, netConnectionHandler, false, 0, true );
		if( nc.connected ) {
			id = nc.nearID;
			__onConnect();
		} else {
			try nc.connect( url ) catch( e : Dynamic ) {
				__onFail( "failed to connect to rtmfp service ["+url+"]" );
			}
		}
	}
	
	public override function close() {
		if( nc != null && nc.connected ) try nc.close() catch(e:Dynamic){
			trace(e,"warn");
		}
	}
	
	function netConnectionHandler( e : NetStatusEvent ) {
		//#if jabber_debug trace( e.info.code ); #end
		switch( e.info.code ) {
		case 'NetConnection.Connect.Failed' :
			if( __onFail != null ) __onFail( e.info.code );
		}
	}
	
}

#end // flash
