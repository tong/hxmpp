/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009-2010 http://www.disktree.net
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
package jabber.jingle;

import flash.net.NetConnection;
import flash.net.NetStream;
import jabber.stream.PacketCollector;
import xmpp.IQ;
import xmpp.IQType;

/**
	Abstract RTMFP session base.
	Flash 10+ only.
*/
class RTMFPSession extends Session {
	
	static function __init__() {
		connectUrl = "rtmfp://stratus.rtmfp.net";
	}
	
	public static var connectUrl(default,null) : String;
	
	public var nc(default,null) : NetConnection;
	public var ns(default,null) : NetStream;
	
	var stratusKey : String;
	
	function new( stream : jabber.Stream, stratusKey : String ) {
		super( stream );
		this.stratusKey = stratusKey;
	}
	
	public override function terminate( ?reason : xmpp.jingle.Reason, ?content : Xml ) {
		if( nc != null && nc.connected ) nc.close();
		super.terminate( reason, content );
	}
	
	function handleSessionPacket( iq : IQ ) {
		var j = xmpp.Jingle.parse( iq.x.toXml() );
		switch( j.action ) {
		case session_terminate :
			if( nc != null && nc.connected ) nc.close();
			stream.sendPacket( IQ.createResult( iq ) );
			onEnd( j.reason.type );
		default :
			trace("TODO #####");
		}
	}
	
	function createSessionPacketCollector() : PacketCollector {
		return stream.collect( [cast new xmpp.filter.PacketFromFilter( entity ),
						 	 	cast new xmpp.filter.IQFilter( xmpp.Jingle.XMLNS, "jingle", IQType.set ),
						 	 	cast new xmpp.filter.JingleFilter( xmpp.jingle.RTMFP.XMLNS, sid )],
							 	handleSessionPacket, true );
	}
	
}
