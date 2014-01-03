
import js.Browser.document;
import js.Browser.window;

/**
	See: https://github.com/tong/chrome.app
*/
class App {
	
	static function main() {
		window.onload = function(_){
			
			document.getElementById('connect').onclick = function(_){

				document.getElementById('login').style.visibility = 'hidden';
				
				var jid : String = untyped document.getElementById('jid').value;
				var password : String = untyped document.getElementById('password').value;
				var ip : String = untyped document.getElementById('ip').value;
				var http : String = untyped document.getElementById('http').value;
				var cnx = new jabber.SocketConnection( ip );
				var stream = new jabber.client.Stream( cnx );
				stream.onOpen = function(){
					var auth = new jabber.client.Authentication( stream, [new jabber.sasl.PlainMechanism()] );
					auth.onSuccess = function(){
						trace( 'Authenticated as $jid' );
						stream.sendPresence();
						var roster = new jabber.client.Roster(stream);
						roster.onLoad = function(){
							var container = document.getElementById('roster');
							for( item in roster.items ) {
								var e = document.createDivElement();
								e.innerHTML = item.jid;
								container.appendChild(e);
							}
						}
						roster.load();
					}
					auth.onFail = function(e){
						trace( 'Authentication failed ($jid)($password)' );
					}
					auth.start( password, "hxmpp" );
				}
				stream.onClose = function(?e){
					trace( "XMPP stream closed" );
					if( e != null ) trace(e);
				};
				stream.open( jid );
			}
		}
	}
	
}
