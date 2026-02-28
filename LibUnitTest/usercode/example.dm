// Uncaught exceptions during unit tests fail the test.
/world/Error(exception/exception)
	#ifdef UNIT_TESTS
	LibUnitTest?.TryGetCurrentTest()?.Fail("Uncaught exception: [exception.name] in [exception.file]:[exception.line]\n[exception.desc]", exception.file, exception.line)
	#endif
	. = ..()
	
/datum/unit_test/deliberate_fail
	name = "Failing Tests Shall Fail"
	priority = 1

/datum/unit_test/deliberate_fail/Run()
	Fail("TEST FAIL.")

/datum/unit_test/deliberate_skip
	name = "Skipped Tests Shall Skip"
	priority = 2

/datum/unit_test/deliberate_skip/Run()
	Skip("TEST SKIP.")

/datum/unit_test/runtimes_fail
	name = "Uncaught Exceptions Shall Fail"
	priority = 3

/datum/unit_test/runtimes_fail/Run()
	var/one = 1
	var/zero = 0
	return one / zero

/datum/unit_test/empty
	name = "Empty Tests Shall Succeed"
	priority = 4

/datum/unit_test/empty/Run()