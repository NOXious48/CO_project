`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// File: processor_top.v (improved - exposes debug_step, configurable trace_enable)
//////////////////////////////////////////////////////////////////////////////////

module processor_top (
    input  wire        clk,
    input  wire        reset,
    input  wire        debug_enable,
    input  wire        debug_step_btn,
    input  wire        trace_enable,       // NEW: control trace buffer externally

    // Debug outputs (connect to LEDs or display)
    output wire [15:0] debug_pc,
    output wire [15:0] debug_instruction,
    output wire [2:0]  debug_state,
    output wire [15:0] debug_reg0,
    output wire [15:0] debug_reg1,
    output wire [15:0] debug_reg2,
    output wire [15:0] debug_reg3,
    output wire [15:0] debug_reg4,
    output wire [15:0] debug_reg5,
    output wire [15:0] debug_reg6,
    output wire [15:0] debug_reg7,
    output wire [31:0] cycle_count,

    // Trace buffer outputs
    output wire [15:0] trace_buf0, trace_buf1, trace_buf2, trace_buf3,
    output wire [15:0] trace_buf4, trace_buf5, trace_buf6, trace_buf7,
    output wire [15:0] trace_buf8, trace_buf9, trace_buf10, trace_buf11,
    output wire [15:0] trace_buf12, trace_buf13, trace_buf14, trace_buf15,
    output wire [3:0]  trace_count,

    // DEBUG OBSERVABILITY (exposed)
    output wire        debug_step_out      // NEW: shows debug_step from debug_interface
);

    // Internal wires - Controller to Datapath
    wire        pc_write, mem_read, mem_write, ir_write, reg_write;
    wire [1:0]  alu_op, pc_src;
    wire        alu_src_a, alu_src_b, mem_to_reg;
    wire [2:0]  state_out;

    // Datapath to Controller
    wire        zero_flag;
    wire [3:0]  opcode;

    // Memory interface
    wire [7:0]  mem_addr;
    wire [15:0] mem_data_in, mem_data_out;

    // Datapath outputs
    wire [15:0] pc_out, instruction_out;
    wire [15:0] reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7;

    // Debug interface
    wire        debug_step;

    // Instantiate Controller (Student A)
    controller ctrl (
        .clk(clk),
        .reset(reset),
        .debug_step(debug_step),
        .opcode(opcode),
        .zero_flag(zero_flag),
        .pc_write(pc_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .ir_write(ir_write),
        .reg_write(reg_write),
        .alu_op(alu_op),
        .pc_src(pc_src),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .mem_to_reg(mem_to_reg),
        .state_out(state_out)
    );

    // Instantiate Datapath (Student B)
    datapath dp (
        .clk(clk),
        .reset(reset),
        .pc_write(pc_write),
        .ir_write(ir_write),
        .reg_write(reg_write),
        .alu_op(alu_op),
        .pc_src(pc_src),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .mem_to_reg(mem_to_reg),
        .state_in(state_out),
        .mem_data_in(mem_data_in),
        .mem_addr(mem_addr),
        .mem_data_out(mem_data_out),
        .pc_out(pc_out),
        .instruction_out(instruction_out),
        .zero_flag(zero_flag),
        .opcode_out(opcode),
        .reg0(reg0),
        .reg1(reg1),
        .reg2(reg2),
        .reg3(reg3),
        .reg4(reg4),
        .reg5(reg5),
        .reg6(reg6),
        .reg7(reg7)
    );

    // Instantiate Debug Interface (Student C)
    debug_interface dbg (
        .clk(clk),
        .reset(reset),
        .debug_enable(debug_enable),
        .debug_step_btn(debug_step_btn),
        .pc_in(pc_out),
        .instruction_in(instruction_out),
        .state_in(state_out),
        .reg0(reg0),
        .reg1(reg1),
        .reg2(reg2),
        .reg3(reg3),
        .reg4(reg4),
        .reg5(reg5),
        .reg6(reg6),
        .reg7(reg7),
        .debug_step(debug_step),
        .debug_pc(debug_pc),
        .debug_ir(debug_instruction),
        .debug_state(debug_state),
        .debug_reg0(debug_reg0),
        .debug_reg1(debug_reg1),
        .debug_reg2(debug_reg2),
        .debug_reg3(debug_reg3),
        .debug_reg4(debug_reg4),
        .debug_reg5(debug_reg5),
        .debug_reg6(debug_reg6),
        .debug_reg7(debug_reg7),
        .cycle_count(cycle_count)
    );

    // Expose debug_step so we can probe it easily in simulation/waveform
    assign debug_step_out = debug_step;

    // Instantiate Memory and Trace Buffer (Student D)
    memory_trace mem (
        .clk(clk),
        .reset(reset),
        .addr(mem_addr),
        .data_in(mem_data_out),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .data_out(mem_data_in),
        .trace_pc(pc_out),
        .trace_instruction(instruction_out),
        .trace_state(state_out),
        .trace_enable(trace_enable),   // now controlled from top-level
        .trace_buf0(trace_buf0),
        .trace_buf1(trace_buf1),
        .trace_buf2(trace_buf2),
        .trace_buf3(trace_buf3),
        .trace_buf4(trace_buf4),
        .trace_buf5(trace_buf5),
        .trace_buf6(trace_buf6),
        .trace_buf7(trace_buf7),
        .trace_buf8(trace_buf8),
        .trace_buf9(trace_buf9),
        .trace_buf10(trace_buf10),
        .trace_buf11(trace_buf11),
        .trace_buf12(trace_buf12),
        .trace_buf13(trace_buf13),
        .trace_buf14(trace_buf14),
        .trace_buf15(trace_buf15),
        .trace_count(trace_count)
    );

endmodule
