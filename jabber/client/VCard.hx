/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009-2010 http://www.disktree.net
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
	VCard4
	
	http://xmpp.org/extensions/xep-0292.html
*/
class VCard extends VCardBase<xmpp.VCard> {
	
	public function new( stream : Stream ) {
		super( stream );
	}
	
	/**
		Requests to load the vcard from the given entity or own no jid is given.
	*/
	public override function load( ?jid : String  ) {
		super._load( xmpp.VCard.emptyXml(), jid );
	}
	
	override function _handleLoad( iq : xmpp.IQ ) {
		onLoad( iq.from, ( iq.x != null ) ? xmpp.VCard.parse( iq.x.toXml() ) : null );
	}
	
}
