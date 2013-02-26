/*
 * Copyright (c), disktree.net
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
	Extension for communicating information about music to which a user is currently listening.
	XEP-0118: User Tune: http://xmpp.org/extensions/xep-0118.html
*/
class UserTune extends xmpp.PersonalEvent {

	public static var XMLNS(default,null) : String = xmpp.Packet.PROTOCOL+"/tune";
	
	/** The artist or performer of the song or piece */
	public var artist : String;
	/** The duration of the song or piece in seconds */
	public var length : Int;
	/** The user's rating of the song or piece, from 1 (lowest) to 10 (highest). */
	public var rating(default,set) : Int;
	/** The collection (e.g., album) or other source (e.g., a band website that hosts streams or audio files) */
	public var source : String;
	/** The title of the song or piece */
	public var title : String;
	/** A unique identifier for the tune; e.g., the track number within a collection or the specific URI for the object (e.g., a stream or audio file) */
	public var track : String;
	/** A URI or URL pointing to information about the song, collection, or artist */
	public var uri : String;
	
	public function new( ?artist : String, ?length : Int, ?rating : Int, ?source : String, ?title : String, ?track : String, ?uri : String ) {
		super( "tune", XMLNS );
		this.artist = artist;
		this.length = length;
		this.rating = rating;
		this.source = source;
		this.title = title;
		this.track = track;
		this.uri = uri;
	}
	
	function set_rating( v : Int ) : Int {
		return rating = ( v < 1 ) ? 1 : ( v > 10 ) ? 10 : v;
	}
	
	public override function toXml() : Xml {
		var x = empty();
		x.addChild( resolveElement( "artist" ) );
		x.addChild( resolveElement( "length" ) );
		x.addChild( resolveElement( "rating" ) );
		x.addChild( resolveElement( "source" ) );
		x.addChild( resolveElement( "title" ) );
		x.addChild( resolveElement( "track" ) );
		x.addChild( resolveElement( "uri" ) );
		return x;
	}
	
	function resolveElement( f : String ) : Xml {
		return xmpp.XMLUtil.createElement( f, Std.string( Reflect.field( this, f ) ) );
	}
	
	public static function parse( x : Xml ) : UserTune  {
		var t = new UserTune();
		for( e in x.elements() ) {
			var v = e.firstChild().nodeValue;
			switch( e.nodeName ) {
			case 'artist' : t.artist = v;
			case 'length' : t.length = Std.parseInt(v);
			case 'rating' : t.rating = Std.parseInt(v);
			case 'source' : t.source = v;
			case 'title' : t.title = v;
			case 'track' : t.track = v;
			case 'uri' : t.uri = v;
			}
		}
		return t;
	}
	
}
