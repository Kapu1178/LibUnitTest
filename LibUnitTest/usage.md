# Setup
LibUnitTest (LUT) can be placed anywhere within a project, and all of its contents should be included by including the `_prelude.md` file in your project's DME. LUT is designed such that the contents of the library can be dropped into an existing project and require zero modification to function. The `usercode` directory is provided as a location for tests, as well as overriding stub procs. LUT utilizes SpacemanDMM to mark procs as Private, Protected, and Should not Override to prevent misuse, but it is not required to use the library.

## Basics
LUT is comprised of 3 primary parts, the Runner, the Config, and the Tests. The Runner is a single global datum housing the entire unit test environment. A global variable is provided named LibUnitTest, and it begins as empty. The runner executes all of the tests according to the given configuration datum, if any, resorting to the default values otherwise.

## Creating a Test
Creating a test is as simple as defining a new subtype of `/datum/unit_test` and implementing `Run()`. Tests by default are considered "Passing", and failures can be generated using the `Fail()` proc, or tests may be entirely skipped via `Skip()`. By default, uncaught exceptions do not fail a running test to maintain the purity of the library, but it is highly encourage to do so, and a code example can be found in `usercode/example.dm`.

Remember to leave no atoms behind between tests, as it could cause cascading test failures and be difficult to track down! LUT provides some helpers for managing references created during a unit test in the form of the `allocate()` proc and `GarbageCollect()` proc. `allocate()` is a wrapper around `new`, which holds references and automatically deletes them after the test has concluded, via `GarbageCollect()`.  More "hands on" reference handling can be managed via `GarbageCollect()` as well.

Advanced projects with their own reference management may override `/datum/unit_test/proc/delete_wrapper`, as to not "hard delete" everything.

## Running Tests
To run all tests, `UNIT_TESTS` must be defined in the project before the inclusion of LUT. Create an instance of `/datum/unit_test_runner` within `global.LibUnitTest`. `LibUnitTest.RunTests()` will begin tests with the default configuration. Configuration is controlled by an instance of `/datum/unit_test_config`, which can be passed into `Run()` to utilize custom configs. Each test will be executed in order according to their assigned priority values, and the results will be output to `tmp/unit_tests.log`. 