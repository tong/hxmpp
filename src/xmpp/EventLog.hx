/*
 * Copyright (c) disktree.net
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
package xmpp;

import haxe.EnumTools;

@:fakeEnum(String)
enum EventLogType {

	/** Developers can ask applications to send debug messages during development or testing to more easily see what happens in a system. */
	debug;

	/** An informational message describing a normal event. */
	informational;

	/** Represents a significant condition or change that administrators should be aware of. */
	notice;

	/** A warning condition. If not taken into account, the condition could turn into an error. */
	warning;
	
	/** An error condition. A condition has been detected that is considered to be an error or a fault. */
	error;

	/** A critical condition. An error so great that it could escalate into something graver if not addressed. */
	critical;

	/** An alert condition. Action must be taken immediately. */
	alert;

	/** System is unusable. */
	emergency;
}

@:fakeEnum(String)
enum EventLogLevel {
	minor;
	medium;
	major;
}

//TODO class
typedef EventLogTag = {
	var name : String;
	var value : String;
	@:optional var type : String;
}

//TODO Date type for timestamp field

/**
	Event Logging over XMPP
	http://xmpp.org/extensions/xep-0337.html
*/
class EventLog {

	public static inline var XMLNS = 'urn:xmpp:eventlog';

	//public var timestamp : Date;
	public var timestamp : String;
	public var messages :	Array<String>;
	public var tags : Array<EventLogTag>;
	public var stackTrace : String;
	public var id : String;
	public var type : EventLogType;
	public var level : EventLogLevel;
	public var object : String;
	public var subject : String;
	public var facility : String;
	public var module : String;

	//public function new( timestamp : Date ) {
	public function new( timestamp : String ) {
		this.timestamp = timestamp;
		messages = new Array();
		tags = new Array();
		type = informational;
		level = minor;
	}

	public function toXml() : Xml {
		var x = IQ.createQueryXml( XMLNS, 'log' );
		x.set( 'timestamp', timestamp.toString() ); //TODO use date
		for( m in messages ) x.addChild( XMLUtil.createElement( 'message', m ) );
		for( t in tags ) {
			var e = Xml.createElement( 'tag' );
			e.set( 'name', t.name );
			e.set( 'value', t.value );
			if( t.type != null ) e.set( 'type', t.type );
			x.addChild( e );
		}
		if( type != null ) x.set( 'type', Std.string( type ) );
		if( level != null ) x.set( 'level', Std.string( level ) );
		if( object != null ) x.set( 'object', object );
		if( subject != null ) x.set( 'subject', subject );
		if( facility != null ) x.set( 'facility', facility );
		if( module != null ) x.set( 'module', module );
		return x;
	}

	public static function parse( x : Xml ) : EventLog {
		//if( x.get('xmlns') != XMLNS )
		//var elog = new EventLog( Date.fromString( x.get( 'timestamp' ) ) );
		var e = new EventLog( x.get( 'timestamp' ) );
		e.stackTrace = x.get( 'stackTrace' );
		e.id = x.get( 'id' );
		if( x.exists('type') ) e.type = EnumTools.createByName( EventLogType, x.get( 'type' ) );
		if( x.exists('level') ) e.level = EnumTools.createByName( EventLogLevel, x.get( 'level' ) );
		e.object = x.get( 'object' );
		e.subject = x.get( 'subject' );
		e.facility = x.get( 'facility' );
		e.module = x.get( 'module' );
		for( x in x.elements() ) {
			switch x.nodeName {
			case 'message': e.messages.push( x.firstChild().nodeValue );
			case 'tag': e.tags.push( { name : x.get('name'), value : x.get('value'), type : x.get('type') } );
			}
		}
		return e;
	}

}
