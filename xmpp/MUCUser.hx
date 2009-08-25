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

import xmpp.MUC;
import xmpp.muc.Decline;
import xmpp.muc.Destroy;
import xmpp.muc.Item;
import xmpp.muc.Status;
import xmpp.muc.Invite;

class MUCUser {
	
	public static var XMLNS = xmpp.MUC.XMLNS+"#user";
	
	public var decline : Decline;
	public var destroy : Destroy;
	public var invite : Invite;
	public var item : Item;
	public var password : String;
	public var status : Status;
	
	
	public function new() {}
	
	
	public function toXml() : Xml {
		var x = Xml.createElement( "x" );
		x.set( "xmlns", XMLNS );
		if( invite != null ) x.addChild( invite.toXml() );
		if( decline != null ) x.addChild( decline.toXml() );
		if( item != null ) x.addChild( item.toXml() );
		if( password != null ) x.addChild( util.XmlUtil.createElement( "password", password ) );
		if( status != null ) x.addChild( status.toXml() );
		if( destroy != null ) x.addChild( destroy.toXml() );
		return x;
	}
	
	public inline function toString() : String { return toXml().toString(); }
	
	
	public static function parse( x : Xml ) : xmpp.MUCUser {
		var p = new MUCUser();
		for( e in x.elements() ) {
			switch( e.nodeName ) {
				case "item" :
					p.item = Item.parse( e );	
				case "status" :
					p.status = Status.parse( e );
				}
		}
		return p;
		/*
		var ext = new MUCUser();
		for( e in x.elements() ) {
			//trace(">>>>>>>>>>>>>>>>>>>>>>>>>> "+e.nodeName );
			//trace(e.nodeName);
			//trace( e.get( "xmlns" ) );
			
		((	if( e.nodeName != "x" || e.get( "xmlns" ) != XMLNS ) continue;
			
			trace(">>>>>>>>>>>>>>>>>>>>>>>>>> "+ee.nodeName );
			for( ee in e.elements() ) {
				switch( ee.nodeName ) {
					//
					case "item" :
						ext.item = Item.parse( ee );
						trace(ext.item);
						
					case "status" :
						ext.status = Status.parse( ee );
				}
			}
		}
		return ext;
			*/
	}
	
}
