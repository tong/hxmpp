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
 
package xmpp.filter;

/**
	Filters jingle IQs.
*/
class JingleFilter extends IQFilter {
	
	/**  Jingle session-id */
	public var sid : String;
	/** Jingle transport namespace */
	public var transport : String;
	
	public function new( ?transport : String, ?sid : String, ?iqType : xmpp.IQType ) {
		super( xmpp.Jingle.XMLNS, iqType, "jingle" );
		this.transport = transport;
		this.sid = sid;
	}
	
	@:keep public override function accept( p : xmpp.Packet ) {
		if( !super.accept( p ) )
			return false;
		var iq : xmpp.IQ = untyped p;
		if( iq.x == null )
			return false;
		var x = iq.x.toXml();
		if( sid != null && x.get( "sid" ) != sid )
			return false;
		if( transport != null ) {
			for( e in x.elementsNamed( "content" ) ) {
				for( e in e.elementsNamed( "transport" ) ) {
					if( e.get( "xmlns" ) != transport )
						return false;
				}
			}
		}
		return true;
	}
	
}
