package error;


class SocketConnectionError extends error.Exception {
	
	public function new( ?desc : String, ?info : haxe.PosInfos ) {
		var d = "Socket connection error";
		if( desc != null ) d += ": "+desc; 
		super( d, info );
	}
	
}
