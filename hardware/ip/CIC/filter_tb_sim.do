onbreak resume
onerror resume
vsim -novopt work.filter_tb
add wave sim:/filter_tb/u_CIC_10d/clk
add wave sim:/filter_tb/u_CIC_10d/clk_enable
add wave sim:/filter_tb/u_CIC_10d/reset
add wave sim:/filter_tb/u_CIC_10d/filter_in
add wave sim:/filter_tb/u_CIC_10d/filter_out
add wave sim:/filter_tb/filter_out_ref
add wave sim:/filter_tb/u_CIC_10d/ce_out
run -all
