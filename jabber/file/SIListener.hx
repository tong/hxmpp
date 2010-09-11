package jabber.file;

import haxe.io.Bytes;
import xmpp.IQ;

/**
	Listens for incoming file transfer requests.
*/
class SIListener {
	
	public dynamic function onFail( info : String ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	public var methods(default,null) : Array<FileReciever>;
	public var handler : FileReciever->Void;
	
	//var file : xmpp.file.File;
	//var methodIndex : Int;
	
	public function new( stream : jabber.Stream, handler : FileReciever->Void ) {
		this.stream = stream;
		this.handler = handler;
		methods = new Array();
		stream.features.add( xmpp.file.SI.PROFILE );
		stream.collect( [cast new xmpp.filter.IQFilter( xmpp.file.SI.XMLNS, "si", xmpp.IQType.set )],
						 handleRequest, true );
	}
	
	function handleRequest( iq : xmpp.IQ ) {
		var si = xmpp.file.SI.parse( iq.x.toXml() );
		var file : xmpp.file.File = null;
		var _methods = new Array<String>();
		for( e in si.any ) {
			#if flash // haXe 2.06 fukup
			if( e.nodeName == "feature" && e.get( "_xmlns_" ) == xmpp.FeatureNegotiation.XMLNS ) {
			#else
			if( e.nodeName == "feature" && e.get( "xmlns" ) == xmpp.FeatureNegotiation.XMLNS ) {
			#end
				for( e in e.elementsNamed( "x" ) ) {
					var form = xmpp.DataForm.parse( e );
					var field = form.fields[0];
					if( field.variable == "stream-method" ) {
						for( o in field.options ) {
							_methods.push( o.value );
						}
					}
				}
			#if flash // haXe 2.06 fukup
			} else if( e.nodeName == "file" && e.get( "_xmlns_" ) == xmpp.file.SI.PROFILE ) {
			#else
			} else if( e.nodeName == "file" && e.get( "xmlns" ) == xmpp.file.SI.PROFILE ) {
			#end
				file = xmpp.file.File.parse( e );
			}
		}
		if( file == null ) {
			//TODO send error
			onFail( "invalid file transfer request" );
			return;
		}
		trace(_methods);
		var acceptedMethods = new Array<FileReciever>();
		for( m in methods ) {
			for( _m in _methods ) {
				if( _m == m.xmlns ) {
					acceptedMethods.push( m );
				}
			}
		}
		if( acceptedMethods.length == 0 ) {
			onFail( "no matching file transfer method" );
			return;
		}
		
		/*
		this.methods = acceptedMethods;
		method = methods[0]; //methods[methodIndex]; //TODO
		//handler( this );
		trace("##########################>>>>>>>>>>>>>>>>>>>>>>>>>>");
		method.init( file );
		handler( method );
		*/
		// TODO new FileTransferNegotiator();
		var method = methods[0];
		method.__init( file, iq, si.id );
		handler( method );
	}
	
}

/*
private class FileTransferNegotiator {
	
	public function new( methods : Array<FileTransfer> ) {
	}
}
*/

