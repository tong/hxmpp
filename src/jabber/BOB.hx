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
	Request entity for 'Bits Of Binary'.
	XEP-0231: Bits Of Binary: http://xmpp.org/extensions/xep-0231.html
*/
class BOB {
	
	public dynamic function onLoad( from : String, bob : xmpp.BOB ) {}
	public dynamic function onError( e : jabber.XMPPError ) {}
	
	public var stream(default,null) : jabber.Stream;
	
	public function new( stream : jabber.Stream ) {
		this.stream = stream;
	}
	
	/**
		Load BOB from entity.
	*/
	public function load( jid : String, cid : String ) {
		var iq = new xmpp.IQ( null, null, jid );
		iq.x = new xmpp.BOB( cid );
		stream.sendIQ( iq, handleResponse );
	}
	
	function handleResponse( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result : onLoad( iq.from, xmpp.BOB.parse( iq.x.toXml() ));
		case error : onError( new jabber.XMPPError( iq ) );
		default : //#
		}
	}
	
}
