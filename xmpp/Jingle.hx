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
	
	static var _XMLNS = "urn:xmpp:jingle:";
	public static var XMLNS = _XMLNS+"1";
	public static var XMLNS_RTMP = _XMLNS+"apps:rtmp";
	public static var XMLNS_RTMFP = _XMLNS+"apps:rtmfp";
	public static var XMLNS_FILETRANSFER = _XMLNS+"apps:file-transfer:1";
	public static var XMLNS_S5B = _XMLNS+"transports:s5b:1";
	
	public var action : xmpp.jingle.Action;
	public var initiator : String;
	public var sid : String;
	public var content : Array<xmpp.jingle.Content>;
	public var reason : { type : xmpp.jingle.Reason, content : Xml };
	public var other : Array<Xml>;
	
	public function new( action : xmpp.jingle.Action, initiator : String, sid : String ) {
		this.action = action;
		this.initiator = initiator;
		this.sid = sid;
		content = new Array();
		other = new Array();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "jingle" );
		//TODO 2.06
	//	x.set( "xmlns", XMLNS );
		x.set( "_xmlns_", XMLNS );
		x.set( "action", StringTools.replace( Type.enumConstructor( action ), "_", "-" ) );
		x.set( "initiator", initiator );
		x.set( "sid", sid );
		for( c in content ) x.addChild( c.toXml() );
		if( reason != null ) {
			var r = Xml.createElement( "reason" );
			var e = Xml.createElement( Type.enumConstructor( reason.type ) );
			if( reason.content != null ) e.addChild( reason.content );
			r.addChild( e );
			x.addChild( r );
		}
		for( e in other ) x.addChild( e );
		return x;
	}
	
	public static function parse( x : Xml ) : Jingle {
		var j = new xmpp.Jingle( Type.createEnum( xmpp.jingle.Action, StringTools.replace( x.get( "action" ), "-", "_" ) ),
								 x.get( "initiator" ),
								 x.get( "sid" )  );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "content" :
				j.content.push( xmpp.jingle.Content.parse( e ) );
			case "reason" :
				j.reason = { type : Type.createEnum( xmpp.jingle.Reason, e.firstChild().nodeName ),
							 content : e.firstChild().firstChild() };
			default :
				j.other.push( e );
			}
		}
		return j;
	}
	
}
