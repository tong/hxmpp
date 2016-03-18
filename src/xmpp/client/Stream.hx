package xmpp.client;

enum State {
    header;
    features( f : Map<String,Xml> );
    starttls;
    open;
	restart;
}

class Stream extends xmpp.Stream {

	public static inline var XMLNS = 'jabber:client';
    public static inline var PORT = 5222;

	public dynamic function onStartTLS( proceed : Void->Void ) {}

	public var jid(default,null) : JID;
	public var state(default,null) : State;
    public var serverFeatures(default,null) : Map<String,Xml>;
    public var starttls(default,null) : Bool;
    public var encrypted(default,null) = false;

	var onRestart : Void->Void;

	public function new( jid : JID, starttls = true, ?lang : String ) {
        super( XMLNS, lang );
        this.jid = jid;
        this.starttls = starttls;
    }

	public override function open() {
		send( xmpp.Stream.createInitElement( xmlns, jid.domain, true, lang ) );
		state = State.header;
	}

	public function restart( callback : Void->Void ) {
        onRestart = callback;
		send( xmpp.Stream.createInitElement( xmlns, jid.domain, true, lang ) );
		state = State.restart;
	}

	override function _receive( str : String ) : Bool {
		switch state {
		case header:
			var header = xmpp.Stream.readHeader( str );
			id = header.id;
			//if( header.id == null )
			var features = xmpp.Stream.readFeatures( str );
			state = State.features( features );
			if( features != null ) _receive( null );
		case features(f):
			if( f == null ) f = xmpp.Stream.readFeatures( str );
			serverFeatures = f;
			if( starttls && serverFeatures.exists( 'starttls' ) ) {
				send( '<starttls xmlns="urn:ietf:params:xml:ns:xmpp-tls"/>' );
				state = State.starttls;
			} else {
				buf = new StringBuf();
				state = State.open;
				onReady();
			}
		case starttls:
			var xml = try XML.parse( str ) catch(e:Dynamic) {
				trace( e );
				//TODO close stream
				return false;
			}
			switch xml.name {
			case 'proceed':
				buf = new StringBuf();
				onStartTLS( function(){
					encrypted = true;
				});
			case 'failure':
				trace("TODO starttls failed");
			}

		case open:
			var xml : XML = null;
			try xml = XML.parse( str ) catch(e:Dynamic) {
				trace( "TODO stanza incomplete" );
				//TODO close stream
				return false;
			}
			buf = new StringBuf();
			receiveXml( xml );
		case restart:
			serverFeatures = xmpp.Stream.readFeatures( str );
			buf = new StringBuf();
			state = State.open;
			onRestart();
		}
		return true;
	}
}
