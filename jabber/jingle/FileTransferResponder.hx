package jabber.jingle;

import haxe.io.Bytes;
import jabber.jingle.io.ByteStreamInput;

class FileTransferResponder extends SessionResponder<ByteStreamInput> {
	
	public dynamic function onProgress( data : Bytes ) : Void;
	public dynamic function onComplete() : Void;
	
	public var filename(default,null) : String;
	public var filedate(default,null) : String;
	public var filesize(default,null) : Int;
	
	public function new( stream : jabber.Stream ) {
		super( stream, xmpp.Jingle.XMLNS_S5B );
	}
	
	override function parseDescription( x : Xml ) {
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "offer" :
				for( e in e.elements() ) {
					switch( e.nodeName ) {
					case "file" :
						filename = e.get( "name" );
						filedate = e.get( "date" );
						filesize = Std.parseInt( e.get( "size" ) );
					}
				}
			}
		}
	}
	
	override function handleTransportConnect() {
		transport.__onProgress = onProgress;
		transport.__onComplete = onComplete;
		super.handleTransportConnect();
		transport.read();
	}
	
	override function addTransportCandidate( x : Xml ) {
		candidates.push( new ByteStreamInput( x.get( "host" ), Std.parseInt( x.get( "port" ) ), filesize ) );
	}
	
}
