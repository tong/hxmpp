package xmpp;


/**
	<a href="http://xmpp.org/extensions/xep-0082.html">XMPP Date and Time Profiles</a>
	
	//TODO check seconds.
*/
class Date {
	
	/*
		Formats a (regular) date string to a xmpp compatible date string.
		CCYY-MM-DDThh:mm:ss[.sss]TZD
		For example: 2008-11-01 18:45:47 gets 2008-11-01T18:45:47Z
		Optionally a timezone offset could be attached.
	*/
	public static function format( s : String, ?offset : Null<Int> ) : String {
		var k = s.split( " " );
		if( k.length == 1 ) return s;
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
