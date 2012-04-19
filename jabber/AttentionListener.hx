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

/**
	<a href="http://www.xmpp.org/extensions/xep-0224.html">XEP 224 - Attention</a><br/>
	Listens/Reports attention request.
*/
class AttentionListener {
	
	public dynamic function onCapture( m : xmpp.Message ) {}
	
	public var stream(default,null) : Stream;
	
	var c : PacketCollector;
	
	public function new( stream : Stream, ?onCapture : xmpp.Message->Void ) {
		if( !stream.features.add( 'urn:xmpp:attention:0' ) )
			throw 'attention listener already added';
		this.stream = stream;
		this.onCapture = onCapture;
		c = stream.collect( [new xmpp.filter.MessageFilter(xmpp.MessageType.chat)], handleRequest, true );
	}
	
	public function dispose() {
		stream.removeCollector( c );
	}
	
	function handleRequest( m : xmpp.Message ) {
		onCapture( m );
	}

}
