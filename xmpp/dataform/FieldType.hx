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
