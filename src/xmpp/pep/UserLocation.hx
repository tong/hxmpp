/*
 * Copyright (c) 2012, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package xmpp.pep;

/**
	Extended information about the current geographical or physical location of an entity.
	<a href="http://xmpp.org/extensions/xep-0080.html">XEP-0080: User Location</a><br/>
*/
class UserLocation extends xmpp.PersonalEvent {

	public static var XMLNS(default,null) : String = xmpp.Packet.PROTOCOL+"/geoloc";
	
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
		var l = new UserLocation();
		for( e in x.elements() ) {
			var v = e.firstChild().nodeValue;
			switch( e.nodeName ) {
			case 'accuracy' : l.accuracy = Std.parseInt(v);
			case 'alt' : l.alt = Std.parseInt(v);
			case 'area' : l.area = v;
			case 'bearing' : l.bearing = Std.parseInt(v);
			case 'building' : l.building = v;
			case 'country' : l.country = v;
			case 'datum' : l.datum = v;
			case 'description' : l.description = v;
			case 'error' : l.error = Std.parseInt(v);
			case 'floor' : l.floor = v;
			case 'lat' : l.lat = Std.parseFloat(v);
			case 'locality' : l.locality = v;
			case 'lon' : l.lon = Std.parseFloat(v);
			case 'postalcode' : l.postalcode = v;
			case 'region' : l.region = v;
			case 'room' : l.room = v;
			case 'speed' : l.speed = Std.parseFloat(v);
			case 'street' : l.street = v;
			case 'text' : l.text = v;
			case 'timestamp' : l.timestamp = v;
			case 'uri' : l.uri = v;
			}
		}
		return l;
	}
	
}
