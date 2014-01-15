use Test::More;

BEGIN {
    use_ok('Imp') || print "Bail out!";
    use_ok('Imp::System') || print "Bail out!";
    use_ok('Imp::System::Cron') || print "Bail out!";
    use_ok('Imp::System::Useradd') || print "Bail out!";
    use_ok('Imp::Portage') || print "Bail out!";
    use_ok('Imp::Portage::Config') || print "Bail out!";
    use_ok('Imp::Portage::Emerge') || print "Bail out!";
    use_ok('Imp::Environment') || print "Bail out!";
}

done_testing();
