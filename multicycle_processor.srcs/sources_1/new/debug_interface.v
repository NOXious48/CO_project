`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.11.2025 21:56:18
// Design Name: 
// Module Name: debug_interface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// File: debug_interface.v
// Student C - Debug Logic (CORRECTED VERSION)
// Debug registers, control, and monitoring interface

module debug_interface (
    input wire clk,
    input wire reset,
    
    // Debug control inputs
    input wire debug_enable,      // Enable debug mode
    input wire debug_step_btn,    // Step button (active high)
    
    // Processor state inputs
    input wire [15:0] pc_in,
    input wire [15:0] instruction_in,
    input wire [2:0] state_in,
    input wire [15:0] reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7,
    
    // Debug outputs
    output reg debug_step,         // Single-step pulse to controller
    output reg [15:0] debug_pc,    // Current PC for display
    output reg [15:0] debug_ir,    // Current instruction
    output reg [2:0] debug_state,  // Current state
    
    // Debug registers (read by external interface)
    output reg [15:0] debug_reg0,
    output reg [15:0] debug_reg1,
    output reg [15:0] debug_reg2,
    output reg [15:0] debug_reg3,
    output reg [15:0] debug_reg4,
    output reg [15:0] debug_reg5,
    output reg [15:0] debug_reg6,
    output reg [15:0] debug_reg7,
    output reg [31:0] cycle_count
);

    // Button debouncing and edge detection - IMPROVED
    reg [3:0] step_btn_sync;
    reg step_btn_prev;
    wire step_btn_edge;
    
    // Synchronize button input (for metastability) - 4 stages for better debouncing
    always @(posedge clk or posedge reset) begin
        if (reset)
            step_btn_sync <= 4'b0;
        else
            step_btn_sync <= {step_btn_sync[2:0], debug_step_btn};
    end
    
    // Edge detection for step button - rising edge
    always @(posedge clk or posedge reset) begin
        if (reset)
            step_btn_prev <= 1'b0;
        else
            step_btn_prev <= step_btn_sync[3];
    end
    
    assign step_btn_edge = step_btn_sync[3] & ~step_btn_prev;
    
    // Generate single-step pulse - FIXED: proper behavior
    always @(posedge clk or posedge reset) begin
        if (reset)
            debug_step <= 1'b0;
        else if (debug_enable)
            debug_step <= step_btn_edge;  // Pulse on button press
        else
            debug_step <= 1'b1;  // Auto-step when debug disabled
    end
    
    // Capture processor state
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            debug_pc <= 16'b0;
            debug_ir <= 16'b0;
            debug_state <= 3'b0;
            debug_reg0 <= 16'b0;
            debug_reg1 <= 16'b0;
            debug_reg2 <= 16'b0;
            debug_reg3 <= 16'b0;
            debug_reg4 <= 16'b0;
            debug_reg5 <= 16'b0;
            debug_reg6 <= 16'b0;
            debug_reg7 <= 16'b0;
        end
        else begin
            debug_pc <= pc_in;
            debug_ir <= instruction_in;
            debug_state <= state_in;
            debug_reg0 <= reg0;
            debug_reg1 <= reg1;
            debug_reg2 <= reg2;
            debug_reg3 <= reg3;
            debug_reg4 <= reg4;
            debug_reg5 <= reg5;
            debug_reg6 <= reg6;
            debug_reg7 <= reg7;
        end
    end
    
    // Cycle counter
    always @(posedge clk or posedge reset) begin
        if (reset)
            cycle_count <= 32'b0;
        else
            cycle_count <= cycle_count + 1;
    end

endmodule
