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

import haxe.io.Bytes;
import xmpp.IQ;

/**
	Listens for incoming file transfer requests.
*/
class SIListener {
	
	public dynamic function onFail( info : String ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	public var methods(default,null) : Array<DataReciever>;
	public var handler : DataReciever->Void;
	
	//var file : xmpp.file.File;
	//var methodIndex : Int;
	
	public function new( stream : jabber.Stream, handler : DataReciever->Void ) {
		this.stream = stream;
		this.handler = handler;
		methods = new Array();
		stream.features.add( xmpp.file.SI.XMLNS_PROFILE );
		stream.collect( [cast new xmpp.filter.IQFilter( xmpp.file.SI.XMLNS, "si", xmpp.IQType.set )],
						 handleRequest, true );
	}
	
	function handleRequest( iq : xmpp.IQ ) {
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
					var field = form.fields[0];
					if( field.variable == "stream-method" ) {
						for( o in field.options ) {
							_methods.push( o.value );
						}
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
			//TODO send error
			onFail( "invalid file transfer request" );
			return;
		}
		var acceptedMethods = new Array<DataReciever>();
		for( m in methods ) {
			for( _m in _methods ) {
				if( m.xmlns == _m )
					acceptedMethods.push( m );
			}
		}
		if( acceptedMethods.length == 0 ) {
			onFail( "no matching file transfer method" );
			return;
		}
		// new FileTransferNegotiator();
		var m = acceptedMethods[0];
		m.init( file, iq, si.id );
		handler( m );
	}
	
}
