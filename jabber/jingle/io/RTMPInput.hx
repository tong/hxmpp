package jabber.jingle.io;

class RTMPInput extends RTMPTransport {
	
	public override function init() {
		ns.play( "#"+id );
	}
	
	public static inline function ofCandidate( x : Xml ) {
		return new RTMPInput( x.get( "id" ), x.get( "host" ), Std.parseInt( x.get( "port" ) ), x.get( "name" ) );
	}
	
}
