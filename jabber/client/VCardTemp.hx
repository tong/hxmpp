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
package jabber.client;

/**
	<a href="http://www.xmpp.org/extensions/xep-0054.html">XEP-0054: vcard-temp</a>
	Depricated (use jabber.client.VCard), but still widely implementd by servers.
*/
class VCardTemp extends VCardBase<xmpp.VCardTemp> {
	
	public function new( stream : Stream ) {
		super( stream );
	}
	
	/**
		Requests to load the vcard from the given entity or from its own if jid is null.
	*/
	public override function load( ?jid : String  ) {
		super._load( xmpp.VCardTemp.emptyXml(), jid );
	}
	
	override function _handleLoad( iq : xmpp.IQ ) {
		onLoad( iq.from, ( iq.x != null ) ? xmpp.VCardTemp.parse( iq.x.toXml() ) : null );
	}
	
}
	 