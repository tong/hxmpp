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
package jabber.jingle.transport;

/**
	flash9.
	Outgoing RTMP transport.
*/
class RTMPOutput extends RTMPTransport {
	
	public static var defaultRecord = "record.flv";
	
	public var __onPublish : Void->Void;
	
	public function new( name : String, host : String, port : Int, id : String ) {
		super( name, host, port, id );
	}
	
	/**
		Start publishing to server.
	*/
	public function publish( ?record : String ) {
		//trace("PUBLISH: "+id );
		ns.publish( ( record == null ) ? defaultRecord : record, id );
	}
	
	override function netStatusHandler( e : flash.events.NetStatusEvent ) {
		if( e.info.code == "NetStream.Publish.Start" ) __onPublish();
		else super.netStatusHandler( e );
	}
	
	public static inline function ofCandidate( c : xmpp.jingle.TRTMPCandidate ) : RTMPOutput {
		return new RTMPOutput( c.name, c.host, c.port, c.id );
	}
	
}
