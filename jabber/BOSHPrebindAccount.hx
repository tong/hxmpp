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

import jabber.JID;
import jabber.util.Base64;
import xmpp.XMLUtil;

/**
	Prebinds an XMPP client account to a BOSH connection.
	Warning! Uses plain text SASL login!
*/
class BOSHPrebindAccount extends BOSHPrebind {
	
	/** The JID of the client account */
	public var jid(default,null) : String;
	
	/** The password of the client account */
	public var password(default,null) : String;

	public function new( serviceUrl : String,
						 jid : String, password : String,
						 wait : Int = 30, hold : Int = 1,
						 ?rid : Int ) {
		super( serviceUrl, wait, hold, rid );
		this.jid = jid;
		this.password = password;
	}
	
	override function createAuthText() : Xml {
		var j = new JID( jid );
		var sasl = new jabber.sasl.PlainMechanism();
		var t = sasl.createAuthenticationText( j.node, j.domain, password, j.resource );
		var x = XMLUtil.createElement( 'auth', Base64.encode( t ) );
		x.set( 'xmlns', 'urn:ietf:params:xml:ns:xmpp-sasl' );
		x.set( 'mechanism', 'PLAIN' );
		return x;
	}

}
