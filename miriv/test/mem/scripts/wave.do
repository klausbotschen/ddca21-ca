onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/mem_inst/clk
add wave -noupdate /tb/mem_inst/res_n
add wave -noupdate -divider Input
add wave -noupdate /tb/mem_inst/stall
add wave -noupdate /tb/mem_inst/flush
add wave -noupdate /tb/mem_inst/mem_op
add wave -noupdate -expand /tb/mem_inst/wbop_in
add wave -noupdate -radix hexadecimal /tb/mem_inst/pc_new_in
add wave -noupdate -radix hexadecimal /tb/mem_inst/pc_old_in
add wave -noupdate -radix hexadecimal /tb/mem_inst/aluresult_in
add wave -noupdate -radix hexadecimal /tb_cpu/dut/pipeline_inst/mem_inst/wrdata
add wave -noupdate /tb/mem_inst/zero
add wave -noupdate -divider Output
add wave -noupdate /tb/mem_inst/mem_busy
add wave -noupdate /tb_cpu/mem_inst/reg_write
add wave -noupdate -radix hexadecimal /tb/mem_inst/pc_new_out
add wave -noupdate /tb_cpu/mem_inst/pcsrc
add wave -noupdate -expand /tb/mem_inst/wbop_out
add wave -noupdate -radix hexadecimal /tb/mem_inst/pc_old_out
add wave -noupdate -radix hexadecimal /tb/mem_inst/aluresult_out
add wave -noupdate -radix hexadecimal /tb/mem_inst/memresult
add wave -noupdate -childformat {{/tb/mem_inst/mem_out.address -radix hexadecimal} {/tb/mem_inst/mem_out.wrdata -radix hexadecimal}} -expand -subitemconfig {/tb/mem_inst/mem_out.address {-height 16 -radix hexadecimal} /tb/mem_inst/mem_out.wrdata {-height 16 -radix hexadecimal}} /tb/mem_inst/mem_out
add wave -noupdate -childformat {{/tb/mem_inst/mem_in.rddata -radix hexadecimal}} -expand -subitemconfig {/tb/mem_inst/mem_in.rddata {-height 16 -radix hexadecimal}} /tb/mem_inst/mem_in
add wave -noupdate /tb/mem_inst/exc_load
add wave -noupdate /tb/mem_inst/exc_store
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
