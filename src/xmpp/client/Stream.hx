package xmpp.client;

enum State {
    header;
    features;
    open;
	restart;
}

class Stream extends xmpp.Stream {

	public static inline var XMLNS = "jabber:client";
    public static inline var PORT = 5222;

	public var jid(default,null) : JID;
    public var serverFeatures(default,null) : Map<String,Xml>;
    public var state(default,null) : State;

	var onRestart : Void->Void;

	public function new( jid : JID, ?lang : String ) {
        super( XMLNS, lang );
        this.jid = jid;
    }

	public function restart( callback : Void->Void ) {
        onRestart = callback;
		sendHeader();
		state = State.restart;
	}

	override function _receive( str : String ) : Bool {
		switch state {
		case header:
			var header = xmpp.Stream.readHeader( str );
			id = header.id;
			var features = xmpp.Stream.readFeatures( str );
			if( features != null ) {
				serverFeatures = features;
				buf = new StringBuf();
				state = State.open;
				onReady();
			} else
				state = State.features;
		case features:
			serverFeatures = xmpp.Stream.readFeatures( str );
			buf = new StringBuf();
			state = State.open;
			onReady();
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

	//function handleOpen( fun : Void->Void ) {

	override function sendHeader() {
		sendString( xmpp.Stream.createInitElement( xmlns, jid.domain, true, lang ) );
		state = header;
	}
}
