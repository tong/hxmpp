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

@:enum abstract EventLogType(String) {

	/** Developers can ask applications to send debug messages during development or testing to more easily see what happens in a system. */
	var debug = "debug";

	/** An informational message describing a normal event. */
	var informational = "informational";

	/** Represents a significant condition or change that administrators should be aware of. */
	var notice = "notice";

	/** A warning condition. If not taken into account, the condition could turn into an error. */
	var warning = "warning";
	
	/** An error condition. A condition has been detected that is considered to be an error or a fault. */
	var error = "error";

	/** A critical condition. An error so great that it could escalate into something graver if not addressed. */
	var critical = "critical";

	/** An alert condition. Action must be taken immediately. */
	var alert = "alert";

	/** System is unusable. */
	var emergency = "emergency";
}

@:enum abstract EventLogLevel(String) {
	var minor = "minor";
	var medium = "medium";
	var major = "major";
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

	/** When the event occurred. */
	//public var timestamp : Date;
	public var timestamp : String;

	/** A (human readable) text message describing what has occurred. */
	public var messages :	Array<String>;

	/** Custom tags or parameter attached to an event.*/
	public var tags : Array<EventLogTag>;

	/**
		Exact position in the code from which the event was reported or where the error occurred.
		Reporting it in a separate attribute unclutters the message, and removes the need to define custom tags.
	*/
	public var stackTrace : String;

	/** An attribute providing a machine readable ID to the type of event in question without having to parse the message text itself. */
	public var id : String;

	/** Coarse classification of the event */
	public var type : EventLogType;

	/** Provides an additional level on the previous classification (Minor, Medium, Major). */
	public var level : EventLogLevel;

	/** The object to which the event message refers to, on which the current action is performed. */
	public var object : String;

	/** The subject causing the event to take place or performing the action (for instance, user, process, etc.) */
	public var subject : String;

	/** What type of device, server, application, etc., is sending the message. */
	public var facility : String;

	/**
		The module reporting the event. Larger software packages are often divided into modules.
		Keeping track of which modules report which events can be useful when analyzing system performance.
	*/
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
		for( m in messages )
			x.addChild( XMLUtil.createElement( 'message', m ) );
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
		if( x.exists('type') ) e.type = cast x.get( 'type' );
		if( x.exists('level') ) e.level = cast x.get( 'level' );
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
