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
package jabber;

import xmpp.IQ;
import xmpp.command.Action;

/**
	Listens for application-specific commands, such as those related to a configuration workflow.
	http://xmpp.org/extensions/xep-0050.html
*/
class AdHocCommandListener {
	
	/** */
	public dynamic function onRequest( jid : String, cmd : xmpp.AdHocCommand, f : xmpp.AdHocCommand->Void ) {}
	
	/** Informational callback when a command got canceled */
	public dynamic function onCancel( jid : String, cmd : xmpp.AdHocCommand ) {}
	
	public var stream(default,null) : Stream;
	
	var c : PacketCollector;
	
	public function new( stream : Stream ) {
		this.stream = stream;
		c = stream.collectPacket( [new xmpp.filter.IQFilter(xmpp.AdHocCommand.XMLNS)], handleRequest, true );
		stream.features.add( xmpp.AdHocCommand.XMLNS );
	}
	
	/**
		Dispose command listener service
	*/
	public function dispose() {
		stream.removeCollector( c );
		c = null;
	}
	
	/**
		Announce available commands to given entity.
		http://xmpp.org/extensions/xep-0050.html#announce
	*/
	public function announce( jid : String, subject : String, items : xmpp.disco.Items ) {
		var m = new xmpp.Message( jid, null, subject );
		m.properties.push( items.toXml() );
		stream.sendPacket( m );
	}
	
	function handleRequest( iq : IQ ) {
		var cmd = xmpp.AdHocCommand.parse( iq.x.toXml() );
		var action = cmd.action;
		if( action == null )
			action = execute;
		switch action {
		case execute, complete:
			onRequest( iq.from, cmd, function(result){
				var r = IQ.createResult( iq );
				r.x = result;
				stream.sendPacket( r );
			});
		case cancel:
			var r = IQ.createResult( iq );
			cmd.action = null;
			cmd.status = canceled;
			r.x = cmd;
			stream.sendPacket( r );
			onCancel( iq.from, cmd );
		//case next : trace("TODO");
		default :
			#if jabber_debug trace( 'unknown command action ($action)' ); #end
		}
	}
}
