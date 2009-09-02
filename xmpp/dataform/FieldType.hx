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
package xmpp.dataform;

enum FieldType {
	
	/**
		The field enables an entity to gather or provide an either-or choice between two options.
		The default value is "false".
	*/
	boolean;
	
	/**
		The field is intended for data description (e.g., human-readable text such as "section" headers) rather than data gathering or provision.
		The <value/> child SHOULD NOT contain newlines (the \n and \r characters);
		instead an application SHOULD generate multiple fixed fields, each with one <value/> child.
	*/
	fixed;
	
	/**
		The field is not shown to the form-submitting entity, but instead is returned with the form.
		The form-submitting entity SHOULD NOT modify the value of a hidden field, 
		but MAY do so if such behavior is defined for the "using protocol".
	*/
	hidden;
	
	/**
		The field enables an entity to gather or provide multiple Jabber IDs.
		Each provided JID SHOULD be unique (as determined by comparison that includes application of the Nodeprep, Nameprep, and Resourceprep profiles of Stringprep as specified in XMPP Core),
		and duplicate JIDs MUST be ignored.
	*/
	jid_multi;
	
	/**
		The field enables an entity to gather or provide a single Jabber ID. 
	*/
	jid_single;
	
	/**
		The field enables an entity to gather or provide one or more options from among many.
		A form-submitting entity chooses one or more items from among the options presented by the form-processing entity and MUST NOT insert new options.
		The form-submitting entity MUST NOT modify the order of items as received from the form-processing entity,
		since the order of items MAY be significant.
	*/
	list_multi;
	
	/**
		The field enables an entity to gather or provide one option from among many.
		A form-submitting entity chooses one item from among the options presented by the form-processing entity and MUST NOT insert new options.
	*/
	list_single;
	
	/**
		 The field enables an entity to gather or provide multiple lines of text.
	*/
	text_multi;
	
	/**
		The field enables an entity to gather or provide a single line or word of text,
		which shall be obscured in an interface (e.g., with multiple instances of the asterisk character).
	*/
	text_private;
	
	/**
		The field enables an entity to gather or provide a single line or word of text, which may be shown in an interface.
		This field type is the default and MUST be assumed if a form-submitting entity receives a field type it does not understand.
	*/
	text_single;
	
}
