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
package xmpp.lop;

using xmpp.XMLUtil;

class Ping {
	
	public var vm_id : String;
	public var job_id : String;
	public var status : String; // type (specs failure)
	
	public function new( vm_id : String, ?job_id : String, ?status : String ) {
		this.vm_id = vm_id;
		this.job_id = job_id;
		this.status = status;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "spawn_vm" );
		x.ns( xmpp.LOP.XMLNS );
		if( vm_id != null ) x.set( "vm_id", vm_id );
		if( job_id != null ) x.set( "job_id", job_id );
		if( status != null ) x.set( "status", status );
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.lop.Ping {
		return new Ping( x.get( "vm_id" ), x.get( "job_id" ), x.get( "status" ) );
	}
	
}
