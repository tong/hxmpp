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
package jabber.remoting;

import haxe.remoting.Context;

/**
	haXe/XMPP remoting host .
*/
class Host {
	
	public var stream(default,null) : jabber.Stream;
	
	var ctx : Context;
	
	public function new( stream : jabber.Stream, ctx :  haxe.remoting.Context ) {
		this.stream = stream;
		this.ctx = ctx;
		stream.features.add( xmpp.HaXe.XMLNS );
		var f_type = new xmpp.filter.IQFilter( xmpp.HaXe.XMLNS );
		stream.collect( [cast f_type], handleIQ, true );
	}
	
	function handleIQ( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case get :
			var request = xmpp.HaXe.getData( iq.x.toXml() );
			var response = processRequest( request, ctx );
			var r = xmpp.IQ.createResult( iq );
			r.properties.push( xmpp.HaXe.create( response ) );
			stream.sendPacket( r );
		default :
			//TODO check error settings
			var r = xmpp.IQ.createErrorResult( iq, [new xmpp.Error(xmpp.ErrorType.modify,null,xmpp.ErrorCondition.NOT_ACCEPTABLE)] );
			stream.sendPacket( r );
		}
	}
	
	public static function processRequest( requestData : String, ctx : Context ) : String {
		try {
			var u = new haxe.Unserializer( requestData );
			var path = u.unserialize();
			var args = u.unserialize();
			var data = ctx.call( path, args );
			var s = new haxe.Serializer();
			s.serialize( data );
			return "hxr"+s.toString();
		} catch( e : Dynamic ) {
			var s = new haxe.Serializer();
			s.serializeException( e );
			return "hxr"+s.toString();
		}
	}
	
}
