onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_cpu/dut/pipeline_inst/clk
add wave -noupdate /tb_cpu/dut/pipeline_inst/res_n
add wave -noupdate -divider -height 40 fetch
add wave -noupdate -group fetch -radix hexadecimal /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in
add wave -noupdate -group fetch /tb_cpu/dut/pipeline_inst/fetch_inst/pcsrc
add wave -noupdate -group fetch -radix hexadecimal /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out
add wave -noupdate -group fetch -radix hexadecimal /tb_cpu/dut/pipeline_inst/fetch_inst/instr
add wave -noupdate -divider -height 40 decode
add wave -noupdate -group decode -radix hexadecimal /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/ram(4)
add wave -noupdate -group decode -radix hexadecimal /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/ram(5)
add wave -noupdate -group decode -radix hexadecimal /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/ram(6)
add wave -noupdate -group decode -radix hexadecimal /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/ram(7)
add wave -noupdate -group decode /tb_cpu/dut/pipeline_inst/decode_inst/exc_dec
add wave -noupdate -divider -height 40 exec
add wave -noupdate -group exec -childformat {{/tb_cpu/dut/pipeline_inst/exec_inst/op.rs1 -radix unsigned} {/tb_cpu/dut/pipeline_inst/exec_inst/op.rs2 -radix unsigned} {/tb_cpu/dut/pipeline_inst/exec_inst/op.readdata1 -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/exec_inst/op.readdata2 -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/exec_inst/op.imm -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/exec_inst/op.rs1 {-height 16 -radix unsigned} /tb_cpu/dut/pipeline_inst/exec_inst/op.rs2 {-height 16 -radix unsigned} /tb_cpu/dut/pipeline_inst/exec_inst/op.readdata1 {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/exec_inst/op.readdata2 {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/exec_inst/op.imm {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/exec_inst/op
add wave -noupdate -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/exec_inst/aluresult
add wave -noupdate -divider -height 40 mem
add wave -noupdate -group mem -childformat {{/tb_cpu/dut/pipeline_inst/mem_inst/mem_out.address -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/mem_inst/mem_out.wrdata -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/mem_inst/mem_out.address {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/mem_inst/mem_out.wrdata {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/mem_inst/mem_out
add wave -noupdate -group mem -childformat {{/tb_cpu/dut/pipeline_inst/mem_inst/mem_in.rddata -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/mem_inst/mem_in.rddata {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/mem_inst/mem_in
TreeUpdate [SetDefaultTree]
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 227
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
configure wave -timelineunits us
update
run 2us
wave zoom full
