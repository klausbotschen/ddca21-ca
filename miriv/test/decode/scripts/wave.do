onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb/clk
add wave -noupdate /tb/res_n

add wave -noupdate -divider Input
add wave -noupdate /tb/uut/stall
add wave -noupdate /tb/uut/flush
add wave -noupdate -radix unsigned /tb/uut/pc_in
add wave -noupdate -radix hex /tb/uut/instr
add wave -noupdate /tb/uut/reg_write.write
add wave -noupdate -radix hex /tb/uut/reg_write.reg
add wave -noupdate -radix hex /tb/uut/reg_write.data

add wave -noupdate -divider Output
add wave -noupdate -radix unsigned /tb/uut/pc_out

add wave -noupdate /tb/uut/exec_op.aluop
add wave -noupdate /tb/uut/exec_op.alusrc1
add wave -noupdate /tb/uut/exec_op.alusrc2
add wave -noupdate /tb/uut/exec_op.alusrc3
add wave -noupdate -radix hex /tb/uut/exec_op.rs1
add wave -noupdate -radix hex /tb/uut/exec_op.rs2
add wave -noupdate -radix hex /tb/uut/exec_op.readdata1
add wave -noupdate -radix hex /tb/uut/exec_op.readdata2
add wave -noupdate -radix hex /tb/uut/exec_op.imm

add wave -noupdate /tb/uut/mem_op.branch
add wave -noupdate /tb/uut/mem_op.mem.memread
add wave -noupdate /tb/uut/mem_op.mem.memwrite
add wave -noupdate /tb/uut/mem_op.mem.memtype

add wave -noupdate /tb/uut/wb_op.rd
add wave -noupdate /tb/uut/wb_op.write
add wave -noupdate -radix hex /tb/uut/wb_op.src

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
