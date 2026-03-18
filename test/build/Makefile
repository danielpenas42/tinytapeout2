# Simple SystemVerilog test runner

SIM ?= vcs

BUILD_DIR    := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
TEST_DIR      := $(abspath $(BUILD_DIR)/..)
PROJECT_ROOT := $(abspath $(TEST_DIR)/..)
RUN_VCS      := $(TEST_DIR)/utils/run_vcs.mk

TEST         ?= 0
GEN_WAVES    ?= True
SIM_ARGS     += +test-case=$(TEST)
WAVE_DIR     ?= $(BUILD_DIR)/waves

RTL_FILES    := $(shell find $(PROJECT_ROOT)/src -type f \( -name '*.v' -o -name '*.sv' \) | sort)
TEST_FILES   := $(wildcard $(TEST_DIR)/*_test.sv)

COMPILE_ARGS += +incdir+$(PROJECT_ROOT)
COMPILE_ARGS += +incdir+$(PROJECT_ROOT)/src
COMPILE_ARGS += +incdir+$(TEST_DIR)
COMPILE_ARGS += +incdir+$(TEST_DIR)/utils
COMPILE_ARGS += +define+GEN_WAVES=$(GEN_WAVES)

.PHONY: %_test help list-tests clean

%_test:
	@mkdir -p $(if $(filter True,$(GEN_WAVES)),$(WAVE_DIR))
	$(MAKE) -f $(RUN_VCS) compile \
		TOP=$@ \
		TEST_DIR=$(TEST_DIR) \
		EXECUTABLE_NAME=$(BUILD_DIR)/simv_$@ \
		SRC_FILES="$(RTL_FILES) $(TEST_DIR)/utils/test_utils.sv $(TEST_FILES)" \
		COMPILE_ARGS="$(COMPILE_ARGS)"
	$(BUILD_DIR)/simv_$@ $(SIM_ARGS) \
		$(if $(filter True,$(GEN_WAVES)),+dump-vcd=$(WAVE_DIR)/$@.vcd,)
	@$(if $(filter True,$(GEN_WAVES)),echo "Waveform: $(WAVE_DIR)/$@.vcd";,)


clean:
	rm -rf \
		$(BUILD_DIR)/simv* \
		$(BUILD_DIR)/csrc \
		$(BUILD_DIR)/*.daidir \
		$(BUILD_DIR)/*.vcd \
		$(BUILD_DIR)/*.ucdb \
		$(WAVE_DIR) \
		$(BUILD_DIR)/ucli.key \
		$(BUILD_DIR)/cm.log \
		$(BUILD_DIR)/.fsm.sch.verilog.xml
