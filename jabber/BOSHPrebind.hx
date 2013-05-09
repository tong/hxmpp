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
package jabber;

import jabber.util.Base64;
import xmpp.IQ;
import xmpp.IQType;

/**
	Base for BOSH/HTTP clients doing account pre-binding.
	Prebinds a anonymous session for default.
	Use jabber.BOSHPrebindAccount to use a 'real' account.
*/
class BOSHPrebind {

	public dynamic function onComplete( info : BOSHPrebindInfo ) {}
	public dynamic function onError( info : String ) {}

	public var serviceUrl(default,null) : String;
	public var sid(default,null) : String;
	//public var authid(default,null) : String;
	public var rid(default,null) : Int;
	public var wait(default,null) : Int;
	public var hold(default,null) : Int;

	public function new( serviceUrl : String,
						 wait : Int = 30, hold : Int = 1,
						 ?rid : Null<Int> ) {
		this.serviceUrl = serviceUrl;
		this.wait = wait;
		this.hold = hold;
		this.rid = ( rid == null ) ? Std.int( Math.random()*10000000 ) : rid;
	}
	
	/**
		Init account pre-binding.
	*/
	public function init( ?cb : BOSHPrebindInfo->Void  ) {
		if( cb != null )
			this.onComplete = cb;
		var x = buildInitialBody();
		sendRequest( x.toString(), function(r){
			//trace(x);
			var x = Xml.parse(r).firstChild();
			sid = x.get( "sid" );
			if( sid == null ) {
				cb( null );
				return;
			}
			wait = Std.parseInt( x.get( "wait" ) );
			hold = Std.parseInt( x.get( "hold" ) );
			onStreamOpen();
		});
	}

	function onStreamOpen() {
		sendRequest( buildBody( createAuthText() ).toString(), function(r) {
			var x = Xml.parse(r).firstChild();
			for( e in x.elements() ) {
				switch( e.nodeName ) {
				case 'failure' : onError( e.nodeName );
				case 'success' :
					restartStream( function(r) {
						//TODO parse/check response
						/*
						if( !isIQResult(r) ) {
							onError( '' );
							return;
						}
						*/
						bindResource( 'web', function(r) {
							if( !isIQResult(r) ) {
								onError( 'failed to bind resource' );
								return;
							}
							createSession( function(r) {
								if( !isIQResult(r) ) {
									onError( 'failed to create stream session' );
									return;
								}
								onComplete( cast this );
							});
						} );
						
					});
				}
			}
		});
	}
	
	function buildInitialBody() : Xml {
		var x = Xml.createElement( "body" );
		x.set( 'xmlns', 'http://jabber.org/protocol/httpbind' );
		x.set( 'xml:lang', 'en' );
		x.set( 'xmlns:xmpp', 'urn:xmpp:xbosh' );
		x.set( 'xmpp:version', '1.0' );
		x.set( 'ver', '1.6' );
		x.set( 'hold', Std.string( hold ) );
		x.set( 'rid', Std.string( rid ) );
		x.set( 'wait', Std.string( wait ) );
		//x.set( 'to', 'disktree' ); //TODO
		x.set( 'secure', "false" );
		return x;
	}
	
	function createAuthText() : Xml {
		// anonymous SASL authentication
		var x = Xml.createElement( 'auth' );
		x.set( 'xmlns', 'urn:ietf:params:xml:ns:xmpp-sasl' );
		x.set( 'mechanism', 'ANONYMOUS' );
		return x;
	}
	
	function restartStream( cb : String->Void ) {
		var x = buildBody();
		x.set( 'xmpp:restart', 'true' );
		x.set( 'xmlns:xmpp', 'urn:xmpp:xbosh' );
		//x.set( 'to', 'disktree' );
		sendRequest( x.toString(), cb );
	}
	
	function bindResource( resource : String, cb : String->Void ) {
		var iq = new IQ( set, Base64.random( 8 ) );
		iq.properties.push( Xml.parse( '<bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"><resource>'+resource+'</resource></bind>' ) );
		sendRequest( buildBody( iq.toXml() ).toString(), cb );
	}
	
	function createSession( cb : String->Void ) {
		var iq = new IQ( set, Base64.random( 8 ) );
		iq.properties.push( Xml.parse( '<session xmlns="urn:ietf:params:xml:ns:xmpp-session"/>' ) );
		sendRequest( buildBody( iq.toXml() ).toString(), cb );
	}
		
	function buildBody( ?e : Xml ) : Xml {
		rid++;
		var x = Xml.createElement( "body" );
		x.set( 'xmlns', 'http://jabber.org/protocol/httpbind' );
		x.set( 'xml:lang', 'en' );
		x.set( 'rid', Std.string( rid ) );
		x.set( 'sid', sid );
		//x.set( 'to', 'disktree' );
		if( e != null ) x.addChild( e );
		return x;
	}

	function sendRequest( t : String, cb : String->Void ) {
		var r = new haxe.Http( serviceUrl );
		r.noShutdown = true;
		r.setHeader( 'Content-type', 'text/xml' );
		r.setHeader( 'Accept', 'text/xml' );
		r.setHeader( 'Content-Length', Std.string( t.length ) );
		r.onData = function(d) {
			cb(d);
		};
		r.onError = function(e){
			onError(e);
		};
		r.setPostData( t );
		r.request( true );
	}

	function isIQResult( body : String ) : Bool {
		return IQ.parse( Xml.parse( body ).firstElement().firstElement() ).type == result;
	}

}
