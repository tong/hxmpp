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
package jabber.data;

import xmpp.IQ;

/**
	<a href="http://xmpp.org/extensions/xep-0096.html">XEP-0096: SI File Transfer</a><br/>
	Listens/Negotiates incoming data transfer requests.
*/
class SIListener {
	
	public dynamic function onFail( info : String ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	/** Available file transfer methods */
	public var methods(default,null) : Array<DataReciever>;
	/** Callback handler for incoming transfer requests */
	public var handler : DataReciever->Void;
	
	var collector : jabber.stream.PacketCollector;
	
	public function new( stream : jabber.Stream, handler : DataReciever->Void ) {
		if( !stream.features.add( xmpp.file.SI.XMLNS_PROFILE ) )
			throw "SI data transfer listener already added";
		this.stream = stream;
		this.handler = handler;
		methods = new Array();
		collector = stream.collect( [cast new xmpp.filter.IQFilter( xmpp.file.SI.XMLNS, "si", xmpp.IQType.set )],
						 			handleRequest, true );
	}
	
	public function dispose() {
		stream.removeCollector( collector );
		stream.features.remove( xmpp.file.SI.XMLNS_PROFILE  );
	}
	
	function handleRequest( iq : IQ ) {
		if( this.methods.length == 0 ) {
			#if JABBER_DEBUG trace( "No file tranfer methods registerd with the SI listener", "warn" ); #end
			return;
		}
		var si = xmpp.file.SI.parse( iq.x.toXml() );
		var file : xmpp.file.File = null;
		var _methods = new Array<String>();
		for( e in si.any ) {
			#if flash // haXe 2.06 fukup
			if( e.nodeName == "feature" && e.get( "_xmlns_" ) == xmpp.FeatureNegotiation.XMLNS ) {
			#else
			if( e.nodeName == "feature" && e.get( "xmlns" ) == xmpp.FeatureNegotiation.XMLNS ) {
			#end
				for( e in e.elementsNamed( "x" ) ) {
					var form = xmpp.DataForm.parse( e );
					var f = form.fields[0];
					if( f.variable == "stream-method" ) {
						for( o in f.options )
							_methods.push( o.value );
					}
				}
			#if flash // haXe 2.06 fukup
			} else if( e.nodeName == "file" && e.get( "_xmlns_" ) == xmpp.file.SI.XMLNS_PROFILE ) {
			#else
			} else if( e.nodeName == "file" && e.get( "xmlns" ) == xmpp.file.SI.XMLNS_PROFILE ) {
			#end
				file = xmpp.file.File.parse( e );
			}
		}
		if( file == null ) {
			stream.sendPacket( IQ.createError( iq, [new xmpp.Error( xmpp.ErrorType.cancel,
																	xmpp.ErrorCondition.BAD_REQUEST )] ) );
			onFail( "invalid file transfer request" );
			return;
		}
		var a_methods = new Array<DataReciever>();
		for( m in methods ) {
			for( _m in _methods ) {
				if( m.xmlns == _m ) a_methods.push( m );
			}
		}
		if( a_methods.length == 0 ) {
			onFail( "no matching file transfer method" );
			stream.sendPacket( IQ.createError( iq, [new xmpp.Error( xmpp.ErrorType.cancel,
																	xmpp.ErrorCondition.BAD_REQUEST )] ) );
			return;
		}
		// new FileTransferNegotiator();
		var m = a_methods[0];
		m.init( file, iq, si.id );
		handler( m );
	}
	
}
