
import Sys.print;
import jabber.sasl.MD5DigestCalculator;

using Lambda;

/**
	Remote SASL-MD5 calculator for XMPP clients
*/
class Index {
	
	static var passwords = {
		hxmpp : 'test'
	};

	static function main() {
		
		var params = php.Web.getParams();
		var host = params.get( 'host' );
		var servertype = params.get( 'servertype' );
		var username = params.get( 'username' );
		var realm = params.get( 'realm' );
		var nonce = params.get( 'nonce' );

		if( host == null || servertype == null || username == null || realm == null || nonce == null ) {
			print(null);
			return;
		}
		
		var password = Reflect.field( passwords, username );
		if( password == null ) {
			print(null);
			return;
		}

		var hash : String = null;
		try hash = MD5DigestCalculator.digest( host, servertype, username, realm, password, nonce ) catch( e : Dynamic ) {
			print(null);
			return;
		}
		Sys.print( hash );
	}

}
