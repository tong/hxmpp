package jabber.error;

class AbstractError extends Error {
	
	public function new( ?desc : String, ?info : haxe.PosInfos ) {
		var d = "Abstract error";
		if( desc != null ) d += ": "+desc; 
		super( d, info );
	}
	
}
