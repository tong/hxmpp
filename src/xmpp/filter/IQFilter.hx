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
	Filters IQ packets: namespace/nodename/iqtype
*/
class IQFilter {
	
	public var xmlns : String;
	public var node : String;
	public var type : xmpp.IQType;
	
	public function new( ?xmlns : String, ?type : xmpp.IQType, ?node : String ) {
		this.xmlns = xmlns;
		this.node = node;
		this.type = type;
	}
	
	@:keep public function accept( p : xmpp.Packet ) : Bool {
		if( !Type.enumEq( p._type, xmpp.PacketType.iq ) )
			return false;
		#if as3
		var iq : Dynamic = p;
		#else
		var iq : xmpp.IQ = cast p;
		#end
		if( type != null ) {
			if( !Type.enumEq( type, iq.type ) )
				return false;
		}
		var x : Xml = null;
		if( xmlns != null ) {
			if( iq.x == null )
				return false;
			x = iq.x.toXml();
			if( x.get( "xmlns" ) != xmlns )
				return false;
		}
		if( node != null ) {
			if( iq.x == null )
				return false;
			if( x == null ) x = iq.x.toXml();
			if( node != x.nodeName )
				return false;
		}
		return true;
	}
	
}
