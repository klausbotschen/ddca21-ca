onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_cpu/dut/pipeline_inst/clk
add wave -noupdate /tb_cpu/dut/pipeline_inst/res_n
add wave -noupdate -divider -height 40 fetch
add wave -noupdate -group fetch /tb_cpu/dut/pipeline_inst/fetch_inst/stall
add wave -noupdate -group fetch /tb_cpu/dut/pipeline_inst/fetch_inst/flush
add wave -noupdate -group fetch -radix hexadecimal /tb_cpu/dut/pipeline_inst/fetch_inst/pc_in
add wave -noupdate -group fetch /tb_cpu/dut/pipeline_inst/fetch_inst/pcsrc
add wave -noupdate -group fetch -childformat {{/tb_cpu/dut/pipeline_inst/fetch_inst/mem_in.rddata -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/fetch_inst/mem_in.rddata {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/fetch_inst/mem_in
add wave -noupdate -group fetch -radix hexadecimal /tb_cpu/dut/pipeline_inst/fetch_inst/instr
add wave -noupdate -group fetch /tb_cpu/dut/pipeline_inst/fetch_inst/mem_busy
add wave -noupdate -group fetch -radix hexadecimal /tb_cpu/dut/pipeline_inst/fetch_inst/pc_out
add wave -noupdate -group fetch -childformat {{/tb_cpu/dut/pipeline_inst/fetch_inst/mem_out.address -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/fetch_inst/mem_out.wrdata -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/fetch_inst/mem_out.address {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/fetch_inst/mem_out.wrdata {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/fetch_inst/mem_out
add wave -noupdate -divider -height 40 decode
add wave -noupdate -group decode /tb_cpu/dut/pipeline_inst/decode_inst/stall
add wave -noupdate -group decode /tb_cpu/dut/pipeline_inst/decode_inst/flush
add wave -noupdate -group decode -radix hexadecimal /tb_cpu/dut/pipeline_inst/decode_inst/instr
add wave -noupdate -group decode -radix hexadecimal /tb_cpu/dut/pipeline_inst/decode_inst/inst
add wave -noupdate -group decode -radix hexadecimal /tb_cpu/dut/pipeline_inst/decode_inst/pc_in
add wave -noupdate -group decode -childformat {{/tb_cpu/dut/pipeline_inst/decode_inst/reg_write.reg -radix unsigned} {/tb_cpu/dut/pipeline_inst/decode_inst/reg_write.data -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/decode_inst/reg_write.reg {-height 16 -radix unsigned} /tb_cpu/dut/pipeline_inst/decode_inst/reg_write.data {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/decode_inst/reg_write
add wave -noupdate -group decode -childformat {{/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.rs1 -radix unsigned} {/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.rs2 -radix unsigned} {/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.readdata1 -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.readdata2 -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.imm -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/decode_inst/exec_op.rs1 {-height 16 -radix unsigned} /tb_cpu/dut/pipeline_inst/decode_inst/exec_op.rs2 {-height 16 -radix unsigned} /tb_cpu/dut/pipeline_inst/decode_inst/exec_op.readdata1 {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/exec_op.readdata2 {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/decode_inst/exec_op.imm {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/decode_inst/exec_op
add wave -noupdate -group decode -expand /tb_cpu/dut/pipeline_inst/decode_inst/mem_op
add wave -noupdate -group decode -expand /tb_cpu/dut/pipeline_inst/decode_inst/wb_op
add wave -noupdate -group decode -radix hexadecimal /tb_cpu/dut/pipeline_inst/decode_inst/pc_out
add wave -noupdate -group decode /tb_cpu/dut/pipeline_inst/decode_inst/exc_dec
add wave -noupdate -divider -height 40 regfile
add wave -noupdate -group regfile -radix hexadecimal /tb_cpu/dut/pipeline_inst/decode_inst/regfile_inst/ram
add wave -noupdate -divider -height 40 exec
add wave -noupdate -group exec /tb_cpu/dut/pipeline_inst/exec_inst/stall
add wave -noupdate -group exec /tb_cpu/dut/pipeline_inst/exec_inst/flush
add wave -noupdate -group exec -childformat {{/tb_cpu/dut/pipeline_inst/exec_inst/op_next.rs1 -radix unsigned} {/tb_cpu/dut/pipeline_inst/exec_inst/op_next.rs2 -radix unsigned} {/tb_cpu/dut/pipeline_inst/exec_inst/op_next.readdata1 -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/exec_inst/op_next.readdata2 -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/exec_inst/op_next.imm -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/exec_inst/op_next.rs1 {-height 16 -radix unsigned} /tb_cpu/dut/pipeline_inst/exec_inst/op_next.rs2 {-height 16 -radix unsigned} /tb_cpu/dut/pipeline_inst/exec_inst/op_next.readdata1 {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/exec_inst/op_next.readdata2 {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/exec_inst/op_next.imm {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/exec_inst/op_next
add wave -noupdate -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/exec_inst/pc_in
add wave -noupdate -group exec -childformat {{/tb_cpu/dut/pipeline_inst/exec_inst/reg_write_mem.reg -radix unsigned} {/tb_cpu/dut/pipeline_inst/exec_inst/reg_write_mem.data -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/exec_inst/reg_write_mem.reg {-height 16 -radix unsigned} /tb_cpu/dut/pipeline_inst/exec_inst/reg_write_mem.data {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/exec_inst/reg_write_mem
add wave -noupdate -group exec /tb_cpu/dut/pipeline_inst/exec_inst/reg_write_wr
add wave -noupdate -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/exec_inst/pc_new_out
add wave -noupdate -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/exec_inst/pc_old_out
add wave -noupdate -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/exec_inst/aluresult
add wave -noupdate -group exec /tb_cpu/dut/pipeline_inst/exec_inst/zero
add wave -noupdate -group exec -radix hexadecimal /tb_cpu/dut/pipeline_inst/exec_inst/wrdata
add wave -noupdate -divider forwarding
add wave -noupdate /tb_cpu/dut/pipeline_inst/exec_inst/fwd1
add wave -noupdate /tb_cpu/dut/pipeline_inst/exec_inst/fwd2
add wave -noupdate -radix hexadecimal /tb_cpu/dut/pipeline_inst/exec_inst/readdata2
add wave -noupdate -radix hexadecimal /tb_cpu/dut/pipeline_inst/exec_inst/readdata1
add wave -noupdate -divider -height 40 fwd1
add wave -noupdate -expand -group fwd1 -childformat {{/tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/reg_write_mem.reg -radix unsigned} {/tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/reg_write_mem.data -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/reg_write_mem.reg {-radix unsigned} /tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/reg_write_mem.data {-radix hexadecimal}} /tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/reg_write_mem
add wave -noupdate -expand -group fwd1 -childformat {{/tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/reg_write_wb.reg -radix unsigned} {/tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/reg_write_wb.data -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/reg_write_wb.reg {-radix unsigned} /tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/reg_write_wb.data {-radix hexadecimal}} /tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/reg_write_wb
add wave -noupdate -expand -group fwd1 -radix unsigned /tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/reg
add wave -noupdate -expand -group fwd1 -radix hexadecimal /tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/val
add wave -noupdate -expand -group fwd1 /tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/do_fwd
add wave -noupdate -divider -height 40 fwd2
add wave -noupdate -expand -group fwd2 -childformat {{/tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst2/reg_write_mem.reg -radix unsigned} {/tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/reg_write_mem.data -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/reg_write_mem.reg {-radix unsigned} /tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/reg_write_mem.data {-radix hexadecimal}} /tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/reg_write_mem
add wave -noupdate -expand -group fwd2 -childformat {{/tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst2/reg_write_wb.reg -radix unsigned} {/tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/reg_write_wb.data -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/reg_write_wb.reg {-radix unsigned} /tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/reg_write_wb.data {-radix hexadecimal}} /tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst1/reg_write_wb
add wave -noupdate -expand -group fwd2 -radix unsigned /tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst2/reg
add wave -noupdate -expand -group fwd2 -radix hexadecimal /tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst2/val
add wave -noupdate -expand -group fwd2 /tb_cpu/dut/pipeline_inst/exec_inst/fwd_inst2/do_fwd
add wave -noupdate -divider -height 40 mem
add wave -noupdate -group mem /tb_cpu/dut/pipeline_inst/mem_inst/stall
add wave -noupdate -group mem /tb_cpu/dut/pipeline_inst/mem_inst/flush
add wave -noupdate -group mem /tb_cpu/dut/pipeline_inst/mem_inst/mem_op
add wave -noupdate -group mem /tb_cpu/dut/pipeline_inst/mem_inst/zero
add wave -noupdate -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/mem_inst/wrdata
add wave -noupdate -group mem /tb_cpu/dut/pipeline_inst/mem_inst/mem_busy
add wave -noupdate -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/mem_inst/memresult
add wave -noupdate -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/mem_inst/pc_new_in
add wave -noupdate -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/mem_inst/pc_new_out
add wave -noupdate -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/mem_inst/pc_old_in
add wave -noupdate -group mem -radix hexadecimal /tb_cpu/dut/pipeline_inst/mem_inst/pc_old_out
add wave -noupdate -group mem /tb_cpu/dut/pipeline_inst/mem_inst/pcsrc
add wave -noupdate -group mem /tb_cpu/dut/pipeline_inst/mem_inst/reg_write
add wave -noupdate -group mem -childformat {{/tb_cpu/dut/pipeline_inst/mem_inst/mem_in.rddata -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/mem_inst/mem_in.rddata {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/mem_inst/mem_in
add wave -noupdate -group mem -childformat {{/tb_cpu/dut/pipeline_inst/mem_inst/mem_out.address -radix hexadecimal} {/tb_cpu/dut/pipeline_inst/mem_inst/mem_out.wrdata -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/mem_inst/mem_out.address {-height 16 -radix hexadecimal} /tb_cpu/dut/pipeline_inst/mem_inst/mem_out.wrdata {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/mem_inst/mem_out
add wave -noupdate -divider -height 40 wb
add wave -noupdate -group wb /tb_cpu/dut/pipeline_inst/wb_inst/stall
add wave -noupdate -group wb /tb_cpu/dut/pipeline_inst/wb_inst/flush
add wave -noupdate -group wb /tb_cpu/dut/pipeline_inst/wb_inst/op_next
add wave -noupdate -group wb -radix hexadecimal /tb_cpu/dut/pipeline_inst/wb_inst/aluresult_next
add wave -noupdate -group wb -radix hexadecimal /tb_cpu/dut/pipeline_inst/wb_inst/memresult_next
add wave -noupdate -group wb -radix hexadecimal /tb_cpu/dut/pipeline_inst/wb_inst/pc_old_in_next
add wave -noupdate -group wb -childformat {{/tb_cpu/dut/pipeline_inst/wb_inst/reg_write.reg -radix unsigned} {/tb_cpu/dut/pipeline_inst/wb_inst/reg_write.data -radix hexadecimal}} -expand -subitemconfig {/tb_cpu/dut/pipeline_inst/wb_inst/reg_write.reg {-height 16 -radix unsigned} /tb_cpu/dut/pipeline_inst/wb_inst/reg_write.data {-height 16 -radix hexadecimal}} /tb_cpu/dut/pipeline_inst/wb_inst/reg_write
add wave -noupdate -divider -height 40 Cache
add wave -noupdate /tb_cpu/dut/cache_inst/cs.state
add wave -noupdate /tb_cpu/dut/cache_inst/bypass_n
add wave -noupdate /tb_cpu/dut/cache_inst/byteena
add wave -noupdate -radix hexadecimal /tb_cpu/dut/cache_inst/index
add wave -noupdate /tb_cpu/dut/cache_inst/rd
add wave -noupdate /tb_cpu/dut/cache_inst/wr
add wave -noupdate /tb_cpu/dut/cache_inst/hit
add wave -noupdate /tb_cpu/dut/cache_inst/tag_out
add wave -noupdate /tb_cpu/dut/cache_inst/dirty_out
add wave -noupdate /tb_cpu/dut/cache_inst/valid_out
add wave -noupdate -radix hexadecimal /tb_cpu/dut/cache_inst/data_in
add wave -noupdate -radix hexadecimal /tb_cpu/dut/cache_inst/data_out
add wave -noupdate -divider mem_out_mem
add wave -noupdate -radix hexadecimal /tb_cpu/dut/cache_inst/mem_out_mem.address
add wave -noupdate /tb_cpu/dut/cache_inst/mem_out_mem.rd
add wave -noupdate /tb_cpu/dut/cache_inst/mem_out_mem.wr
add wave -noupdate /tb_cpu/dut/cache_inst/mem_out_mem.byteena
add wave -noupdate -radix hexadecimal /tb_cpu/dut/cache_inst/mem_out_mem.wrdata
add wave -noupdate -divider mem_in_mem
add wave -noupdate /tb_cpu/dut/cache_inst/mem_in_mem.busy
add wave -noupdate -radix hexadecimal /tb_cpu/dut/cache_inst/mem_in_mem.rddata
TreeUpdate [SetDefaultTree]
quietly wave cursor active 1
configure wave -namecolwidth 200
configure wave -valuecolwidth 150
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
run 3us
wave zoom full
