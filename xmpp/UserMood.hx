package xmpp;


/**
	<a href="http://xmpp.org/extensions/xep-0107.html">XEP-0107: User Mood</a><br/>
*/
class UserMood {
	
	public static var XMLNS = "http://jabber.org/protocol/mood";
	
	public var mood : xmpp.Mood;
	public var text : String; 
	
	public function new( mood : xmpp.Mood, ?text : String ) {
		if( mood == null ) throw "Invalid mood xmpp";
		this.mood = mood;
		this.text = text;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "mood" );
		x.set( "xmlns", XMLNS );
		x.addChild( Xml.createElement( Type.enumConstructor( mood ) ) );
		if( text != null ) x.addChild( util.XmlUtil.createElement( "text", text ) );
		return x;
	}
	
	#if JABBER_DEBUG public inline function toString() : String { return toXml().toString(); } #end
	
	public static function parse( x : Xml ) : xmpp.UserMood {
		if( x.nodeName != "mood" || x.get( "xmlns" ) != XMLNS ) throw "Invalid mood xmpp";
		var _m : xmpp.Mood = null;
		var _t : String = null;
		for( e in x.elements() ) {
			if( e.nodeName == "text" ) {
				_t = e.firstChild().nodeValue;
				if( _m != null ) break;
			} else {
				_m = Type.createEnum( xmpp.Mood, e.nodeName );
				if( _t != null ) break;
			}
		}
		return new xmpp.UserMood( _m, _t );
	}
	
}
