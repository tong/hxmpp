
import utest.Assert.*;


typedef Roster = {
	var item : String;
	var ver : String;
}

//TODO:
class TestXEP extends utest.Test {

    public function test() {

		//var str = 'xmpp:example.com';
       
	   //XEP.a();
		var roster = new xmpp.XEP<Roster>();
		//xmpp.XEP.build( Roster );

	   	//trace(xep.Samba);
    }
}

