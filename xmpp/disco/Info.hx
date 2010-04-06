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

/**
*/
class Info {
	
	public static var XMLNS = xmpp.Namespace.PROTOCOL+'/disco#info';
	
	public var identities : Array<Identity>; 
	public var features : Array<String>;
	public var node : String;
	public var x : Xml; //TODO
	
	public function new( ?identities : Array<Identity>, ?features : Array<String>, ?node : String ) {
		this.identities = identities == null ? new Array() : identities;
		this.features = features == null ? new Array() : features;
		this.node = node;
	}

	public function toXml() : Xml {
		var x = xmpp.IQ.createQueryXml( XMLNS );
		if( node != null ) x.set( "node", node );
		for( i in identities ) {
			var identity = Xml.createElement( 'identity' );
			if( i.category != null ) identity.set( "category", i.category );
			if( i.name != null ) identity.set( "name", i.name );
			if( i.type != null ) identity.set( "type", i.type );
			x.addChild( identity );
		}
		if( features.length > 0 ) {
			for( f in features ) {
				var feature = Xml.createElement( 'feature' );
				feature.set( "var", f );
				x.addChild( feature );
			}
		}
		return x;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	public static function parse( x : Xml ) : Info {
		var i = new Info( null, null, x.get( "node" ) );
		for( f in x.elements() ) {
			switch( f.nodeName ) {
			case "feature"  : i.features.push( f.get( "var" ) );
			case "identity" : i.identities.push( { category : f.get( "category" ),
												   name : f.get( "name" ),
												   type : f.get( "type" ) } );
			case "x" : i.x = f;
			}
		}
		return i;
	}
	
}
