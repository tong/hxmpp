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
	Filters XMPP packets where the from attribute contains the given string.
*/
class PacketFromContainsFilter {
	
	public var contains(default,set_contains) : String;
	
	var ereg : EReg;
	
	public function new( contains : String ) {
		set_contains( contains );
	}
	
	function set_contains( t : String ) : String {
		ereg = new EReg( t, "" );
		return this.contains = t;
	}
	
	@:keep public function accept( p : xmpp.Packet ) : Bool {
		if( p.from == null )
			return false;
		try {
			return ereg.match( p.from );
		} catch( e : Dynamic ) {
			return false;
		}
	}
	
}
