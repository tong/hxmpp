/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009-2010 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package;

import flash.external.ExternalInterface;
import tls.controller.SecureSocket;
import tls.event.SecureSocketEvent;
import tls.valueobject.SecurityOptionsVO;

private class Socket extends SecureSocket {
	public var id(default,null) : UInt;
	public function new( id : UInt ) {
		super();
		this.id = id;
	}
}

/**
	Secure flash socketbridge.
*/
class FlashSecureSocketBridge {
	
	var ctx : String;
	var sockets : IntHash<Socket>;
	
	function new( ?ctx : String ) {
		this.ctx = ( ctx != null ) ? ctx : "jabber.SocketBridgeConnection";
		init();
	}
	
	function init() {
		if( ExternalInterface.available ) {
			ExternalInterface.addCallback( "createSocket", createSocket );
			ExternalInterface.addCallback( "destroySocket", destroySocket );
			ExternalInterface.addCallback( "connect", connect );
			ExternalInterface.addCallback( "disconnect", disconnect );
			//ExternalInterface.addCallback( "destroy", destroy );
			//ExternalInterface.addCallback( "destroyAll", destroyAll );
			ExternalInterface.addCallback( "send", send );
		} else {
			throw "Unable to initialize external connection on socket bridge";
		}
		sockets = new IntHash();
	}
	
	function createSocket( ?secure : Bool = true ) : Int {
		var id = Lambda.count( sockets );
		var s = new Socket( id );
		s.addEventListener( SecureSocketEvent.ON_CONNECT, sockConnectHandler );
		s.addEventListener( SecureSocketEvent.ON_SECURE_CHANNEL_ESTABLISHED, sockSecuredHandler );
		s.addEventListener( SecureSocketEvent.ON_CLOSE, sockDisconnectHandler );
		s.addEventListener( SecureSocketEvent.ON_ERROR, sockErrorHandler );
		s.addEventListener( SecureSocketEvent.ON_PROCESSED_DATA, sockDataHandler );
		sockets.set( id, s );
		return id;
	}
	
	function destroySocket( id : Int ) : Bool {
		if( !sockets.exists( id ) )
			return false;
		var s = sockets.get( id );
		//if( s.connected ) s.close();
		try { s.close(); } catch( e : Dynamic ) {}
		sockets.remove( s.id );
		s = null;
		return true;
	}
	
	function connect( id : Int, host : String, port : Int,
					  ?timeout : Int = -1 ) : Bool {
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
	
	function send( id : Int, data : String ) : Bool {
		if( !sockets.exists( id ) )
			return false;
		var s = sockets.get( id );
		s.sendString( data ); 
		//s.flush();
		return true;
	}
	
	
	function sockConnectHandler( e : SecureSocketEvent ) {
		e.target.startSecureSupport( SecurityOptionsVO.getDefaultOptions( SecurityOptionsVO.SECURITY_TYPE_TLS ) );
	}

	function sockSecuredHandler( e : SecureSocketEvent ) {
		ExternalInterface.call( ctx+".handleConnect", e.target.id );
	}
	
	function sockDisconnectHandler( e : SecureSocketEvent ) {
		ExternalInterface.call( ctx+".handleDisconnect", e.target.id );
	}
	
	function sockErrorHandler( e : SecureSocketEvent ) {
		ExternalInterface.call( ctx+".handleError", e.target.id, e.type );
	}
	
	function sockDataHandler( e : SecureSocketEvent ) {
		ExternalInterface.call( ctx+".handleData", e.target.id, e.rawData.toString() );
	}
	
	static function main() {
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		var cm = new flash.ui.ContextMenu();
		cm.hideBuiltInItems();
		flash.Lib.current.contextMenu = cm;
		new FlashSecureSocketBridge( flash.Lib.current.loaderInfo.parameters.ctx );
	}
	
}
