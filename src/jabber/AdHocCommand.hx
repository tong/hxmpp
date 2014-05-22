/*
 * Copyright (c), disktree
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
package jabber;

import xmpp.command.Action;
import xmpp.command.Status;

/**
	A command session for advertising and executing application-specific commands,
	such as those related to a configuration workflow.

	XEP-0050: Ad-Hoc Commands: http://xmpp.org/extensions/xep-0050.html

	See also: XEP-0146: Remote Controlling Clients: http://xmpp.org/extensions/xep-0146.html
*/
class AdHocCommand {
	
	/** */
	public dynamic function onExecuting( cmd : xmpp.AdHocCommand ) {}
	/** */
	public dynamic function onCanceled() {}
	/** */
	public dynamic function onComplete( cmd : xmpp.AdHocCommand ) {}
	/** */
	public dynamic function onError( e : XMPPError ) {}
	
	public var stream(default,null) : Stream;
	
	/** Command host jid */
	public var host(default,null) : String;
	
	/** Used command node */
	public var node(default,null) : String;

	/** */
	public var sessionId(default,null) : String;
	
	public function new( stream : Stream,
						 host : String, node : String ) {
		this.stream = stream;
		this.host = host;
		this.node = node;
	}
	
	public function execute() {
		var iq = new xmpp.IQ( xmpp.IQType.set, null, host );
		iq.x = new xmpp.AdHocCommand( node, xmpp.command.Action.execute );
		stream.sendIQ( iq, handleResponse );
		//executeAction( Action.execute, form );
	}
	
	/**
		Start command process
	*/
	public function cancel() {
		var iq = new xmpp.IQ( xmpp.IQType.set, null, host );
		iq.x = new xmpp.AdHocCommand( node, xmpp.command.Action.cancel );
		stream.sendIQ( iq, handleResponse );
		//executeAction
	}
	
	/**
	*/
	public function next( child : Xml ) {
		executeAction( node, null, child );
	}
	
	/*
	public function complete() {
	}
	
	public function prev() {
	}
	*/
	
	function executeAction( node : String, action : Action, ?child : Xml ) {
		var iq = new xmpp.IQ( xmpp.IQType.set, null, host );
		var cmd = new xmpp.AdHocCommand( node, action, sessionId );
		cmd.child = child;
		iq.x = cmd; //new xmpp.AdHocCommand( node, action, sessionId );
		stream.sendIQ( iq, handleResponse );
	}
	
	function handleResponse( iq : xmpp.IQ ) {
		//trace("RRR--------------------------------");
		switch( iq.type ) {
		case result :
			var cmd = xmpp.AdHocCommand.parse( iq.x.toXml() );
			//trace( "SSSS "+cmd.status );
			switch( cmd.status ) {
			case executing :
				onExecuting( cmd );
			case completed :
				onComplete( cmd );
			case canceled :
				onCanceled();
			}
		case error :
			onError( new XMPPError( iq ) );
		default :
		}
	}
}

/*
class Command {
	
	public dynamic function onNext( data : xmpp.DataForm ) {}
	public dynamic function onComplete( data : xmpp.DataForm ) {}
	//public dynamic function onCanceled( success : Bool = true ) {}
	//public dynamic function onError( e : XMPPError ) {}
	
	
	 Command session host 
	public var host : String;
	// Command session id
	public var id(default,null) : String;
	public var stream(default,null) : Stream;
	public var node(default,null) : String;
	
	//var hasPrev : Bool;
	//var hasNext : Bool;
	
	
	public function new( stream : Stream, host : String ) {
		this.stream = stream;
		this.host = host;
	}
	
	
		Init command session with the given command node.
	public function execute( node : String ) {
		this.node = node;
		var q = new xmpp.IQ( xmpp.IQType.set, null, host );
		q.x = new Command( node, xmpp.command.Action.execute );
		stream.sendIQ( q, handleResponse );
	}
	
	public function executeNext( data : xmpp.DataForm ) {
		var q = new xmpp.IQ( xmpp.IQType.set, null, host );
		<iq type='set' to='responder@domain' id='exec2'>
  <command xmlns='http://jabber.org/protocol/commands'
           sessionid='config:20020923T213616Z-700'
           node='config'>
    <x xmlns='jabber:x:data' type='submit'>
      <field var='service'>
        <value>httpd</value>
      </field>
    </x>
  </command>
</iq>
	}
	
		//Revert to the previous stage.
	public function prev() {
		if( sessionid == null )
			throw "Command session not active";
		var iq = new xmpp.IQ( xmpp.IQType.set );
		//..
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
			case result :
				//...
				//onNext( data );
			}
		} );
		<iq type='set' to='responder@domain' id='exec2'>
  <command xmlns='http://jabber.org/protocol/commands'
           sessionid='config:20020923T213616Z-700'
           node='config'
           action='prev'/>
</iq>
	}
	
	//	Cancel the command session.
	public function cancel() {
		<iq type='set' to='responder@domain' id='exec3'>
  <command xmlns='http://jabber.org/protocol/commands'
           sessionid='config:20020923T213616Z-700'
           node='config'
           action='cancel'/>
</iq>
	}
	
	function handleResponse( iq : xmpp.IQ ) {
		switch( r.type ) {
		case result :
			var c = xmpp.Command.parse( iq.x.toXml() );
			if( c.sessionid != sessionid ) {
				//..........
			}
			
			switch( c.status ) {
			case "completed" :
				var data = xmpp.DataForm.parse( el );
				//...
				onComplete( data );
			case "executing" :
				//..
				onNext( data );
			}
		case error :
			onError( new XMPPError( iq ) );
		default : //#
		}
	}
}
	*/
