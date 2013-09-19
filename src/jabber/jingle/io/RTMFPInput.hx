/*
 * Copyright (c), disktree.net
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

import flash.events.NetStatusEvent;
import flash.net.NetStream;

@:require(flash10)
class RTMFPInput extends RTMFPTransport {
	
	public var pubid(default,null) : String;
	
	public function new( url : String, id : String, pubid : String ) {
		super( url );
		this.id = id;
		this.pubid = pubid;
	}
	
	public override function toXml() : Xml {
		//TODO out of any (non-existing) spec
		var x = Xml.createElement( "candidate" );
		x.set( "id", id );
		return x;
	}
	
	override function netConnectionHandler( e : NetStatusEvent ) {
		#if jabber_debug trace( e.info.code ); #end
		switch( e.info.code ) {
		case "NetConnection.Connect.Failed" :
			if( __onFail != null ) __onFail( e.info.code );
		case "NetConnection.Connect.Success" :
			if( __onConnect != null ) __onConnect();
		case "NetConnection.Connect.Closed" :
			if( __onDisconnect != null ) __onDisconnect();
		}
	}

	public static function ofCandidate( x : Xml ) : RTMFPInput {
		//TODO maybe url splitting here
		return new RTMFPInput( x.get( "url" ), x.get( "id" ), x.get( "pubid" ) );
	}
	
}
