package xmpp;


class PubSubOwner {
	
	public static var XMLNS = xmpp.PubSub.XMLNS+"#owner";
	
	/** Set to "" to add a empty delete element */
	public var delete : String;
	public var purge : String;
	public var configure : { form : xmpp.DataForm, node : String };
	public var subscriptions : xmpp.pubsub.Subscriptions;
	public var affiliations : xmpp.pubsub.Affiliations;
	public var _default : { form : xmpp.DataForm, empty : Bool };
	
	public function new() {}
	
	public function toXml() {
		var x = Xml.createElement( "pubsub" );
		x.set( "xmlns", XMLNS );
		if( delete != null ) {
			var e = Xml.createElement( "delete" );
			if( delete != "" ) e.set( "node", delete );
			x.addChild( e );
			return x;
		}
		if( purge != null ) {
			var e = Xml.createElement( "purge" );
			e.set( "node", purge );
			x.addChild( e );
			return x;
		}
		if( configure != null ) {
			var e = Xml.createElement( "configure" );
			if( configure.node != null ) e.set( "node", configure.node );
			e.addChild( configure.form.toXml() );
			x.addChild( e );
			return x;
		}
		if( subscriptions != null ) {
			x.addChild( subscriptions.toXml() );
			return x;
		}
		if( affiliations != null ) {
			x.addChild( affiliations.toXml() );
			return x;
		}
		if( _default != null ) {
			var e = Xml.createElement( "default" );
			if( !_default.empty && _default.form != null )
				e.addChild( _default.form.toXml() );
			return x;
		}
		return x;
	}
	
	public static function parse( x : Xml ) : PubSubOwner {
		var p = new PubSubOwner();
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "delete" :
				p.delete = e.get( "node" );
			case "purge" :
				p.purge = e.get( "node" );
			case "configure" :
				var _f = e.elementsNamed( "x" ).next();
				p.configure = { form : ( _f != null ) ? xmpp.DataForm.parse( _f ) : null,
								node : e.get( "node" ) };
			case "subscriptions" :
				p.subscriptions = xmpp.pubsub.Subscriptions.parse( e );
			case "affiliations" :
				p.affiliations = xmpp.pubsub.Affiliations.parse( e );
			case "default" :
				var _f = e.elementsNamed( "x" ).next();
				p._default = { form : ( _f != null ) ? xmpp.DataForm.parse( _f ) : null,
							   empty : ( _f != null ) ? false : true };
			}
		}
		return p;
	}
	
}
