/datum/unit_test
	var/name = "Unit Tests Shall Pass"
	/// Execution priority. Higher == sooner.
	var/priority = 1

	VAR_PROTECTED/list/skip_reasons = list()
	VAR_PROTECTED/list/fail_reasons = list()
	
	/// Contains a list of all datums created during the test using the allocate() function, for automatic garbage collection.
	VAR_PRIVATE/list/allocated_datums = list()

/// Stub for user behavior, executed before Run().
/datum/unit_test/proc/BeforeRun(datum/unit_test_runner/runner)
	return

/// Stub for user behavior, most behavior should occur here.
/datum/unit_test/proc/Run(datum/unit_test_runner/runner)
	return

/// Clean up references / the unit test area. Executed after Run().
/datum/unit_test/proc/GarbageCollect()
	SHOULD_CALL_PARENT(TRUE)
	for(var/datum/datum in allocated_datums)
		if(!istype(datum, /datum))
			continue
		
		delete_wrapper(datum)

/// Returns TRUE if the unit test concluded with a non-success exit.
/datum/unit_test/proc/Bailed()
	SHOULD_NOT_OVERRIDE(TRUE)
	return DidSkip() || DidFail()

/// Returns TRUE if the test was skipped.
/datum/unit_test/proc/DidSkip()
	SHOULD_NOT_OVERRIDE(TRUE)
	return !DidFail() && !!length(skip_reasons)

/// Returns TRUE if the test was skipped.
/datum/unit_test/proc/DidFail()
	SHOULD_NOT_OVERRIDE(TRUE)
	return !!length(fail_reasons)

/// Getter for skip reasons.
/datum/unit_test/proc/GetSkipReasons()
	SHOULD_NOT_OVERRIDE(TRUE)
	return skip_reasons

/datum/unit_test/proc/GetFailReasons()
	SHOULD_NOT_OVERRIDE(TRUE)
	return fail_reasons

/// Appends a failure reason, marking the test as failed.
/datum/unit_test/proc/Fail(failure_reason = "No reason provided", file = caller.file, line = caller.line)
	SHOULD_NOT_OVERRIDE(TRUE)
	fail_reasons[++fail_reasons.len] = list(failure_reason, file, line)

/// Appends a skip reason, marking the test as skipped.
/datum/unit_test/proc/Skip(skip_reason = "No reason provided", file = caller.file, line = caller.line)
	SHOULD_NOT_OVERRIDE(TRUE)
	skip_reasons[++skip_reasons.len] = list(skip_reason, file, line)

/// Allows user-defined garbage collection instead of del().
/datum/unit_test/proc/delete_wrapper(datum)
	PROTECTED_PROC(TRUE)
	del(datum)

/// A wrapper for new(), handles garbage collection automatically.
/datum/unit_test/proc/allocate(type_path, ...)
	SHOULD_NOT_OVERRIDE(TRUE)
	PROTECTED_PROC(TRUE)

	var/list/arguments = list()
	if(length(args) > 1)
		arguments = args.Copy(2)
	
	var/datum/out = new type_path(arglist(arguments))
	allocated_datums += out
	return out