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

import xmpp.dataform.FieldType;
import xmpp.lop.Bindings;
import xmpp.lop.Ping;
import xmpp.lop.SpawnVM;
import xmpp.lop.Submit;

/**
	Manages the spawning of virtual machines.
	The disco 'identity' of a farm MUST be of category="client" and type="bot" (name is up to the implementation).
	
	<a href="http://xmpp.org/extensions/inbox/lop.html">Linked Process Protocol</a>
	<a href="http://linkedprocess.org">Linked Process Website</a>
*/
class Farm {
	
	public dynamic function onJob( job : Submit ) : String { return "no LOP job handler specified"; }
	public dynamic function onVMKill( id : String ) {}
	public dynamic function onPing( ping : Ping ) : String { return null; }
	public dynamic function onSetBindings( bindings : Bindings ) {}
	public dynamic function onGetBindings( bindings : Bindings ) : Bindings { return null; }
	
	public var stream(default,null) : jabber.Stream;
	public var species(default,null) : Map<String,jabber.JID->SpawnVM->String>;
	public var password(default,null) : String;
	
	public var ip : String;
	public var vm_species : String;
	public var vm_time_to_live : Float;
	public var job_timeout : Float;
	public var job_queue_capacity : Null<Int>;
	public var max_concurrent_vms : Null<Int>;
	public var farm_start_time : String;
	public var read_file : Array<String>;
	public var write_file : Array<String>;
	public var delete_file : Array<String>;
	public var open_connection : Null<Bool>;
	public var listen_for_connection : Null<Bool>;
	public var accept_connection : Null<Bool>;
	public var perform_multicast : Null<Bool>;
	
	public function new( stream : jabber.Stream,
						 ?password : String,
						 vm_species : String = "unknown",
						 vm_time_to_live : Float = 1.0,
						 job_timeout : Float = 1.0 ) {
		
		this.stream = stream;
		stream.features.add( xmpp.LOP.XMLNS );
		this.password = password;
		this.vm_species = vm_species;
		this.vm_time_to_live = vm_time_to_live;
		this.job_timeout = job_timeout;
		this.farm_start_time = xmpp.DateTime.now();
		this.read_file = new Array();
		this.write_file = new Array();
		this.delete_file = new Array();
		
		//open_connection = listen_for_connection = accept_connection = perform_multicast = false;
		species = new Map();
		stream.collect( [ new xmpp.filter.IQFilter(xmpp.LOP.XMLNS,null) ], handleIQ, true );
	}
	
	/**
	*/
	public function handleIQ( iq : xmpp.IQ ) {
		switch( iq.x.toXml().nodeName ) {
		case "spawn_vm" :
			var spawn = SpawnVM.parse( iq.x.toXml() );
			if( !species.exists( spawn.species ) ) {
				var err = new xmpp.Error( xmpp.ErrorType.cancel, "'"+spawn.species+"' is a unsupported virtual machine", 503 );
//TODO			err.conditions.push( Xml.parse( '<species_not_supported xmlns="http://linkedprocess.org/2009/06/Farm#"/>' ) );
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
				var err = new xmpp.Error( xmpp.ErrorType.modify, e, 400 );
				err.app = { condition : "evaluation_error", xmlns : "http://linkedprocess.org/2009/06/Farm#" };
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
			onVMKill( iq.x.toXml().get( "vm_id" ) );
			var r = xmpp.IQ.createResult( iq );
			r.x = iq.x;
			stream.sendPacket( r );
		}
	}
	
	/**
		Generate a dataform of this farms settings.
	*/
	public function getDataForm() : xmpp.DataForm {
		var f = new xmpp.DataForm( xmpp.dataform.FormType.result ); //?
		f.fields.push( createFormField( "farm_password", Std.string( password != null ), FieldType.boolean ) );
		if( ip != null ) f.fields.push( createFormField( "ip_address", ip, FieldType.list_single ) );
		f.fields.push( createFormField( "vm_species", vm_species, FieldType.list_single ) );
		f.fields.push( createFormField( "vm_time_to_live", Std.string( vm_time_to_live ), FieldType.list_single ) );
		f.fields.push( createFormField( "job_timeout", Std.string( job_timeout ), FieldType.text_single ) );
		if( job_queue_capacity != null ) f.fields.push( createFormField( "job_queue_capacity", Std.string( job_queue_capacity ), FieldType.text_single ) );
		if( max_concurrent_vms != null ) f.fields.push( createFormField( "max_concurrent_vms", Std.string( max_concurrent_vms ),  FieldType.text_single ) );
		if( farm_start_time != null ) f.fields.push( createFormField( "farm_start_time", farm_start_time, FieldType.text_single ) );
		if( read_file != null && read_file.length > 0 ) f.fields.push( createFormFieldMulti( "read_file", read_file ) );
		if( write_file != null && write_file.length > 0 ) f.fields.push( createFormFieldMulti( "write_file", write_file ) );
		if( delete_file != null && delete_file.length > 0 ) f.fields.push( createFormFieldMulti( "delete_file", delete_file ) );
		if( open_connection != null ) f.fields.push( createFormField( "open_connection", Std.string( open_connection ), FieldType.boolean ) );
		if( listen_for_connection != null ) f.fields.push( createFormField( "listen_for_connection", Std.string( listen_for_connection ), FieldType.boolean ) );
		if( accept_connection != null ) f.fields.push( createFormField( "accept_connection", Std.string( accept_connection ), FieldType.boolean ) );
		if( perform_multicast != null ) f.fields.push( createFormField( "perform_multicast", Std.string( perform_multicast ), FieldType.boolean ) );
		return f;
	}
	
	static function createFormField( name : String, value : String, type : FieldType ) : xmpp.dataform.Field {
		var f = new xmpp.dataform.Field( type );
		f.variable = name;
		f.values.push( value );
		return f;
	}
	
	static function createFormFieldMulti( name : String, values : Iterable<String> ) : xmpp.dataform.Field {
		var f = new xmpp.dataform.Field( FieldType.list_multi );
		f.variable = name;
		for( v in values ) f.values.push( v );
		return f;
	}
	
}
