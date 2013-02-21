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
	XEP-0012: Last Activity: http://xmpp.org/extensions/xep-0012.html
*/
class LastActivity {
	
	public dynamic function onLoad( entity : String, secs : Int ) {}
	public dynamic function onError( e : XMPPError ) {}
	
	public var stream(default,null) : Stream;
	
	public function new( stream : Stream ) {
		this.stream = stream;
	}
	
	/**
		Requests the given entity for their last activity.<br/>
		Given a bare jid will be handled by the server on roster subscription basis.<br/>
		Otherwise the request will be fowarded to the resource of the client entity.<br/>
	*/
	public function request( jid : String ) {
		var iq = new xmpp.IQ( null, null, jid );
		iq.x = new xmpp.LastActivity();
		stream.sendIQ( iq, handleLoad );
	}
	
	function handleLoad( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			onLoad( iq.from, xmpp.LastActivity.parseSeconds( iq.x.toXml() ) );
		case error :
			onError( new XMPPError( iq ) );
		default : ///
		}
	}
	
}
