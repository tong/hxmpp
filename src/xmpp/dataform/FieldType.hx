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
package xmpp.dataform;

@:enum abstract FieldType(String) {
	
	/**
		The field enables an entity to gather or provide an either-or choice between two options.
		The default value is "false".
	*/
	var boolean = "boolean"; //TODO java throws error 
	
	/**
		The field is intended for data description (e.g., human-readable text such as "section" headers) rather than data gathering or provision.
		The <value/> child SHOULD NOT contain newlines (the \n and \r characters);
		instead an application SHOULD generate multiple fixed fields, each with one <value/> child.
	*/
	var fixed = "fixed";
	
	/**
		The field is not shown to the form-submitting entity, but instead is returned with the form.
		The form-submitting entity SHOULD NOT modify the value of a hidden field, 
		but MAY do so if such behavior is defined for the "using protocol".
	*/
	var hidden = "hidden";
	
	/**
		The field enables an entity to gather or provide multiple Jabber IDs.
		Each provided JID SHOULD be unique (as determined by comparison that includes application of the Nodeprep, Nameprep, and Resourceprep profiles of Stringprep as specified in XMPP Core),
		and duplicate JIDs MUST be ignored.
	*/
	var jid_multi = "jid-multi";
	
	/**
		The field enables an entity to gather or provide a single Jabber ID. 
	*/
	var jid_single = "jid-single";
	
	/**
		The field enables an entity to gather or provide one or more options from among many.
		A form-submitting entity chooses one or more items from among the options presented by the form-processing entity and MUST NOT insert new options.
		The form-submitting entity MUST NOT modify the order of items as received from the form-processing entity,
		since the order of items MAY be significant.
	*/
	var list_multi = "list-multi";
	
	/**
		The field enables an entity to gather or provide one option from among many.
		A form-submitting entity chooses one item from among the options presented by the form-processing entity and MUST NOT insert new options.
	*/
	var list_single = "list-single";
	
	/**
		 The field enables an entity to gather or provide multiple lines of text.
	*/
	var text_multi = "text-multi";
	
	/**
		The field enables an entity to gather or provide a single line or word of text,
		which shall be obscured in an interface (e.g., with multiple instances of the asterisk character).
	*/
	var text_private = "text-private";
	
	/**
		The field enables an entity to gather or provide a single line or word of text, which may be shown in an interface.
		This field type is the default and MUST be assumed if a form-submitting entity receives a field type it does not understand.
	*/
	var text_single = "text-single";
	
}
