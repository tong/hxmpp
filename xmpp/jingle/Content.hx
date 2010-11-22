package xmpp.jingle;

class Content {
	
	public var creator : Creator;
	public var name : String;
	public var disposition : String;
	public var senders : Senders;
	public var other : Array<Xml>;
	
	public function new( creator : Creator, name : String,
						 ?disposition : String, ?senders : Senders ) {
		this.creator = creator;
		this.name = name;
		this.disposition = disposition;
		this.senders = senders;
		other = new Array();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "content" );
		x.set( "creator", Type.enumConstructor( creator ) );
		x.set( "name", name );
		if( disposition != null ) x.set( "disposition", disposition );
		if( senders != null ) x.set( "senders", Type.enumConstructor( senders ) );
		for( e in other ) x.addChild( e );
		return x;
	}
	
	public static function parse( x : Xml ) : Content {
		var c = new Content( Type.createEnum( Creator, x.get( "creator" ) ),
							 x.get( "name" ),
							 x.get( "disposition" ),
							 x.exists( "senders" ) ? Type.createEnum( Senders, x.get( "senders" ) ) : null );
		//TODO
		/*
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "transport" :
				//TODO
			default : c.other.push( e );
			}
		}
		*/
		c.other = Lambda.array( x );
		return c;
	}
	
}
