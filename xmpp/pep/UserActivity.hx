package xmpp.pep;

/**
	Extended presence data about user activities.
	<a href="http://xmpp.org/extensions/xep-0108.html">XEP-0108: User Activity</a><br/>
*/
class UserActivity extends Event {
	
	public static var XMLNS = xmpp.NS.PROTOCOL+"/activity";
	
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
			if( extended.xmlns != null ) e.set( "xmlns", extended.xmlns );
			a.addChild( e );
		}
		x.addChild( a );
		if( text != null )
			x.addChild( util.XmlUtil.createElement( "text", text ) );
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
