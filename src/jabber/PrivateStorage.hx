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
package jabber;

/**
	Extension to store any arbitrary XML on the server side.
	XEP-0049: Private XML Storage: http://xmpp.org/extensions/xep-0049.html
*/
class PrivateStorage {
	
	public dynamic function onLoad( s : xmpp.PrivateStorage ) {}
	public dynamic function onStored( s : xmpp.PrivateStorage ) {}
	public dynamic function onError( e : jabber.XMPPError ) {}
	
	public var stream(default,null) : jabber.Stream;

	public function new( stream : jabber.Stream ) {
		this.stream = stream;
	}
	
	/**
		Load private data.
	*/
	public function load( name : String, namespace : String ) {
		var iq = new xmpp.IQ( xmpp.IQType.get );
		iq.x = new xmpp.PrivateStorage( name, namespace );
		var me = this;
		stream.sendIQ( iq, function(r:xmpp.IQ) {
			switch( r.type ) {
			case result : me.onLoad( xmpp.PrivateStorage.parse( r.x.toXml() ) );
			case error : me.onError( new jabber.XMPPError( iq ) );
			default://#
			}
		} );
	}
	
	/**
		Store private data.
	*/
	public function store( name : String, namespace : String, data : Xml ) {
		var iq = new xmpp.IQ( xmpp.IQType.set );
		var xt = new xmpp.PrivateStorage( name, namespace, data );
		iq.x = xt;
		var me = this;
		stream.sendIQ( iq, function(r:xmpp.IQ) {
			switch( r.type ) {
			case result : me.onStored( xt );
			case error : me.onError( new jabber.XMPPError( iq ) );
			default://#
			}
		} );
	}
	
}
