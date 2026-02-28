/datum/unit_test_config
	/// File name and directory for the log file..
	var/log_file = "tmp/unit_tests.log"

	/// Bottom-left turf of the test area.
	var/turf/bottom_left_turf
	/// Top-right turf of the test area.
	var/turf/top_right_turf

/datum/unit_test_config/New()
	. = ..()
	bottom_left_turf = locate(1,1,1)
	top_right_turf = locate(1,1,1)