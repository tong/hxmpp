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
	Extension for communicating information about music to which a user is currently listening.
	<a href="http://xmpp.org/extensions/xep-0118.html">XEP-0118: User Tune</a><br/>
*/
class UserTune extends Event {

	public static var XMLNS = xmpp.Packet.PROTOCOL+"/tune";
	
	/** The artist or performer of the song or piece */
	public var artist : String;
	/** The duration of the song or piece in seconds */
	public var length : Int;
	/** The user's rating of the song or piece, from 1 (lowest) to 10 (highest). */
	public var rating(default,setRating) : Int;
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
	
	function setRating( v : Int ) : Int {
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
		var f = new haxe.xml.Fast( x );
		return new UserTune( f.node.artist.innerData,
							 Std.parseInt( f.node.length.innerData ),
							 Std.parseInt( f.node.rating.innerData ),
							 f.node.source.innerData,
							 f.node.title.innerData,
							 f.node.track.innerData,
							 f.node.uri.innerData );
	}
	
}
