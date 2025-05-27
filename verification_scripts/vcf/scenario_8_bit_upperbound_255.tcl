####################################################
# Copyright(c) LUBIS EDA GmbH, All rights reserved #
# Contact: contact@lubis-eda.com                   #
####################################################

# TCL-script for VC Formal (Synopsys)

################################################################################
# Configuration

# Select the way how VCF is informed about reset signals
# When 1: Tell VCF about reset signals and don't create a constraint that permanently disables them
# When 0: Tell VCF about reset signals and       create a constraint that permanently disables them
set reset_without_constraint 1

################################################################################
# Script - No change required below this line

# Change working directory to the directory of the script
# Eliminate every symbolic link
set script_path [file dirname [file dirname [file normalize [info script]/___]]]


#################
# Configure VCF #
#################
set_fml_appmode FPV
set_app_var apply_bind_in_all_units true
set_app_var analyze_skip_translate_body false
set_app_var fml_auto_save default
set_app_var fml_composite_trace true
set_fml_var fml_witness_on true
set_fml_var fml_vacuity_on true


###############
# Load Design #
###############
set design_path $script_path/../../rtl

analyze -format sverilog -vcs " +incdir+$design_path +define+SCENARIO_8_BIT=1 " [subst {
    $design_path/counter.sv
}]


#######################
# Load Property Suite #
#######################
set property_path $script_path/../../properties

analyze -format sverilog -vcs " -assert svaext +incdir+$design_path +define+SCENARIO_8_BIT=1 " [subst {
    $property_path/fv_counter.sv
    $property_path/fv_constraints.sv
    $property_path/fv_scenarios.sv
    $property_path/fv_top_aip.sv
}]


elaborate customer_counter -vcs "-pvalue+WIDTH=8 " -verbose -sva


##########################
# Configure Verification #
##########################
create_clock clk -period 200

set_change_at -default -clock clk -posedge

# Problem (page 51 VC formal manual):
# Reset high, "create_reset rst -sense high" is the same as:
# sim_force rst -apply 1'b1
# set_constant rst -apply 1'b0
# This creates a constraint that sets reset to constant 0 which prevents any proofs
# that start from reset.
if {$reset_without_constraint} {
    sim_force rst -apply 1'b1
} else {
    create_reset rst -sense high
}


