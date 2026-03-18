# Simple SystemVerilog test runner

SIM ?= vcs
YOSYS ?= yosys

TEST_DIR     := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
BUILD_DIR    := $(TEST_DIR)/build
PROJECT_ROOT := $(abspath $(TEST_DIR)/..)
RUN_VCS      := $(TEST_DIR)/utils/run_vcs.mk

TEST         ?= 0
GEN_WAVES    ?= True
SIM_ARGS     += +test-case=$(TEST)
WAVE_DIR     ?= $(BUILD_DIR)/waves
TOP_MODULE   ?= tinytapeout
LIBERTY      ?= $(TEST_DIR)/utils/sg13g2_stdcell_typ_1p20V_25C.lib
ESTIMATE_LOG ?= $(BUILD_DIR)/$(TOP_MODULE)_estimate.log

RTL_FILES    := $(shell find $(PROJECT_ROOT)/src -type f \( -name '*.v' -o -name '*.sv' \) | sort)
TEST_FILES   := $(wildcard $(TEST_DIR)/*_test.sv)

COMPILE_ARGS += +incdir+$(PROJECT_ROOT)
COMPILE_ARGS += +incdir+$(PROJECT_ROOT)/src
COMPILE_ARGS += +incdir+$(TEST_DIR)
COMPILE_ARGS += +incdir+$(TEST_DIR)/utils
COMPILE_ARGS += +define+GEN_WAVES=$(GEN_WAVES)

.PHONY: %_test estimate estimate-% help list-tests clean

%_test:
	@mkdir -p $(BUILD_DIR) $(if $(filter True,$(GEN_WAVES)),$(WAVE_DIR))
	$(MAKE) -f $(RUN_VCS) compile \
		TOP=$@ \
		TEST_DIR=$(TEST_DIR) \
		EXECUTABLE_NAME=$(BUILD_DIR)/simv_$@ \
		SRC_FILES="$(RTL_FILES) $(TEST_DIR)/utils/test_utils.sv $(TEST_FILES)" \
		COMPILE_ARGS="$(COMPILE_ARGS)"
	$(BUILD_DIR)/simv_$@ $(SIM_ARGS) \
		$(if $(filter True,$(GEN_WAVES)),+dump-vcd=$(WAVE_DIR)/$@.vcd,)
	@$(if $(filter True,$(GEN_WAVES)),echo "Waveform: $(WAVE_DIR)/$@.vcd";,)

estimate:
	@mkdir -p $(BUILD_DIR)
	$(YOSYS) -l $(ESTIMATE_LOG) -p "read_verilog $(RTL_FILES); hierarchy -check -top $(TOP_MODULE); synth -top $(TOP_MODULE); dfflibmap -liberty $(LIBERTY); abc -liberty $(LIBERTY); stat -liberty $(LIBERTY)"
	@echo "Estimate log: $(ESTIMATE_LOG)"

estimate-%:
	@$(MAKE) estimate TOP_MODULE=$*


clean:
	rm -rf $(BUILD_DIR)
