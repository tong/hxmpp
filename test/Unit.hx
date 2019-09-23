
class Unit {

	static function main() {

		var runner = new utest.Runner();

		runner.addCase( new TestXML() );
	//	runner.addCase( new TestXMLSchema() );
		
		runner.addCase( new TestJID() );

		runner.addCase( new TestStanza() );
		runner.addCase( new TestMessage() );
		runner.addCase( new TestPresence() );
		runner.addCase( new TestIQ() );

		//runner.addCase( new TestContentBuild() );

        utest.ui.Report.create( runner );

        runner.run();
	}

}
