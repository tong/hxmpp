/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package jabber;

import jabber.stream.PacketCollector;
import jabber.util.SystemUtil;

/**
	<a href="http://www.xmpp.org/extensions/xep-0092.html">XEP 0092 - Software Version</a>
	Extension for retrieving information about the software application associated with an XMPP entity
*/
class SoftwareVersionListener {
	
	//public dynamic function onLoad( jid : String, sv : xmpp.SoftwareVersion ) {}
	
	public var stream(default,null) : Stream;
	/** The natural-language name of the software */
	public var name : String;
	/** The specific version of the software*/
	public var version : String;
	/** The operating system of the queried entity (optional) */
	public var os : String;
	
	var c : PacketCollector;
	
	public function new( stream : Stream,
						 name : String, version : String, ?os : String ) {
		if( !stream.features.add( xmpp.SoftwareVersion.XMLNS ) )
			throw "softwareversion feature already added";
		this.stream = stream;
		this.name = name;
		this.version = version;
		this.os = ( os != null ) ? os : SystemUtil.systemName();
		c = stream.collect( [ cast new xmpp.filter.IQFilter( xmpp.SoftwareVersion.XMLNS, xmpp.IQType.get ) ], handleQuery, true);
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
