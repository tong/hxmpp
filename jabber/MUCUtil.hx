package jabber;

/**
	Static methods for manipulation/validation of mutliuser chat addresses.
*/
class MUCUtil {
	
	public static var EREG = ~/[A-Z0-9._%-]+@[A-Z0-9.-]+(\/[A-Z0-9._%-]+)?/i;
	public static var EREG_FULL = ~/[A-Z0-9._%-]+@[A-Z0-9.-]+\/[A-Z0-9._%-]+/i;
	
	/**
		Returns Bool if the given string is a valid muchat address.
	*/
	public static function isValid( t : String ) : Bool {
		return EREG.match( t );
	}
	
	/**
		Returns Bool if the given string is a full valid muchat address (including occupant name).
	*/
	public static function isValidFull( t : String ) : Bool {
		return EREG_FULL.match( t );
	}
	
	/**
		Returns the room of the muc jid.
	*/
	public static function getRoom( t : String ) : String {
		return JIDUtil.parseNode( t );
	}
	
	/**
		Returns the host of the muc jid.
	*/
	public static function getHost( t : String ) : String {
		return getParts( t )[1];
	}
	
	/**
		Returns the occupant name of the muc jid.
	*/
	public static function getOccupant( t : String ) : String {
		var i = t.indexOf( "/" );
		return ( i == -1 ) ? null : t.substr( i+1 );
	}
	
	/**
		Returns array existing of roomname[0], host[1] and (optional) occupantname[2] of the given muc address.
	*/
	public static function getParts( t : String ) : Array<String> {
		var i1 = t.indexOf( "@" );
		var i2 = t.indexOf( "/" );
		return if( i2 == -1 ) [ t.substr( 0, i1 ), t.substr( i1+1 ) ];
		else [ t.substr( 0, i1 ), t.substr( i1+1, i2-i1-1 ), t.substr( i2+1 ) ];
	}
	
}
