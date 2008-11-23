package error;


class AbstractError extends Exception {
	
	public function new( ?desc : String, ?info : haxe.PosInfos ) {
		var d = "Abstract error";
		if( desc != null ) d += ": "+desc; 
		super( d, info );
	}
	
}
