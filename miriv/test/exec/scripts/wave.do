onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/exec_inst/clk
add wave -noupdate /tb/exec_inst/res_n
add wave -noupdate -divider Input
add wave -noupdate /tb/exec_inst/stall
add wave -noupdate /tb/exec_inst/flush
add wave -noupdate -childformat {{/tb/exec_inst/op.rs1 -radix unsigned} {/tb/exec_inst/op.rs2 -radix unsigned} {/tb/exec_inst/op.readdata1 -radix hexadecimal} {/tb/exec_inst/op.readdata2 -radix hexadecimal} {/tb/exec_inst/op.imm -radix hexadecimal}} -expand -subitemconfig {/tb/exec_inst/op.rs1 {-height 16 -radix unsigned} /tb/exec_inst/op.rs2 {-height 16 -radix unsigned} /tb/exec_inst/op.readdata1 {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/exec_inst/op.readdata2 {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/exec_inst/op.imm {-height 16 -radix hexadecimal}} /tb/exec_inst/op
add wave -noupdate -radix hexadecimal /tb/exec_inst/pc_in
add wave -noupdate -expand /tb/exec_inst/memop_in
add wave -noupdate -expand /tb/exec_inst/wbop_in
add wave -noupdate -childformat {{/tb/exec_inst/reg_write_mem.reg -radix unsigned} {/tb/exec_inst/reg_write_mem.data -radix hexadecimal}} -expand -subitemconfig {/tb/exec_inst/reg_write_mem.reg {-height 16 -radix unsigned} /tb/exec_inst/reg_write_mem.data {-height 16 -radix hexadecimal}} /tb/exec_inst/reg_write_mem
add wave -noupdate /tb/exec_inst/reg_write_wr
add wave -noupdate -divider Output
add wave -noupdate -radix hexadecimal /tb/exec_inst/pc_new_out
add wave -noupdate -radix hexadecimal /tb/exec_inst/pc_old_out
add wave -noupdate -radix hexadecimal /tb/exec_inst/aluresult
add wave -noupdate /tb/exec_inst/zero
add wave -noupdate -radix hexadecimal /tb/exec_inst/wrdata
add wave -noupdate -expand /tb/exec_inst/memop_out
add wave -noupdate -expand /tb/exec_inst/wbop_out
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
WaveRestoreZoom {0 ps} {5250 ns}
