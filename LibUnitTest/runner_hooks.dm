// Procs within this file are intended to be overridden within the usercode directory.

/// Called when all tests have concluded.
/datum/unit_test_runner/proc/OnFinishTests()
	return

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
	
		log_entry += "\tREASON #[i] | [text] at [file]:[line]"
	
		if(config.github_actions_log && test_instance.DidFail())
			// I guess you need to URI encode newlines.
			var/anno = replacetext(replacetext(text, "%", "%25"), "\n", "%0A")
			world.log << "::error file=[test_instance.name],line=[line],title=[test_instance.type]: [test_instance.type]::[anno]"

	var/log_text = jointext(log_entry, "\n")
	log += log_text
	if(config.github_actions_log)
		world.log << log_text

/// Write the log to the disk.
/datum/unit_test_runner/proc/writeLogToDisk()
	PROTECTED_PROC(TRUE)
	fdel(config.log_file)

	var/list/split_path = splittext(config.log_file, "/")
	var/file_name = split_path[split_path.len]
	var/directory = split_path.len > 1 ? "[split_path.Join("/", 1, split_path.len)]/" : ""

	fcopy(file_name, directory)
	file(config.log_file) << jointext(log, "\n")