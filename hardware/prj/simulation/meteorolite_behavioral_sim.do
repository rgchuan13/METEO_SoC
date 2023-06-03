#
# Create work library
#
vlib work
#
# Compile sources
#
vlog  E:/TD/workspace/meteorolite/hardware/ip/pll_0.v
vlog  E:/TD/workspace/meteorolite/hardware/prj/simulation/pll_0_tb.v
#
# Call vsim to invoke simulator
#
vsim -L E:/TD/sim_release -gui -novopt work.pll_0_tb
#
# Add waves
#
add wave *
#
# Run simulation
#
run 1000ns
#
# End