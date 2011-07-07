/*
 *	This file is part of HXMPP.
 *	Copyright (c)2010 http://www.disktree.net
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
package jabber.lop;

import xmpp.lop.Bindings;
import xmpp.lop.Ping;
import xmpp.lop.SpawnVM;
import xmpp.lop.Submit;
import xmpp.lop.Terminate;

/**
	Communicates with a resource provider's farm in order to spawn and compute with virtual machines that leverage provided resources.
	<a href="http://xmpp.org/extensions/inbox/lop.html">Linked Process Protocol</a><br/>
	<a href="http://linkedprocess.org">Linked Process Website</a><br/>
*/
class Villein {
	
	public dynamic function onSpawn( s : SpawnVM ) {}
	public dynamic function onResult( job : Submit ) {}
	public dynamic function onFail( id : String, e : xmpp.Error ) {}
	public dynamic function onTerminate( vm : String ) {}
	public dynamic function onTerminateFail( id : String, e : xmpp.Error ) {}
	public dynamic function onBind( bindings : Bindings ) {}
	public dynamic function onBindFail( id : String, e : xmpp.Error ) {}
	public dynamic function onVariables( bindings : Bindings ) {}
	public dynamic function onVariablesFail( id : String, e : xmpp.Error ) {}
	
	/** The jid of the farm */
	public var farm(default,null) : String;
	public var stream(default,null) : jabber.Stream;

	public function new( stream : jabber.Stream, farm : String ) {
		this.stream = stream;
		this.farm = farm;
	}
	
	/**
	*/
	public function spawnVM( species : String, ?password : String ) {
		var iq = new xmpp.IQ( null, null, farm );
		iq.x = new SpawnVM( species );
		stream.sendIQ( iq, handleVMSpawn );
	}
	
	/**
	*/
	public function submitJob( id : String, job : String ) : String {
		var iq = new xmpp.IQ( null, null, farm );
		iq.x = new Submit( id, job );
		stream.sendIQ( iq, handleJob );
		return null; //TODO generate job id
	}
	
	/**
	*/
	public function pingJob( vm_id : String, job_id : String ) {
		//TODO check
		var iq = new xmpp.IQ( null, null, farm );
		iq.x = new Ping( vm_id, job_id );
		stream.sendIQ( iq, handlePing );
	}
	
	//TODO
	/**
	*/
	public function abortJob() {
	}
	
	//TODO
	/**
	*/
	public function getBindings( id : String, names : Iterable<String> ) {
		var iq = new xmpp.IQ( null, null, farm );
		var l = new Bindings( id );
		for( n in names ) l.add( cast { name : n } );
		iq.x = l;
		stream.sendIQ( iq, handleGetBindings );
	}
	
	//TODO
	/**
	*/
	public function setBindings( id : String, list : Iterable<xmpp.lop.Binding> ) {
		var iq = new xmpp.IQ( xmpp.IQType.set, null, farm );
		if( Std.is( list, Bindings ) ) iq.x = cast list;
		else {
			var l = new Bindings( id );
			for( b in list ) l.add( b );
			iq.x = l;
		}
		stream.sendIQ( iq, handleSetBindings );
	}
	
	/**
	*/
	public function terminateVM( vm_id : String ) {
		var iq = new xmpp.IQ( null, null, farm );
		iq.x = new Terminate( vm_id );
		stream.sendIQ( iq, handleTerminate );
	}
	
	function handleVMSpawn( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			var s = SpawnVM.parse( iq.x.toXml() );
			onSpawn( s );
		case error :
		default :
		}
	}
	
	function handleJob( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			var job = Submit.parse( iq.x.toXml() );
			onResult( job );
		case error :
			var id = Submit.parse( iq.x.toXml() ).id;
			onFail( id, iq.errors[0] );
		default :
		}
	}
	
	//TODO
	function handlePing( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			trace("######################PING RESULT");
			//onPing();
		case error :
			//..
		default :
		}
	}
	
	function handleTerminate( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			var id = Terminate.parse( iq.x.toXml() ).vm_id;
			onTerminate( id );
		case error :
			var id = Terminate.parse( iq.x.toXml() ).vm_id;
			onTerminateFail( id, iq.errors[0] );
		default :
		}
	}
	
	function handleGetBindings( iq : xmpp.IQ ) {
		trace("handleGetBindings");
		switch( iq.type ) {
		case result :
			onVariables( Bindings.parse( iq.x.toXml() ) );
		case error :
			var id = Bindings.parse( iq.x.toXml() ).vm_id;
			onVariablesFail( id, iq.errors[0] );
		default :
		}
	}
	
	function handleSetBindings( iq : xmpp.IQ ) {
		trace("handleSetBindings");
		switch( iq.type ) {
		case result :
			onBind( Bindings.parse( iq.x.toXml() ) );
		case error :
			var id = Bindings.parse( iq.x.toXml() ).vm_id;
			onBindFail( id, iq.errors[0] );
		default :
		}
	}
	
}
