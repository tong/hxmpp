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

/**
	XEP-0055: Search: http://xmpp.org/extensions/xep-0055.html
*/
class UserSearch {
	
	public dynamic function onFields( jid : String, l : xmpp.UserSearch ) {}
	public dynamic function onResult( jid : String, l : xmpp.UserSearch ) {}
	public dynamic function onError( e : XMPPError ) {}
	
	public var stream(default,null) : Stream;
	
	public function new( stream : Stream ) {
		this.stream = stream;
	}
	
	public function requestFields( jid : String ) {
		var iq = new xmpp.IQ();
		iq.to = jid;
		iq.x = new xmpp.UserSearch();
		sendIQ( iq, onFields );
	}
	
	public function search( jid : String, item : xmpp.UserSearchItem ) {
		var iq = new xmpp.IQ( xmpp.IQType.set );
		iq.to = jid;
		var u = new xmpp.UserSearch();
		for( f in Reflect.fields( item ) )
			Reflect.setField( u, f, Reflect.field( item, f ) );
		iq.x = u;
		sendIQ( iq, onResult );
	}
	
	function sendIQ( iq : xmpp.IQ, h : String->xmpp.UserSearch->Void ) {
		var me = this;
		stream.sendIQ( iq, function(r:xmpp.IQ){
			switch( r.type ) {
			case result : h( r.from, xmpp.UserSearch.parse( r.x.toXml() ) );
			case error : me.onError( new XMPPError( r ) );
			default :
			}
		} );
	}

}
