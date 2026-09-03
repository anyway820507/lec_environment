# Cadence Conformal Equivalence Checker: RTL-to-netlist example
# Run: lec -nogui -tclmode -dofile rtl_to_netlist_lec.tcl

tclmode
set_dofile_abort on

# User configuration: use the exact inputs/options from synthesis.
set TOP_MODULE top
set LOG_FILE ./logs/rtl_to_netlist_lec.log

set GOLDEN_FILES [list \
    ./rtl/top.v \
    ./rtl/alu.v \
    ./rtl/control.v \
]

set NETLIST_FILES [list \
    ./netlist/top_netlist.v \
]

# Some flows require vendor Verilog cell models instead. Match the synthesis
# and site-specific Conformal setup rather than guessing a library format.
set LIBERTY_FILES [list \
    ./libs/slow.lib \
]

foreach path [concat $GOLDEN_FILES $NETLIST_FILES $LIBERTY_FILES] {
    if {![file isfile $path]} { error "Required input does not exist: $path" }
}
if {![file isdirectory [file dirname $LOG_FILE]]} {
    error "Log directory does not exist: [file dirname $LOG_FILE]"
}

set_log_file $LOG_FILE -replace
read_library $LIBERTY_FILES -liberty -both

# Add the same SystemVerilog mode, include directories, macro defines and
# parameters used by synthesis. A .vg file is still a Verilog netlist.
read_design $GOLDEN_FILES -verilog -golden -root $TOP_MODULE
read_design $NETLIST_FILES -verilog -revised -root $TOP_MODULE

# Add functional-mode constraints before LEC mode (for example scan_enable=0),
# plus synthesis-specific clock-gating, retiming or sequential mapping setup.
report_design_data
report_black_box -detail

# This is a flat comparison template. Prefer a generated hierarchical compare
# flow for large RTL-to-gate designs.
set_system_mode lec
add_compared_points -all
compare

report_verification
report_compared_points
report_unmapped_points

set_exit_code -verbose
exit -force
