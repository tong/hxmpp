function main() {
    final r = new utest.Runner();
    r.addCase(new TestXML());
    //r.addCase(new TestXMLSchema());
    r.addCase(new TestJid());
    r.addCase(new TestStanza());
    r.addCase(new TestMessage());
    r.addCase(new TestPresence());
    r.addCase(new TestIQ());
    r.addCase(new TestDataForm());
    r.addCase(new TestResponse());
    r.addCase(new TestStream());
    //r.addCase(new TestURI());
    utest.ui.Report.create(r);
    r.run();
}
