// LibUnitTest version 1.0.0
// Author: Kapu1178

/// SpacemanDMM is optional, but not required. If SMDMM is not present, gracefully stub its macros.
#if defined(SPACEMAN_DMM) && !defined(UNLINT)
	#define RETURN_TYPE(X) set SpacemanDMM_return_type = X
	#define SHOULD_CALL_PARENT(X) set SpacemanDMM_should_call_parent = X
	#define UNLINT(X) SpacemanDMM_unlint(X)
	#define SHOULD_NOT_OVERRIDE(X) set SpacemanDMM_should_not_override = X
	#define SHOULD_NOT_SLEEP(X) set SpacemanDMM_should_not_sleep = X
	#define SHOULD_BE_PURE(X) set SpacemanDMM_should_be_pure = X
	#define PRIVATE_PROC(X) set SpacemanDMM_private_proc = X
	#define PROTECTED_PROC(X) set SpacemanDMM_protected_proc = X
	#define VAR_FINAL var/SpacemanDMM_final
	#define VAR_PRIVATE var/SpacemanDMM_private
	#define VAR_PROTECTED var/SpacemanDMM_protected
#else
	#define RETURN_TYPE(X)
	#define SHOULD_CALL_PARENT(X)
	#define UNLINT(X) X
	#define SHOULD_NOT_OVERRIDE(X)
	#define SHOULD_NOT_SLEEP(X)
	#define SHOULD_BE_PURE(X)
	#define PRIVATE_PROC(X)
	#define PROTECTED_PROC(X)
	#define VAR_FINAL var
	#define VAR_PRIVATE var
	#define VAR_PROTECTED var
#endif

#if defined(UNIT_TESTS)
	#include "config.dm"
	#include "runner_hooks.dm"
	#include "runner.dm"
	#include "unit_test.dm"
	#include "usercode\_includes.dm"
#endif