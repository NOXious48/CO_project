`timescale 1ns / 1ps

module memory_trace (
    input wire clk,
    input wire reset,
    
    // Memory interface
    input wire [7:0] addr,
    input wire [15:0] data_in,
    input wire mem_read,
    input wire mem_write,
    output reg [15:0] data_out,
    
    // Trace interface
    input wire [15:0] trace_pc,
    input wire [15:0] trace_instruction,
    input wire [2:0] trace_state,
    input wire trace_enable,
    
    // Trace outputs
    output reg [15:0] trace_buf0, trace_buf1, trace_buf2, trace_buf3,
    output reg [15:0] trace_buf4, trace_buf5, trace_buf6, trace_buf7,
    output reg [15:0] trace_buf8, trace_buf9, trace_buf10, trace_buf11,
    output reg [15:0] trace_buf12, trace_buf13, trace_buf14, trace_buf15,
    output reg [3:0] trace_count
);

    localparam WRITEBACK = 3'b100;

    // Combined instruction and data memory (256 words)
    reg [15:0] memory [0:255];
    
    // Internal trace buffer
    reg [15:0] trace_buffer [0:15];
    reg [3:0] trace_index;

    integer i;

    // Memory initialization
    initial begin
        // Clear all memory
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 16'h0000;
        
        // Data memory (addresses 40-42)
        memory[40] = 16'd5;    // N = 5
        memory[41] = 16'd1;    // Result = 1
        memory[42] = 16'd1;    // Const 1

        // Program instructions
        memory[0]  = 16'h2228;  // LOAD R1, [40]  (N=5)
        memory[1]  = 16'h2429;  // LOAD R2, [41]  (result=1)
        memory[2]  = 16'h262a;  // LOAD R3, [42]  (const=1)
        
        memory[3]  = 16'h0800;  // ADD R4, R0, 0  (R4=0, temp accumulator)
        memory[4]  = 16'h0a00;  // ADD R5, R0, 0  (R5=0, loop counter)

        // INNER LOOP (address 5-9) - Multiply R2 by R1
        memory[5]  = 16'h0902;  // ADD R4, R4, R2  (accumulate)
        memory[6]  = 16'h0b43;  // ADD R5, R5, R3  (R5++, increment counter)
        memory[7]  = 16'h1c45;  // SUB R6, R1, R5  (check if R5 == R1)
        memory[8]  = 16'h5c02;  // BEQ R6,R0,+2  (if loop done, skip JUMP)
        memory[9]  = 16'h4005;  // JUMP 5  (repeat inner loop)
        
        // OUTER LOOP (address 10-13) - Decrement N, repeat until N==0
        memory[10] = 16'h0900;  // ADD R2, R4, 0  (save multiplication result to R2)
        memory[11] = 16'h1243;  // SUB R1, R1, R3  (N--, decrement N)
        memory[12] = 16'h5210;  // BEQ R1,R0,+16  (if N==0, jump to STORE at address 28)
        memory[13] = 16'h4003;  // JUMP 3  (else repeat from outer loop start)

        // HALT (address 28-29)
        memory[28] = 16'h3429;  // STORE R2, [41]  (save result to memory)
        memory[29] = 16'h401d;  // JUMP 29  (infinite halt loop)
    end

    // Memory write (synchronous)
    always @(posedge clk) begin
        if (mem_write)
            memory[addr] <= data_in;
    end

    // Memory read (COMBINATIONAL)
    always @(*) begin
        data_out = memory[addr];
    end

    // Trace buffer (triggered on WRITEBACK)
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            trace_index <= 4'd0;
            trace_count <= 4'd0;
            for (i = 0; i < 16; i = i + 1)
                trace_buffer[i] <= 16'b0;
        end
        else if (trace_enable && (trace_state == WRITEBACK)) begin
            trace_buffer[trace_index] <= trace_instruction;
            trace_index <= (trace_index == 4'd15) ? 4'd0 : trace_index + 4'd1;
            if (trace_count < 4'd15)
                trace_count <= trace_count + 4'd1;
        end
    end

    // Export trace buffer to outputs
    always @(*) begin
        trace_buf0  = trace_buffer[0];
        trace_buf1  = trace_buffer[1];
        trace_buf2  = trace_buffer[2];
        trace_buf3  = trace_buffer[3];
        trace_buf4  = trace_buffer[4];
        trace_buf5  = trace_buffer[5];
        trace_buf6  = trace_buffer[6];
        trace_buf7  = trace_buffer[7];
        trace_buf8  = trace_buffer[8];
        trace_buf9  = trace_buffer[9];
        trace_buf10 = trace_buffer[10];
        trace_buf11 = trace_buffer[11];
        trace_buf12 = trace_buffer[12];
        trace_buf13 = trace_buffer[13];
        trace_buf14 = trace_buffer[14];
        trace_buf15 = trace_buffer[15];
    end

endmodule