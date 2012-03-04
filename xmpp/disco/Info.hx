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
package xmpp.disco;

class Info {
	
	public static var XMLNS = xmpp.Packet.PROTOCOL+'/disco#info';
	
	public var identities : Array<Identity>; 
	
	/** */
	public var features : Array<String>;
	
	/** */
	public var node : String;
	
	/** Dataform */
	public var x : Xml;
	
	public function new( ?identities : Array<Identity>, ?features : Array<String>, ?node : String ) {
		this.identities = ( identities == null ) ? new Array() : identities;
		this.features = ( features == null ) ? new Array() : features;
		this.node = node;
	}

	public function toXml() : Xml {
		var x = xmpp.IQ.createQueryXml( XMLNS );
		if( node != null ) x.set( "node", node );
		for( i in identities ) {
			var ix = Xml.createElement( 'identity' );
			if( i.category != null ) ix.set( "category", i.category );
			if( i.name != null ) ix.set( "name", i.name );
			if( i.type != null ) ix.set( "type", i.type );
			x.addChild( ix );
		}
		if( features.length > 0 ) {
			for( f in features ) {
				var fx = Xml.createElement( 'feature' );
				fx.set( "var", f );
				x.addChild( fx );
			}
		}
		if( this.x != null )
			x.addChild( this.x );
		return x;
	}
	
	public static function parse( x : Xml ) : Info {
		var i = new Info( null, null, x.get( "node" ) );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "feature"  : i.features.push( e.get( "var" ) );
			case "identity" : i.identities.push( { category : e.get( "category" ),
												   name : e.get( "name" ),
												   type : e.get( "type" ) } );
			case "x" : i.x = e;
			}
		}
		return i;
	}
	
}
