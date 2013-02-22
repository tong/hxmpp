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

import jabber.util.SystemUtil;

/**
	Extension for retrieving information about the software application associated with an XMPP entity
	XEP 0092 - Software Version: http://www.xmpp.org/extensions/xep-0092.html
*/
class SoftwareVersionListener {
	
	public var stream(default,null) : Stream;
	
	/** The natural-language name of the software */
	public var name : String;
	
	/** The specific version of the software*/
	public var version : String;
	
	/** The operating system of the queried entity (optional) */
	public var os : String;
	
	var c : PacketCollector;
	
	public function new( stream : Stream, name : String, version : String, ?os : String ) {
		if( !stream.features.add( xmpp.SoftwareVersion.XMLNS ) )
			throw "softwareversion feature already added";
		this.stream = stream;
		this.name = name;
		this.version = version;
		this.os = ( os != null ) ? os : SystemUtil.systemName();
		c = stream.collect( [new xmpp.filter.IQFilter( xmpp.SoftwareVersion.XMLNS, xmpp.IQType.get )], handleQuery, true);
	}
	
	public function dispose() {
		stream.removeCollector( c );
		stream.features.remove( xmpp.SoftwareVersion.XMLNS );
	}
	
	function handleQuery( iq : xmpp.IQ ) {
		var r = xmpp.IQ.createResult( iq );
		r.x = new xmpp.SoftwareVersion( name, version, os );
		stream.sendData( r.toString() );
	}
	
}
