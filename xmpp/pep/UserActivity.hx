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
			if( extended.xmlns != null ) xmpp.XMLUtil.setNamespace( e, extended.xmlns );
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
