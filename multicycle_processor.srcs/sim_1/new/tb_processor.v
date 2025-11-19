`timescale 1ns / 1ps

module tb_processor;

    reg clk;
    reg reset;
    reg debug_enable;
    reg debug_step_btn;
    reg trace_enable;
    
    wire [15:0] debug_pc;
    wire [15:0] debug_instruction;
    wire [2:0]  debug_state;
    wire [15:0] debug_reg0, debug_reg1, debug_reg2, debug_reg3;
    wire [15:0] debug_reg4, debug_reg5, debug_reg6, debug_reg7;
    wire [31:0] cycle_count;
    wire [15:0] trace_buf0, trace_buf1, trace_buf2, trace_buf3;
    wire [15:0] trace_buf4, trace_buf5, trace_buf6, trace_buf7;
    wire [15:0] trace_buf8, trace_buf9, trace_buf10, trace_buf11;
    wire [15:0] trace_buf12, trace_buf13, trace_buf14, trace_buf15;
    wire [3:0] trace_count;
    wire debug_step_out;

    processor_top uut (
        .clk(clk),
        .reset(reset),
        .debug_enable(debug_enable),
        .debug_step_btn(debug_step_btn),
        .trace_enable(trace_enable),
        .debug_pc(debug_pc),
        .debug_instruction(debug_instruction),
        .debug_state(debug_state),
        .debug_reg0(debug_reg0),
        .debug_reg1(debug_reg1),
        .debug_reg2(debug_reg2),
        .debug_reg3(debug_reg3),
        .debug_reg4(debug_reg4),
        .debug_reg5(debug_reg5),
        .debug_reg6(debug_reg6),
        .debug_reg7(debug_reg7),
        .cycle_count(cycle_count),
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
        .trace_count(trace_count),
        .debug_step_out(debug_step_out)
    );

    // 100MHz clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task display_state;
        begin
            $display("T=%0t | PC=%3d | IR=%h | ST=%0d | R1=%3d R2=%3d R3=%3d R4=%3d R5=%3d", 
                     $time, debug_pc[7:0], debug_instruction, debug_state,
                     debug_reg1, debug_reg2, debug_reg3, debug_reg4, debug_reg5);
        end
    endtask
    
    // Enhanced monitoring during WRITEBACK
    always @(posedge clk) begin
        if (!reset && debug_state == 3'b100) begin  // WRITEBACK state
            $display("  WB: reg_write=%b, mem_to_reg=%b, rd=%0d, alu_result=%h, mem_data=%h", 
                     uut.ctrl.reg_write, uut.ctrl.mem_to_reg, uut.dp.rd,
                     uut.dp.alu_result_reg, uut.dp.mem_data_reg);
        end
    end
    
    // Monitor debug_step signal
    always @(posedge clk) begin
        if (!reset)
            $display("T=%0t | debug_step=%b | state=%0d | debug_step_out=%b", 
                     $time, uut.dbg.debug_step, debug_state, debug_step_out);
    end
    
    initial begin
        // Initialize ALL signals
        reset = 1;
        debug_enable = 0;
        debug_step_btn = 0;
        trace_enable = 1;

        $display("\n========================================");
        $display(" MULTICYCLE PROCESSOR TESTBENCH START ");
        $display("========================================");
        $display("Calculating 5! = 120");
        $display("Time  | PC  | Instruction | ST | R1  | R2  | R3  | R4  | R5");
        $display("------+-----+-------------+----+-----+-----+-----+-----+----");

        #30 reset = 0;

        // Wait for completion or timeout
        wait(debug_pc == 29 || $time >= 1000000);

        #100;

        $display("\n========================================");
        $display("           SIMULATION RESULTS");
        $display("========================================");
        $display("Final PC:          %0d", debug_pc);
        $display("Final R1 (N):      %0d", debug_reg1);
        $display("Final R2 (Result): %0d", debug_reg2);
        $display("Final R3 (Const):  %0d", debug_reg3);
        $display("Final R4 (Temp):   %0d", debug_reg4);
        $display("Total Cycles:      %0d", cycle_count);

        if (debug_reg2 == 120)
            $display("\n✓✓✓ TEST PASSED! 5! = 120 ✓✓✓\n");
        else
            $display("\n✗✗✗ TEST FAILED! Expected 120, got %0d ✗✗✗\n", debug_reg2);

        // Print trace buffer
        $display("\n===== EXECUTION TRACE BUFFER =====");
        $display("Trace Count: %0d/16", trace_count);
        $display("Index | Instruction (hex)");
        $display("------+------------------");
        if (trace_count > 0)  $display("  0   | %h", trace_buf0);
        if (trace_count > 1)  $display("  1   | %h", trace_buf1);
        if (trace_count > 2)  $display("  2   | %h", trace_buf2);
        if (trace_count > 3)  $display("  3   | %h", trace_buf3);
        if (trace_count > 4)  $display("  4   | %h", trace_buf4);
        if (trace_count > 5)  $display("  5   | %h", trace_buf5);
        if (trace_count > 6)  $display("  6   | %h", trace_buf6);
        if (trace_count > 7)  $display("  7   | %h", trace_buf7);
        if (trace_count > 8)  $display("  8   | %h", trace_buf8);
        if (trace_count > 9)  $display("  9   | %h", trace_buf9);
        if (trace_count > 10) $display(" 10   | %h", trace_buf10);
        if (trace_count > 11) $display(" 11   | %h", trace_buf11);
        if (trace_count > 12) $display(" 12   | %h", trace_buf12);
        if (trace_count > 13) $display(" 13   | %h", trace_buf13);
        if (trace_count > 14) $display(" 14   | %h", trace_buf14);
        if (trace_count > 15) $display(" 15   | %h", trace_buf15);

        $display("\n========================================\n");
        $finish;
    end

    // Monitor WRITEBACK state
    always @(posedge clk) begin
        if (!reset && !debug_enable && debug_state == 3'b100)
            display_state();
    end

    // Timeout watchdog
    initial begin
        #1000000;
        $display("\n*** TIMEOUT: Simulation exceeded 1ms ***");
        $display("Last PC: %0d", debug_pc);
        $display("Last R2: %0d", debug_reg2);
        $finish;
    end

endmodule