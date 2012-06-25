/*
 * Copyright (c) 2012, tong, disktree.net
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
		Accept/Deny the data transfer
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
		xmpp.XMLUtil.setNamespace( feature, xmpp.FeatureNegotiation.XMLNS );
		//feature.set( "xmlns", xmpp.FeatureNegotiation.XMLNS );
		
		var form = new xmpp.DataForm( xmpp.dataform.FormType.submit );
		var form_f = new xmpp.dataform.Field();
		form_f.variable = "stream-method";
		form_f.values.push( xmlns );
		form.fields.push( form_f );
		feature.addChild( form.toXml() );
		
		si.any.push( feature );
		r.x = si;
		
		stream.sendPacket( r );
		stream.collect( [new xmpp.filter.IQFilter( xmlns, xmpp.IQType.set, xname )], handleRequest );
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
