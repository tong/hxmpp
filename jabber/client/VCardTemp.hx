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
package jabber.client;

/**
	XEP-0054: vcard-temp: http://www.xmpp.org/extensions/xep-0054.html

	Depricated but still widely implementd by servers (use jabber.client.VCard)
*/
class VCardTemp extends VCardBase<xmpp.VCardTemp> {
	
	public function new( stream : Stream ) {
		super( stream );
	}
	
	/**
		Requests to load the vcard from the given entity or from its own if jid is null.
	*/
	public override function load( ?jid : String  ) {
		super._load( xmpp.VCardTemp.emptyXml(), jid );
	}
	
	override function _handleLoad( iq : xmpp.IQ ) {
		onLoad( iq.from, ( iq.x != null ) ? xmpp.VCardTemp.parse( iq.x.toXml() ) : null );
	}
	
}
	 