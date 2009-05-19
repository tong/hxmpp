package jabber.tool;

#if flash9
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;
import flash.external.ExternalInterface;


private class Socket extends flash.net.Socket {
	public var id(default,null) : UInt;
	public function new( id : UInt ) {
		super();
		this.id = id;
	}
}

/**
*/
class SocketBridge {
	
	static var defaultBridgeContext = "jabber.SocketBridgeConnection";
	
	var ctx : String;
	var sockets : IntHash<Socket>;
	
	function new( ctx : String ) {
		
		this.ctx = ( ctx != null ) ? ctx : defaultBridgeContext;
		
		sockets = new IntHash();
		
		if( ExternalInterface.available ) {
			try {
				ExternalInterface.addCallback( "createSocket", createSocket );
				ExternalInterface.addCallback( "destroySocket", destroySocket );
				ExternalInterface.addCallback( "connect", connect );
				ExternalInterface.addCallback( "disconnect", disconnect );
				//ExternalInterface.addCallback( "destroy", destroy );
				ExternalInterface.addCallback( "send", send );
			} catch( e : Dynamic ) {
				trace( e );
				throw e;
			}
		}
	}
	
	/*
	function init( ctx : String ) : Bool {
		this.ctx = ctx;
		return true;
	}*/
	
	function createSocket() : Int {
		var id = Lambda.count( sockets );
		var s = new Socket( id );
		s.addEventListener( Event.CONNECT, sockConnectHandler );
		s.addEventListener( Event.CLOSE, sockDisconnectHandler );
		s.addEventListener( IOErrorEvent.IO_ERROR, sockErrorHandler );
		s.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockErrorHandler );
		s.addEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
		sockets.set( id, s );
		return id;
	}
	
	function destroySocket( id : Int ) : Bool {
		if( !sockets.exists( id ) )
			return false;
		var s = sockets.get( id );
		if( s.connected ) s.close();
		sockets.remove( s.id );
		s = null;
		return true;
	}
	
	function connect( id : Int, host : String, port : Int, ?timeout : Int = -1 ) : Bool {
		#if flash10 if( timeout > 0 ) s.timeout = timeout; #end
		if( !sockets.exists( id ) )
			return false;
		var s = sockets.get( id );
		s.connect( host, port );
		return true;
	}
	
	function disconnect( id : Int ) : Bool {
		if( !sockets.exists( id ) )
			return false;
		var s = sockets.get( id );
		s.close();
		return true;
	}
	
	/*
	function destroy( id : Int ) : Bool {
		trace("SOCKETBRIDGE destroy: "+id );
		if( !sockets.exists( id ) )
			return false;
		var s = sockets.get( id );
		//s.close();
		if( s.connected ) s.close();
		sockets.remove( id );
		s = null;
		return true;
	}
	*/
	
	function send( id : Int, data : String ) : Bool {
		if( !sockets.exists( id ) )
			return false;
		var s = sockets.get( id );
		s.writeUTFBytes( data ); 
		s.flush();
		return true;
	}
	
	function sockConnectHandler( e : Event ) {
		ExternalInterface.call( ctx+".handleConnect", e.target.id );
	}

	function sockDisconnectHandler( e : Event ) {
		ExternalInterface.call( ctx+".handleDisconnect", e.target.id );
	}
	
	function sockErrorHandler( e ) {
		ExternalInterface.call( ctx+".handleError", e.target.id, e.type );
	}
	
	function sockDataHandler( e : ProgressEvent ) {
		ExternalInterface.call( ctx+".handleData", e.target.id, e.target.readUTFBytes( e.bytesLoaded ) );
	}
	
	
	static function main() {
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		var cm = new flash.ui.ContextMenu();
		cm.hideBuiltInItems();
		flash.Lib.current.contextMenu = cm;
		new SocketBridge( flash.Lib.current.loaderInfo.parameters.ctx );
	}
	
}

#end // flash9
