function main() {
    final runner = new utest.Runner();
    runner.addCase( new TestXML() );
    runner.addCase( new TestXMLSchema() );
    runner.addCase( new TestJid() );
    runner.addCase( new TestResponse() );
    runner.addCase( new TestStanza() );
    runner.addCase( new TestMessage() );
    runner.addCase( new TestPresence() );
    runner.addCase( new TestIQ() );
    runner.addCase( new TestStream() );
    utest.ui.Report.create( runner );
    runner.run();
}
