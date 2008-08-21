
import jabber.JID;
import jabber.StreamSocketConnection;
import jabber.component.Stream;



/**
*/
class ComponentDemo {
	
	static function main() {
		
		jabber.tool.XMPPDebug.setRedirection();
		
		#if flash9
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
		
		var component = new ComponentDemo();
	}
	
	
	var stream : Stream;
	
	
	function new() {
		stream = new CustomStream( "norc", "disktree", "1234", "127.0.0.1" );
		stream.onOpen.addHandler( onStreamOpen );
		stream.open();
	}
	
	
	function onStreamOpen( s ) {
		trace("###############################");
	}
}



private class CustomStream extends jabber.component.Stream {
	
	
	public function new( name : String, host : String, password : String,  ?manualHost : String, ?manualPort : Int ) {
		super( name, password,
			   new StreamSocketConnection( manualHost != null ? manualHost : host, manualPort != null ? manualPort : Stream.DEFAULT_PORT  ) );
	}
	
	
	override function onData( data : String ) {
		trace( data, false );
		super.onData( data );
	}
	
	override public function sendData( data : String ) : Bool {
		trace( data, true );
		return super.sendData( data );
	}
	
}
