package xmpp.muc;


class Invite extends Decline {
	
	public function new( ?reason : String, ?to : String, ?from : String ) {
		super( reason, to, from );
		nodeName = "invite";
	}
	
	//TODO public static function parse( x : Xml ) :  {
	
}
