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
package xmpp;

class Jingle {
	
	public static var XMLNS = "urn:xmpp:jingle:1";
	public static var NODENAME = "jingle";
	
	public var action : xmpp.jingle.Action;
	public var initiator : String;
	public var sid : String;
	public var responder : String;
	public var content : Array<xmpp.jingle.Content>;
//	public var reason : xmpp.jingle.Reason;
//	public var thread : Thread;
	public var any : Array<Xml>;

	public function new( action : xmpp.jingle.Action, initiator : String, sid : String ) {
		this.action = action;
		this.initiator = initiator;
		this.sid = sid;
		content = new Array();
		any = new Array();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( NODENAME );
		x.set( "xmlns", XMLNS );
		x.set( "action", StringTools.replace( Type.enumConstructor( action ), "_", "-" ) );
		x.set( "initiator", initiator );
		x.set( "sid", sid );
		if( responder != null ) x.set( "responder", responder );
		for( c in content )
			x.addChild( c.toXml() );
		for( a in any )
			x.addChild( a );
		//TODO
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.Jingle {
		var j = new xmpp.Jingle( Type.createEnum( xmpp.jingle.Action, StringTools.replace( x.get( "action" ), "-", "_" ) ), x.get( "initiator" ), x.get( "sid" )  );
		//TODO
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "content" :
				j.content.push( xmpp.jingle.Content.parse( e ) );
			//case "reason" :
			default :
				j.any.push( e );
			}
		}
		return j;
	}
	
	//public static function createTransport( xmlns : String, e : Array<Xml> )
}
