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
	Extended information about user moods, such as whether a person is currently happy, sad, angy, annoyed ...
	XEP-0107: User Mood: http://xmpp.org/extensions/xep-0107.html
*/
class UserMood extends xmpp.PersonalEvent {
	
	public static var XMLNS(default,null) : String = xmpp.Packet.PROTOCOL+"/mood";
	
	public var type : Mood;
	public var text : String; 
	public var extended : { mood : String, xmlns : String };
	
	public function new( ?type : Mood, ?text : String, ?extended : { mood : String, xmlns : String } ) {
		super( "mood", XMLNS );
		this.type = type;
		this.text = text;
		this.extended = extended;
	}
	
	public override function toXml() : Xml {
		var x = empty();
		var m = Xml.createElement( Type.enumConstructor( type ) );
		if( extended != null ) {
			var e = Xml.createElement( extended.mood );
			e.set( "xmlns", extended.xmlns );
			m.addChild( e );
		}
		x.addChild( m );
		if( text != null )
			x.addChild( xmpp.XMLUtil.createElement( "text", text ) );
		return x;
	}
	
	public static function parse( x : Xml ) : UserMood {
		var m : Mood = null;
		var t : String = null;
		var ext : { mood : String, xmlns : String } = null;
		for( e in x.elements() ) {
			if( e.nodeName == "text" )
				t = e.firstChild().nodeValue;
			else {
				//try {
					m = Type.createEnum( xmpp.pep.Mood, e.nodeName );
					for( _ext in e.elements() )
						ext = { mood : _ext.nodeName, xmlns : _ext.get( "xmlns" ) };
				//} catch( e :Dynamic ) { return null; }
			}
		}
		return new UserMood( m, t, ext );
	}
	
}
