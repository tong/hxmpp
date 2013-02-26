/*
 * Copyright (c) 2012, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package jabber.lop;

import xmpp.lop.Bindings;
import xmpp.lop.Ping;
import xmpp.lop.SpawnVM;
import xmpp.lop.Submit;
import xmpp.lop.Terminate;

/**
	Communicates with a resource provider's farm in order to spawn and compute with virtual machines that leverage provided resources.<br/>
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
