onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clk
add wave -noupdate /tb/res_n
add wave -noupdate -divider Input
add wave -noupdate /tb/fetch_inst/stall
add wave -noupdate /tb/fetch_inst/flush
add wave -noupdate /tb/fetch_inst/pcsrc
add wave -noupdate -radix unsigned /tb/fetch_inst/pc_in
add wave -noupdate /tb/fetch_inst/mem_in.busy
add wave -noupdate -radix hex /tb/fetch_inst/mem_in.rddata
add wave -noupdate -divider Output
add wave -noupdate /tb/fetch_inst/mem_busy
add wave -noupdate -radix unsigned /tb/fetch_inst/pc_out
add wave -noupdate -radix hex /tb/fetch_inst/instr
add wave -noupdate -radix unsigned /tb/fetch_inst/mem_out.address
add wave -noupdate /tb/fetch_inst/mem_out.rd
add wave -noupdate /tb/fetch_inst/mem_out.wr
add wave -noupdate -radix hex /tb/fetch_inst/mem_out.byteena
add wave -noupdate -radix hex /tb/fetch_inst/mem_out.wrdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
wave zoom full
