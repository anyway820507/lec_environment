# Cadence Conformal Equivalence Checker: RTL-to-RTL example
# Run: lec -nogui -tclmode -dofile rtl_to_rtl_lec.tcl

tclmode
set_dofile_abort on

# User configuration: replace every example value for the target design.
# Relative paths are resolved from the directory where lec is launched.
set TOP_MODULE top
set LOG_FILE ./logs/rtl_to_rtl_lec.log

set GOLDEN_FILES [list \
    ./rtl/golden/top.v \
    ./rtl/golden/alu.v \
    ./rtl/golden/control.v \
]

set REVISED_FILES [list \
    ./rtl/revised/top.v \
    ./rtl/revised/alu.v \
    ./rtl/revised/control.v \
]

# Fail early instead of turning a typo into a misleading elaboration error.
foreach path [concat $GOLDEN_FILES $REVISED_FILES] {
    if {![file isfile $path]} { error "Required input does not exist: $path" }
}
if {![file isdirectory [file dirname $LOG_FILE]]} {
    error "Log directory does not exist: [file dirname $LOG_FILE]"
}

set_log_file $LOG_FILE -replace

# Add release-specific SystemVerilog, include, define, parameter, or language
# options here when needed.
read_design $GOLDEN_FILES -verilog -golden -root $TOP_MODULE
read_design $REVISED_FILES -verilog -revised -root $TOP_MODULE

# Add functional constraints before LEC mode. Examples include tying
# scan_enable/test_mode inactive and aligning reset assumptions.
report_design_data
report_black_box -detail

set_system_mode lec
add_compared_points -all
compare

# PASS is meaningful only after reviewing coverage and exceptional points.
report_verification
report_compared_points
report_unmapped_points

set_exit_code -verbose
exit -force
