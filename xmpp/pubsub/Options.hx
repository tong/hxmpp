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
package xmpp.pubsub;

class Options {
	
	public var jid : String;
	public var node : String;
	public var subid : String;
	public var form : xmpp.DataForm;
	
	public function new( ?jid : String, ?node : String, ?subid : String, ?form : xmpp.DataForm ) {
		this.jid = jid;
		this.node = node;
		this.subid = subid;
		this.form = form;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "options" );
		if( jid != null ) x.set( "jid", jid );
		if( node != null ) x.set( "node", node );
		if( subid != null ) x.set( "subid", subid );
		if( form != null ) x.addChild( form.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : Options {
		var f : xmpp.DataForm = null;
		for( e in x.elementsNamed( "x" ) ) {
			f = xmpp.DataForm.parse( e );
			break;
		}
		return new Options( x.get( "jid" ),  x.get( "node" ),  x.get( "subid" ), f );
	}
	
}
