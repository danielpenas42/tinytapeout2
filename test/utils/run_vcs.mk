# Parameters: ------------------------------------------------------------
TOP ?= tb
EXECUTABLE_NAME ?= simv
TEST_DIR ?= .
MODULES_FILE ?=
SRC_FILES ?=

# If MODULES_FILE is set, compile with -f. Otherwise use explicit files.
FILE_LIST_OPT :=
ifneq ($(strip $(MODULES_FILE)),)
	FILE_LIST_OPT := -f $(TEST_DIR)/$(MODULES_FILE)
else
	FILE_LIST_OPT := $(SRC_FILES)
endif

compile:
	vcs -sverilog -full64 -debug_access+all \
	-timescale=1ns/1ps \
	$(FILE_LIST_OPT) \
	-top $(TOP) \
	-o $(EXECUTABLE_NAME) \
	$(COMPILE_ARGS)
