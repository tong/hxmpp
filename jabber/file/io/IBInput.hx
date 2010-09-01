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
package jabber.file.io;

import jabber.util.Base64;
import jabber.stream.PacketCollector;
import xmpp.filter.IQFilter;

//TODO encode data onrecieve

//TODO class IBIput extends IBIO {
class IBInput extends IO {
	
	public var data(getData,null) : haxe.io.Bytes;
	
	var stream : jabber.Stream;
	var initiator : String;
	var seq : Int;
	var buf : StringBuf;
	var cdata : PacketCollector;
	var sid : String;
	
	public function new( stream : jabber.Stream, initiator : String, sid : String ) {
		super();
		this.stream = stream;
		this.initiator = initiator;
		this.sid = sid;
		seq = 0;
		buf = new StringBuf();
		var ff : xmpp.PacketFilter = new xmpp.filter.PacketFromFilter( initiator );
		// collect stream closing iqs
		var cclose = new PacketCollector( [ ff, cast new IQFilter( xmpp.file.IB.XMLNS, Type.enumConstructor( xmpp.file.IBType.close ), xmpp.IQType.set ) ], handleIBClose, false );
		stream.addCollector( cclose );
		// collect data iqs
		cdata = new PacketCollector( [ ff, cast new IQFilter( xmpp.file.IB.XMLNS, Type.enumConstructor( xmpp.file.IBType.data ), xmpp.IQType.set ) ], handleIBData, true );
		stream.addCollector( cdata );
	}
	
	function getData() : haxe.io.Bytes {
		//return haxe.io.Bytes.ofString( buf.toString() );
		return new haxe.BaseCode( haxe.io.Bytes.ofString( Base64.CHARS ) ).decodeBytes( haxe.io.Bytes.ofString( buf.toString() ) );
	}
	
	function handleIBData( iq : xmpp.IQ ) {
		var i = xmpp.file.IB.parseData( iq ); //?
		if( seq != i.seq ) {
			//__onFail( "In-band data packet loss ("+i.seq+")" );
			__onFail();
			return;
		}
		if( i.sid != sid ) {
			//__onFail( "Invalid SID" );
			__onFail();
			return;
		}
		seq++;
		buf.add( i.data );
		//buf.add( util.Base64.decode( i.data ) );
		stream.sendPacket( xmpp.IQ.createResult( iq ) );
		//onProgress( this );
	}
	
	function handleIBClose( iq : xmpp.IQ ) {
		// read success?
		stream.removeCollector( cdata );
		stream.sendPacket( xmpp.IQ.createResult( iq ) );
		//__onClose();
		__onComplete();
	}
	
}
