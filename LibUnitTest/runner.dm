/// Global variable to be instanced and referenced by user code.
#ifdef UNIT_TESTS
var/datum/unit_test_runner/LibUnitTest
#endif

/datum/unit_test_runner
	/// Currently running test.
	VAR_PRIVATE/datum/unit_test/current_test
	/// Configuration datum.
	VAR_PRIVATE/datum/unit_test_config/config

	/// K:V list of test_instance -> list(skip reasons)
	VAR_PRIVATE/list/skipped_tests = list()
	/// K:V list of test_instance -> list(fail reasons)
	VAR_PRIVATE/list/failed_tests = list()
	/// Flat list of successful test instances.
	VAR_PRIVATE/list/successful_tests = list()

	var/list/log = list()

/// Run tests.
/datum/unit_test_runner/proc/RunTests(datum/unit_test_config/config_to_use)
	SHOULD_NOT_OVERRIDE(TRUE)

	config = config_to_use || new()
	
	var/list/tests_to_run = list()

	for(var/test_type in typesof(/datum/unit_test) - /datum/unit_test)
		var/datum/unit_test/test_instance = new test_type

		if(!length(tests_to_run))
			tests_to_run[test_instance] = test_instance.priority
			continue

		// Good ol' binary insertion
		var/left = 1
		var/right = length(tests_to_run)
		var/middle = (left + right) >> 1
		while(left < right)
			if(tests_to_run[tests_to_run[middle]] >= test_instance.priority)
				left = middle + 1
			else
				right = middle
			
			middle = (left + right) >> 1

		middle = tests_to_run[tests_to_run[middle]] < test_instance.priority ? middle : middle + 1
		tests_to_run.Insert(middle, test_instance)
		tests_to_run[test_instance] = test_instance.priority

	for(var/datum/unit_test/test_instance as anything in tests_to_run)
		current_test = test_instance

		test_instance.BeforeRun(src)
		if(!test_instance.Bailed())
			test_instance.Run(src)
		test_instance.GarbageCollect()

		if(test_instance.DidFail())
			failed_tests[test_instance] = test_instance.GetFailReasons()
		else if(test_instance.DidSkip())
			skipped_tests[test_instance] = test_instance.GetSkipReasons()
		else
			successful_tests += test_instance
		
		logResult(test_instance)

	current_test = null
	writeLogToDisk()
	OnFinishTests()
	
/// Returns the current test instance, if any.
/datum/unit_test_runner/proc/TryGetCurrentTest() as /datum/unit_test
	SHOULD_NOT_OVERRIDE(TRUE)
	return current_test

/// Returns the current config, if any.
/datum/unit_test_runner/proc/TryGetConfig() as /datum/unit_test_config
	SHOULD_NOT_OVERRIDE(TRUE)
	return config

/// Returns the bottom-left turf of the test area.
/datum/unit_test_runner/proc/GetBLTurf()
	SHOULD_NOT_OVERRIDE(TRUE)
	return config.bottom_left_turf

/// Returns the top-right turf of the test area.
/datum/unit_test_runner/proc/GetTRTurf()
	SHOULD_NOT_OVERRIDE(TRUE)
	return config.top_right_turf

/// Returns a list of all turfs in the test region.
/datum/unit_test_runner/proc/GetTestBlock()
	return block(GetBLTurf(), GetTRTurf())