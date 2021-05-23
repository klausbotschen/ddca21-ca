onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/wb_inst/clk
add wave -noupdate /tb/wb_inst/res_n
add wave -noupdate -divider Input
add wave -noupdate /tb/wb_inst/stall
add wave -noupdate /tb/wb_inst/flush
add wave -noupdate /tb/wb_inst/op
add wave -noupdate -radix hexadecimal /tb/wb_inst/aluresult
add wave -noupdate -radix hexadecimal /tb/wb_inst/memresult
add wave -noupdate -radix hexadecimal /tb/wb_inst/pc_old_in
add wave -noupdate -divider Output
add wave -noupdate -childformat {{/tb/wb_inst/reg_write.reg -radix unsigned} {/tb/wb_inst/reg_write.data -radix hexadecimal}} -expand -subitemconfig {/tb/wb_inst/reg_write.reg {-height 16 -radix unsigned} /tb/wb_inst/reg_write.data {-height 16 -radix hexadecimal}} /tb/wb_inst/reg_write
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
