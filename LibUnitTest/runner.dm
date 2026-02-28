/// Global variable to be instanced and referenced by user code.
var/datum/unit_test_runner/LibUnitTest

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
			if(tests_to_run[tests_to_run[middle]] <= test_instance.priority)
				left = middle + 1
			else
				right = middle
			
			middle = (left + right) >> 1

		middle = tests_to_run[tests_to_run[middle]] > test_instance.priority ? middle : middle + 1
		tests_to_run.Insert(middle, test_instance)
		tests_to_run[test_instance] = test_instance.priority

	for(var/datum/unit_test/test_instance as anything in tests_to_run)
		current_test = test_instance

		test_instance.BeforeRun()
		if(!test_instance.Bailed())
			test_instance.Run()
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

/// Writes the results of a test to the a log.
/datum/unit_test_runner/proc/logResult(datum/unit_test/test_instance)
	PROTECTED_PROC(TRUE)

	var/log_prefix = "PASSED"
	if(test_instance.DidFail())
		log_prefix = "FAILED"
	else if(test_instance.DidSkip())
		log_prefix = "SKIPPED"

	var/list/log_entry = list("\[[log_prefix]\] [test_instance.name]")

	var/list/reason_list
	if(test_instance.DidFail())
		reason_list = test_instance.GetFailReasons()
	else if(test_instance.DidSkip())
		reason_list = test_instance.GetSkipReasons()
	
	for(var/i in 1 to length(reason_list))
		var/text = reason_list[i][1]
		var/file = reason_list[i][2]
		var/line = reason_list[i][3]
	
		log_entry += "REASON #[i] | [text] at [file]:[line]"

	log += jointext(log_entry, "\n")

/// Write the log to the disk.
/datum/unit_test_runner/proc/writeLogToDisk()
	fdel(config.log_file)

	var/list/split_path = splittext(config.log_file, "/")
	var/file_name = split_path[split_path.len]
	var/directory = split_path.len > 1 ? "[split_path.Join("/", 1, split_path.len)]/" : ""

	fcopy(file_name, directory)
	file(config.log_file) << jointext(log, "\n")