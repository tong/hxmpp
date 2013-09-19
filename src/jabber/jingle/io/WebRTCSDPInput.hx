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
package jabber.jingle.io;

/**
*/
@:require(js) class WebRTCSDPInput extends WebRTCSDPTransport {
	
	public var stream(default,null) : Dynamic;
	
	public function new( sdp : String ) {
		super();
		this.sdp  =sdp;
	}
	
	public override function connect() {
		super.connect();
		//TODO
		//connection.processSignalingMessage( sdp );
	}
	
	/*
	override function signalingCallback( s : String ) {
		sdp = s;
		//trace(sdp);
		__onConnect();
	}
	*/
	
	/*
	override function onRemoteStreamAdded(e) {
		stream = e.stream;
	}
	*/
	
	/* 
	public static inline function ofCandidate( x : Xml ) : WebRTCInput {
		return new WebRTCInput();
		//return null;
		//return new RTMPInput( x.get( "name" ), x.get( "host" ), Std.parseInt( x.get( "port" ) ), x.get( "id" ) );
	}
	*/
	
}
