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
package jabber.jingle.io;

/**
*/
@:require(js) class WebRTCSDPInput extends WebRTCSDPTransport {
	
	public var stream(default,null) : Dynamic;
	
	public function new( sdp : String ) {
		super();
		this.sdp  =sdp;
	}
	
	public override function connect() {
		super.connect();
		connection.processSignalingMessage( sdp );
	}
	
	override function signalingCallback( s : String ) {
		sdp = s;
		__onConnect();
		
	}
	
	override function onRemoteStreamAdded(e) {
		stream = e.stream;
	}
	
	/* 
	public static inline function ofCandidate( x : Xml ) : WebRTCInput {
		return new WebRTCInput();
		//return null;
		//return new RTMPInput( x.get( "name" ), x.get( "host" ), Std.parseInt( x.get( "port" ) ), x.get( "id" ) );
	}
	*/
	
}
