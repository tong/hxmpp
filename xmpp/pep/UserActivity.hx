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
package xmpp.pep;

/**
	Extended presence data about user activities.
	<a href="http://xmpp.org/extensions/xep-0108.html">XEP-0108: User Activity</a><br/>
*/
class UserActivity extends xmpp.PersonalEvent {
	
	public static var XMLNS = xmpp.Packet.PROTOCOL+"/activity";
	
	public var activity : Activity;
	public var text : String; 
	public var extended : { activity : String, xmlns : String, detail : { activity : String, xmlns : String } };
	
	public function new( activity : Activity, ?text : String, ?extended : { activity : String, xmlns : String, detail : { activity : String, xmlns : String } } ) {
		super( "activity", XMLNS );
		this.activity = activity;
		this.text = text;
		this.extended = extended;
	}
	
	public override function toXml() : Xml {
		var x = empty();
		var a = Xml.createElement( Type.enumConstructor( activity ) );
		if( extended != null ) {
			var e = Xml.createElement( extended.activity );
			if( extended.xmlns != null ) e.set( "xmlns", extended.xmlns );
			a.addChild( e );
		}
		x.addChild( a );
		if( text != null )
			x.addChild( xmpp.XMLUtil.createElement( "text", text ) );
		return x;
	}
	
	public static function parse( x : Xml ) : UserActivity {
		var a : Activity = null;
		var t : String = null;
		var ext : { activity : String, xmlns : String, detail : { activity : String, xmlns : String } } = null;
		for( e in x.elements() ) {
			if( e.nodeName == "text" )
				t = e.firstChild().nodeValue;
			else {
				//try {
					a = Type.createEnum( xmpp.pep.Activity, e.nodeName );
					for( _ext in e.elements() ) {
						var detail : { activity : String, xmlns : String } = null;
						for( _d in _ext.elements() )
							detail = { activity : _d.nodeName, xmlns : _d.get( "xmlns" ) };
						ext = { activity : _ext.nodeName, xmlns : _ext.get( "xmlns" ), detail : detail };
					}
				//} catch( e :Dynamic ) { return null; }
			}
		}
		return new UserActivity( a, t, ext );
	}
	
}
