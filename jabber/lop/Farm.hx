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

//TODO support all service discovery dataform fearures  http://xmpp.org/extensions/inbox/lop.html#sect-id2257047

/**
	Manages the spawning of virtual machines.

	<a href="http://xmpp.org/extensions/inbox/lop.html">Linked Process Protocol</a>
	<a href="http://linkedprocess.org">Linked Process Website</a>
*/
class Farm {
	
	public dynamic function onJob( job : Submit ) : String { return throw "No LOP job handler specified"; }
	public dynamic function onKillVM( id : String ) : Void;
	public dynamic function onPing( ping : Ping ) : String { return null; }
	public dynamic function onSetBindings( bindings : Bindings ) : Void;
	public dynamic function onGetBindings( bindings : Bindings ) : Bindings { return null; }
	
	public var stream(default,null) : jabber.Stream;
	public var species(default,null) : Hash<jabber.JID->SpawnVM->String>;
	public var password(default,null) : String;
	//public var config(default,null) : FarmConfig;
	/*
	public var hasPassword : Bool;
	public var ip : String;
	public var timeToLive : Int;
	public var jobTimeout : Int;
	public var jobQueueCapacity : Int;
	public var maxConcurrentVMs : Int;
	public var startTime : Int;
	public var readFile : List<String>;
	public var writeFile : List<String>;
	public var deleteFile : List<String>;
	public var openConnection : Bool;
	public var listenConnection : Bool;
	public var acceptConnection : Bool;
	public var performConnection : Bool;
	*/
	
	//public function new( stream : jabber.Stream, ?config : FarmConfig ) {
	public function new( stream : jabber.Stream, ?password : String ) {
		if( !stream.features.add( xmpp.EntityTime.XMLNS ) )
			throw "LOP farm listener already added";
		this.stream = stream;
		this.password = password; 
		species = new Hash();
		stream.collect( [ cast new xmpp.filter.IQFilter( xmpp.LOP.XMLNS, null ) ], handleIQ, true );
		
		//TODO relay service discovery somehow (to return the dataform)
	}
	
	/**
	*/
	public function handleIQ( iq : xmpp.IQ ) {
		switch( iq.x.toXml().nodeName ) {
		case "spawn_vm" :
			var spawn = SpawnVM.parse( iq.x.toXml() );
			if( !species.exists( spawn.species ) ) {
				var err = new xmpp.Error( xmpp.ErrorType.cancel, 503, "'"+spawn.species+"' is a unsupported virtual machine" );
				err.conditions.push( Xml.parse( '<species_not_supported xmlns="http://linkedprocess.org/2009/06/Farm#"/>' ) );
				var r = xmpp.IQ.createError( iq, [err] );
				spawn.species = null; // XMPP error (?), TODO report to XEP author
				r.properties.push( spawn.toXml() );
				stream.sendPacket( r );
			} else {
				if( this.password != null ) {
					//TODO
				}
				var jid = new jabber.JID( iq.from );
				var spawn_handler = species.get( spawn.species );
				spawn.id = spawn_handler( jid, spawn );
				var r = xmpp.IQ.createResult( iq );
				r.x = spawn;
				stream.sendPacket( r );
			}
			
		case "submit_job" :
			var job = Submit.parse( iq.x.toXml() );
			var result : String = null;
			try {
				result = onJob( job );
			} catch( e : Dynamic ) {
				var err = new xmpp.Error( xmpp.ErrorType.modify, 400, e, [Xml.parse('<evaluation_error xmlns="http://linkedprocess.org/2009/06/Farm#"/>')]);
				var r = xmpp.IQ.createError( iq, [err] );
				job.code = null;
				r.x = job;
				stream.sendPacket( r );
				return;
			}
			job.code = result;
			var r = xmpp.IQ.createResult( iq );
			r.x = job;
			stream.sendPacket( r );
		
		case "ping_job" :
			//TODO
			var p = Ping.parse( iq.x.toXml() );
			var s : String = null;
			try {
				s = onPing( p );
			} catch( e : Dynamic ) {
				trace(e);
				//TODO
				//var err =
				//var r = xmpp.IQ.createError( iq );
				//..
				return;
			}
			p.status = s;
			var r = xmpp.IQ.createResult( iq );
			r.x = p;
			stream.sendPacket( r );
			
		case "manage_bindings" :
			//TODO
			var bindings = Bindings.parse( iq.x.toXml() );
			switch( iq.type ) {
			case get :
				var r = xmpp.IQ.createResult( iq );
				//var b = onGetBindings( bindings );
				//try {
				r.x = onGetBindings( bindings );//new xmpp.lop.Bindings( bindings.vm_id );
				stream.sendPacket( r );
			case set :
				onSetBindings( bindings );
				var r = xmpp.IQ.createResult( iq );
				//try {
				r.x = new Bindings( bindings.vm_id );
				stream.sendPacket( r );
			default :
			}
			
		case "terminate_vm" :
			//onKillVM( xmpp.lop.Terminate.parse( iq.x.toXml() ).vm_id );
			onKillVM( iq.x.toXml().get( "vm_id" ) );
			var r = xmpp.IQ.createResult( iq );
			r.x = iq.x;
			stream.sendPacket( r );
		}
	}
	
}
