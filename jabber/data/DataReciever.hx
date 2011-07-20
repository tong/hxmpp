/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
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
package jabber.data;

import haxe.io.Bytes;
import xmpp.IQ;

/**
	Abstract, incoming data transfer handler.
*/
class DataReciever {
	
	//public dynamic function onInit() {}
	public dynamic function onProgress( bytes : Bytes ) {}
	public dynamic function onComplete() {}
	public dynamic function onFail( info : String ) {}
	
	public var stream(default,null) : jabber.Stream;
	public var xmlns(default,null) : String;
	public var initiator(default,null) : String;
	public var file(default,null) : xmpp.file.File;
	public var range(default,null) : xmpp.file.Range;
	
	var request : IQ;
	var sid : String;
	
	function new( stream : jabber.Stream, xmlns : String ) {
		this.stream = stream;
		this.xmlns = xmlns;
		stream.features.add( xmlns );
	}
	
	public function init( file : xmpp.file.File, request : IQ, sid : String ) {
		this.file = file;
		this.request = request;
		this.sid = sid;
		initiator = request.from;
	}
	
	/**
		Accept/deny the data transfer
	*/
	public function accept( yes : Bool, ?range : xmpp.file.Range ) {
		// override me
	}
	
	function _accept( yes : Bool, ename : String, ?range : xmpp.file.Range ) {
		this.range = range;
		if( yes ) sendAccept( xmlns, ename ) else sendDeny();
	}
	
	function sendDeny() {
		var r = IQ.createError( request );
		r.errors.push( new xmpp.Error( xmpp.ErrorType.auth, "not-acceptable" ) );
		stream.sendPacket( r );
	}
	
	function sendAccept( xmlns : String, xname : String ) {
		var r = IQ.createResult( request );
		var si = new xmpp.file.SI();
		var file = new xmpp.file.File( null, null );
		file.range = range;
		si.any.push( file.toXml() );
		var feature = Xml.createElement( "feature" );
		feature.set( "xmlns", xmpp.FeatureNegotiation.XMLNS );
		var form = new xmpp.DataForm( xmpp.dataform.FormType.submit );
		var form_f = new xmpp.dataform.Field();
		form_f.variable = "stream-method";
		form_f.values.push( xmlns );
		form.fields.push( form_f );
		feature.addChild( form.toXml() );
		si.any.push( feature );
		r.x = si;
		stream.sendPacket( r );
		stream.collect( [cast new xmpp.filter.IQFilter( xmlns, xmpp.IQType.set, xname )], handleRequest );
	}
	
	function handleRequest( iq : IQ ) {
		// override me
	}
	
	/*
	function handleTransferProgress( bytes : Bytes ) {
		onProgress( bytes );
	}
	
	function handleTransferComplete() {
		//this.data = bytes;
		onComplete();
	}
	*/
	
}
