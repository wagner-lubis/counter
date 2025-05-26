####################################################
# Copyright(c) LUBIS EDA GmbH, All rights reserved #
# Contact: contact@lubis-eda.com                   #
####################################################

# TCL-script for JasperGold (Cadence)

################################################################################
# Configuration

################################################################################
# Script - No change required below this line

# Clear GUI windows
clear -all

# Change working directory to the directory of the script
# Eliminate every symbolic link
set script_path [file dirname [file dirname [file normalize [info script]/___]]]
cd $script_path


######################
# Tool Configuration #
set_parallel_synthesis_mode on
set_parallel_synthesis_num_process 16

########################
# Prover Configuration #
set_proofmaster off
set_prove_orchestration on
set_prove_invariants_import on

########################
# Engine Orchestration #
set_engine_mode auto

#######################
# Load Design and AIP #
analyze -sv12 +define+SCENARIO_8_BIT=1 ../../rtl/counter.sv

analyze -sv12 +define+SCENARIO_8_BIT=1 +incdir+../../rtl ../../properties/fv_counter.sv
analyze -sv12 +define+SCENARIO_8_BIT=1 +incdir+../../rtl ../../properties/fv_constraints.sv
analyze -sv12 +define+SCENARIO_8_BIT=1 +incdir+../../rtl ../../properties/fv_scenarios.sv
analyze -sv12 +define+SCENARIO_8_BIT=1 +incdir+../../rtl ../../properties/fv_top_aip.sv


set_elaborate_single_run_mode off
set_capture_elaborated_design on
check_cov -init -exclude_bind_hierarchies -enable_checker_undetectable -include_assign_scoring

###############
# Elaboration #
set_task_compile_time_limit 30m
set_property_compile_time_limit 10m

elaborate\
    -create_related_covers {precondition witness}\
    -disable_auto_bbox\
    -top customer_counter\
    -parameter WIDTH 8

clock clk

reset {
     rst
}

# Configure default task

set_prove_per_property_time_limit 2s
