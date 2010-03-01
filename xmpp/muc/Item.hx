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
package xmpp.muc;

import xmpp.XMLUtil;

/**
*/
class Item {
	
	public var affiliation : Affiliation;
	public var role : Role;
	public var nick : String;
	public var jid : String;
	public var actor : String;
	public var reason : String;
	public var continue_ : String;
	
	public function new( ?affiliation : Affiliation, ?role : Role, ?nick : String, ?jid : String ) {
		this.affiliation = affiliation;
		this.role = role;
		this.nick = nick;
		this.jid = jid;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "item" );
		if( jid != null ) x.set( "jid", jid );
		if( nick != null ) x.set( "nick", nick );
		if( role != null ) x.set( "role", Type.enumConstructor( role ) );
		if( affiliation != null ) x.set( "affiliation", Type.enumConstructor( affiliation ) );
		if( actor != null ) {
			var e = Xml.createElement( "actor" );
			e.set( "jid", actor );
			x.addChild( e );
		}
		if( reason != null ) {
			x.addChild( XMLUtil.createElement( "reason", reason ) );
		}
		if( continue_ != null ) {
			var e = Xml.createElement( "continue" );
			e.set( "thread", continue_ );
			x.addChild( e );
		}
		return x;
	}
	
	public static function parse( x : Xml ) : Item {
		var p = new Item();
		if( x.exists( "affiliation" ) ) p.affiliation = Type.createEnum( Affiliation, x.get( "affiliation" ) );
		if( x.exists( "role" ) ) p.role = Type.createEnum( Role, x.get( "role" ) );
		if( x.exists( "nick" ) ) p.nick = x.get( "nick" );
		if( x.exists( "jid" ) ) p.jid = x.get( "jid" );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
				case "actor" : p.actor = e.get( "jid" );
				case "reason" : p.reason = e.firstChild().nodeValue;
				case "continue" : p.continue_ = e.get( "continue" );
			}
		}
		return p;
	}
	
}
