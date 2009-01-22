package xmpp;


/**
	<a href="http://xmpp.org/extensions/xep-0082.html">XMPP Date and Time Profiles</a>
*/
class Date {
	
	/**
	*/
	public static function isValid( t : String ) : Bool {
		//TODO !! regexp
		return true;
	}
	
	/**
		Formats a (regular) date string to a xmpp compatible date string (CCYY-MM-DDThh:mm:ss[.sss]TZD)<br>
		For example: 2008-11-01 18:45:47 gets 2008-11-01T18:45:47Z<br>
		Optionally a timezone offset could be attached.<br>
		
		// TODO seconds.
	*/
	public static function format( t : String, ?offset : Null<Int> ) : String {
		if( !isValid( t ) ) return null;
		var k = t.split( " " );
		if( k.length == 1 ) return t;
		var b = new StringBuf();
		b.add( k[0] );
		b.add( "T" );
		b.add( k[1] );
		return if( offset == null ) {
			b.add( "Z" );
			b.toString();
		} else {
			b.add( "-" );
			b.add( if( offset > 9 ) Std.string( offset ) else ("0"+offset) );
			b.add( ":00" );
			b.toString();
		}
	}
	
}
