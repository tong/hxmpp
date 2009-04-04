package xmpp.pep;

/**
	Extended information about user moods, such as whether a person is currently happy, sad, angy, or annoyed.
	<a href="http://xmpp.org/extensions/xep-0107.html">XEP-0107: User Mood</a><br/>
*/
class UserMood extends Event {
	
	public static var XMLNS = xmpp.NS.PROTOCOL+"/mood";
	
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
			x.addChild( util.XmlUtil.createElement( "text", text ) );
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
