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
package xmpp;

/**
	Abstract base for personal event classes.
	The implementing class HAS TO HAVE a static XMLNS field (required by jabber.PersonalEventListener)!
*/
class PersonalEvent {
	
	public var nodeName(default,null) : String;
	public var xmlns(default,null) : String;
	
	function new( nodeName : String, xmlns : String ) {
		this.nodeName = nodeName;
		this.xmlns = xmlns;
	}
	
	/**
		Returns the (subclass) namespace.
	*/
	public function getNode() : String {
		return xmlns;
	}
	
	/**
		Returns a empty XML node for disabling the personal event.
	*/
	public function empty() : Xml {
		return IQ.createQueryXml( xmlns, nodeName );
	}
	
	public function toXml() : Xml {
		return throw 'abstract method';
	}
	
	/*
	public static function fromMessage( m : xmpp.Message ) : xmpp.pep.Event {
		////////
	}
	*/
	
}
