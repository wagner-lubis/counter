####################################################
# Copyright(c) LUBIS EDA GmbH, All rights reserved #
# Contact: contact@lubis-eda.com                   #
####################################################

# TCL-script for OneSpin (Siemens EDA)


################################################################################
# Script - No change required below this line

# Change working directory to the directory of the script
# Eliminate every symbolic link
set script_path [file dirname [file dirname [file normalize [info script]/___]]]
cd $script_path


# Start logging
start_message_log -force ./prove.log


# Re-run setup in case this script was already executed
#re_setup
set_mode setup
delete_design -both
remove_server -all

set_session_option -naming_style sv


# Load Setup Database
set setup_database_name setup.onespin
if {$use_setup_database && [file isdirectory $setup_database_name]} {
    cd $script_path
    load_database -force $setup_database_name
} else {

###############
# Load Design #
# Use the SystemVerilog standard SV2012
cd ../../rtl
set_read_hdl_option -golden -verilog_include_path {
    ./
}
set_read_hdl_option -golden -verilog_define {
    DEFAULT_UPPERBOUND=1
}
read_verilog -golden -version sv2012 {
    counter.sv
}

cd $script_path


####################
# Elaborate Design #
set_elaborate_option -golden -verilog_parameter { WIDTH=4 }
set_elaborate_option -golden -top customer_counter
elaborate            -golden


##################
# Compile Design #
set_compile_option   -golden -clock { {clk} }
set_compile_option   -golden -undriven_value input
compile              -golden


###############
# Final Setup #
set_clock_spec -period 2 clk

set_reset_sequence -golden { { rst=1 } }


##########################
# Configure Verification #
set_mode mv

# Save Setup Database
if {$use_setup_database} {
    cd $script_path
    save_database -force $setup_database_name
}

}

cd ../../properties
set_read_sva_option -define {
    DEFAULT_UPPERBOUND=1
}
read_sva -version sv2012 -include_path {
    ../rtl
} {
    fv_counter.sv
    fv_constraints.sv
    fv_scenarios.sv
    fv_top_aip.sv
}

cd $script_path




set_limit -check_real_time 2
