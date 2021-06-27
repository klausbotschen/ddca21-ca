onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clk
add wave -noupdate /tb/res_n
add wave -noupdate -divider Input
add wave -noupdate /tb/uut/cs.state
add wave -noupdate /tb/uut/bypass_n
add wave -noupdate -radix hexadecimal /tb/uut/tag_in
add wave -noupdate -radix hexadecimal -childformat {{/tb/uut/index(2) -radix hexadecimal} {/tb/uut/index(1) -radix hexadecimal} {/tb/uut/index(0) -radix hexadecimal}} -subitemconfig {/tb/uut/index(2) {-height 16 -radix hexadecimal} /tb/uut/index(1) {-height 16 -radix hexadecimal} /tb/uut/index(0) {-height 16 -radix hexadecimal}} /tb/uut/index
add wave -noupdate /tb/uut/valid_in
add wave -noupdate /tb/uut/dirty_in
add wave -noupdate /tb/uut/hit
add wave -noupdate -divider mem_out_cpu
add wave -noupdate -radix hexadecimal /tb/uut/mem_out_cpu.address
add wave -noupdate /tb/uut/mem_out_cpu.rd
add wave -noupdate /tb/uut/mem_out_cpu.wr
add wave -noupdate /tb/uut/mem_out_cpu.byteena
add wave -noupdate -radix hexadecimal /tb/uut/mem_out_cpu.wrdata
add wave -noupdate -divider mem_in_mem
add wave -noupdate /tb/uut/mem_in_mem.busy
add wave -noupdate -radix hexadecimal /tb/uut/mem_in_mem.rddata
add wave -noupdate -divider Output
add wave -noupdate -divider mem_in_cpu
add wave -noupdate /tb/uut/mem_in_cpu.busy
add wave -noupdate -radix hexadecimal /tb/uut/mem_in_cpu.rddata
add wave -noupdate -divider mem_out_mem
add wave -noupdate -radix hexadecimal /tb/uut/mem_out_mem.address
add wave -noupdate /tb/uut/mem_out_mem.rd
add wave -noupdate /tb/uut/mem_out_mem.wr
add wave -noupdate /tb/uut/mem_out_mem.byteena
add wave -noupdate -radix hexadecimal /tb/uut/mem_out_mem.wrdata
add wave -noupdate -divider Cache
add wave -noupdate /tb/uut/cmgmnt/rd
add wave -noupdate /tb/uut/cmgmnt/wr
add wave -noupdate -radix hexadecimal /tb/uut/cmgmnt/index
add wave -noupdate /tb/uut/byteena
add wave -noupdate -radix hexadecimal /tb/uut/cdata/data_in
add wave -noupdate -radix hexadecimal /tb/uut/cdata/data_out

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 200
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

run -all
#run 200ns

wave zoom full
