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

//import haxe.EnumTools;

/** 
	Filters message packets, optional including xmpp.MessageType.
*/
class MessageFilter {
		
	public var type : xmpp.MessageType;
	
	public function new( ?type : xmpp.MessageType ) {
		this.type = type;
	}
	
	@:keep
	public function accept( p : xmpp.Packet ) : Bool {
		if( p._type != xmpp.PacketType.message )
			return false;
		//if( type != null )
		//	return EnumValueTools.equals( type, untyped p.type );
		/*
		if( p._type != xmpp.PacketType.message )
			return false;
		*/
		return ( type == null ) ? true : ( type == untyped p.type );
	}
	
}
