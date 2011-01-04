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
	Extended information about the current geographical or physical location of an entity.
	<a href="http://xmpp.org/extensions/xep-0080.html">XEP-0080: User Location</a><br/>
*/
class UserLocation extends xmpp.PersonalEvent {

	public static var XMLNS = xmpp.Packet.PROTOCOL+"/geoloc";
	
	/** Horizontal GPS error in meters; this element obsoletes the <error/> element */
	public var accuracy : Int;
	/** Altitude in meters above or below sea level */
	public var alt : Int;
	/** A named area such as a campus or neighborhood */
	public var area : String;
	/** GPS bearing (direction in which the entity is heading to reach its next waypoint), measured in decimal degrees relative to true north */
	public var bearing : Int;
	/** A specific building on a street or in an area */
	public var building : String;
	/** The nation where the user is located */
	public var country : String;
	/** GPS datum */
	public var datum : String;
	/** A natural-language name for or description of the location */
	public var description : String;
	/** Horizontal GPS error in arc minutes; this element is deprecated in favor of <accuracy/> */
	public var error : Int;
	/** A particular floor in a building */
	public var floor : String;
	/** Latitude in decimal degrees North */
	public var lat : Float;
	/** A locality within the administrative region, such as a town or city */
	public var locality : String;
	/** Longitude in decimal degrees East */
	public var lon : Float;
	/** A code used for postal delivery */
	public var postalcode : String;
	/** An administrative region of the nation, such as a state or province */
	public var region : String;
	/** A particular room in a building */
	public var room : String;
	/** The speed at which the entity is moving, in meters per second */
	public var speed : Float;
	/** A thoroughfare within the locality, or a crossing of two thoroughfares */
	public var street : String;
	/** A catch-all element that captures any other information about the location */
	public var text : String;
	/** UTC timestamp specifying the moment when the reading was taken */
	public var timestamp : String;
	/** A URI or URL pointing to information about the location */
	public var uri : String;
	
	public function new() {
		super( "geoloc", XMLNS );
	}
	
	public override function toXml() : Xml {
		var x = empty();
		addElement( "accuracy", x );
		addElement( "alt", x );
		addElement( "area", x );
		addElement( "bearing", x );
		addElement( "building", x );
		addElement( "country", x );
		addElement( "datum", x );
		addElement( "description", x );
		addElement( "lat", x );
		addElement( "floor", x );
		addElement( "locality", x );
		addElement( "lon", x );
		addElement( "postalcode", x );
		addElement( "region", x );
		addElement( "room", x );
		addElement( "speed", x );
		addElement( "street", x );
		addElement( "text", x );
		addElement( "timestamp", x );
		addElement( "uri", x );
		return x;
	}
	
	function addElement( f : String, x : Xml ) {
		var d = Std.string( Reflect.field( this, f ) );
		if( d != null ) x.addChild( xmpp.XMLUtil.createElement( f, d ) );
	}
	
	public static function parse( x : Xml ) : UserLocation  {
		//TODO remove dependency of haxe.xml.Fast
		var f = new haxe.xml.Fast( x );
		var l = new UserLocation();
		if( f.hasNode.accuracy ) 	l.accuracy = Std.parseInt( f.node.accuracy.innerData );
		if( f.hasNode.alt ) 		l.alt = Std.parseInt( f.node.alt.innerData );
		if( f.hasNode.area ) 		l.area = f.node.area.innerData;
		if( f.hasNode.bearing ) 	l.bearing = Std.parseInt( f.node.bearing.innerData );
		if( f.hasNode.building ) 	l.building = f.node.building.innerData;
		if( f.hasNode.country ) 	l.country = f.node.country.innerData;
		if( f.hasNode.datum ) 		l.datum = f.node.datum.innerData;
		if( f.hasNode.description ) l.description = f.node.description.innerData;
		if( f.hasNode.error ) 		l.error = Std.parseInt( f.node.error.innerData );
		if( f.hasNode.floor ) 		l.floor = f.node.floor.innerData;
		if( f.hasNode.lat ) 		l.lat = Std.parseFloat( f.node.lat.innerData );
		if( f.hasNode.locality ) 	l.locality = f.node.locality.innerData;
		if( f.hasNode.lon ) 		l.lon = Std.parseFloat( f.node.lon.innerData );
		if( f.hasNode.postalcode ) 	l.postalcode = f.node.postalcode.innerData;
		if( f.hasNode.region ) 		l.region = f.node.region.innerData;
		if( f.hasNode.room ) 		l.room = f.node.room.innerData;
		if( f.hasNode.speed ) 		l.speed = Std.parseFloat( f.node.speed.innerData );
		if( f.hasNode.street ) 		l.street = f.node.street.innerData;
		if( f.hasNode.text ) 		l.text = f.node.text.innerData;
		if( f.hasNode.timestamp ) 	l.timestamp = f.node.timestamp.innerData;
		if( f.hasNode.uri ) 		l.uri = f.node.uri.innerData;
		return l;
	}
	
}
