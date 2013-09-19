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
package xmpp.pubsub;

class Options {
	
	public var jid : String;
	public var node : String;
	public var subid : String;
	public var form : xmpp.DataForm;
	
	public function new( ?jid : String, ?node : String, ?subid : String, ?form : xmpp.DataForm ) {
		this.jid = jid;
		this.node = node;
		this.subid = subid;
		this.form = form;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "options" );
		if( jid != null ) x.set( "jid", jid );
		if( node != null ) x.set( "node", node );
		if( subid != null ) x.set( "subid", subid );
		if( form != null ) x.addChild( form.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : Options {
		var f : xmpp.DataForm = null;
		for( e in x.elementsNamed( "x" ) ) {
			f = xmpp.DataForm.parse( e );
			break;
		}
		return new Options( x.get( "jid" ),  x.get( "node" ),  x.get( "subid" ), f );
	}
	
}
