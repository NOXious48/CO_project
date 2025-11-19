`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// File: controller.v
// Student A - FSM Controller (CORRECTED VERSION)
// Multicycle processor control unit with debug support
//////////////////////////////////////////////////////////////////////////////////

module controller (
    input wire clk,
    input wire reset,
    input wire debug_step,        // Single-step debug signal (from debug_interface)
    input wire [3:0] opcode,      // Instruction opcode (from datapath)
    input wire zero_flag,         // ALU zero flag (from datapath)
    
    output reg pc_write,          // Program counter write enable
    output reg mem_read,          // Memory read enable
    output reg mem_write,         // Memory write enable
    output reg ir_write,          // Instruction register write
    output reg reg_write,         // Register file write enable
    output reg [1:0] alu_op,      // ALU operation
    output reg [1:0] pc_src,      // PC source select
    output reg alu_src_a,         // ALU source A select (informational)
    output reg alu_src_b,         // ALU source B select (informational)
    output reg mem_to_reg,        // Memory to register select
    output reg [2:0] state_out    // Current state (for debugging)
);

    // State definitions
    localparam FETCH      = 3'b000;
    localparam DECODE     = 3'b001;
    localparam EXECUTE    = 3'b010;
    localparam MEMORY     = 3'b011;
    localparam WRITEBACK  = 3'b100;
    localparam DEBUG_WAIT = 3'b101;

    // Opcode definitions (must match datapath)
    localparam OP_ADD   = 4'b0000;
    localparam OP_SUB   = 4'b0001;
    localparam OP_LOAD  = 4'b0010;
    localparam OP_STORE = 4'b0011;
    localparam OP_JUMP  = 4'b0100;
    localparam OP_BEQ   = 4'b0101;

    reg [2:0] state, next_state;

    // State register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= FETCH;
        else
            state <= next_state;
    end

    // Next state logic with debug support
    always @(*) begin
        case (state)
            FETCH: 
                next_state = DECODE;
            
            DECODE: 
                next_state = DEBUG_WAIT;
            
            DEBUG_WAIT: 
                next_state = debug_step ? EXECUTE : DEBUG_WAIT;
            
            EXECUTE: 
                next_state = MEMORY;
            
            MEMORY: begin
                // For STORE we don't need a WRITEBACK (store is done in MEMORY)
                if (opcode == OP_STORE)
                    next_state = FETCH;
                else if (opcode == OP_LOAD || opcode == OP_ADD || opcode == OP_SUB)
                    next_state = WRITEBACK;
                else
                    next_state = FETCH;
            end
            
            WRITEBACK:
                next_state = FETCH;
            
            default:
                next_state = FETCH;
        endcase
    end

    // Control signal generation
    always @(*) begin
        // Default values
        pc_write = 1'b0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        ir_write = 1'b0;
        reg_write = 1'b0;
        alu_op = 2'b00;
        pc_src = 2'b00;
        alu_src_a = 1'b0;
        alu_src_b = 1'b0;
        mem_to_reg = 1'b0;
        state_out = state;

        case (state)
            FETCH: begin
                mem_read = 1'b1;    // read instruction
                ir_write = 1'b1;    // write instruction register
                pc_write = 1'b1;    // increment PC (pc_src selects +1)
                pc_src = 2'b00;     // PC + 1
            end

            DECODE: begin
                // No strobes required here in this simple design
            end

            DEBUG_WAIT: begin
                // Wait until debug_step supplies a pulse to advance to EXECUTE
            end

            EXECUTE: begin
                // Default: no memory ops here (address calculation only)
                case (opcode)
                    OP_ADD: begin
                        alu_src_a = 1'b1;  // rs1
                        alu_src_b = 1'b0;  // rs2
                        alu_op = 2'b00;    // ADD
                    end

                    OP_SUB: begin
                        alu_src_a = 1'b1;
                        alu_src_b = 1'b0;
                        alu_op = 2'b01;    // SUB
                    end

                    OP_LOAD: begin
                        // LOAD uses absolute immediate as address
                        // Datapath will use immediate directly for address calc
                        alu_src_a = 1'b0;  // force ZERO (informational)
                        alu_src_b = 1'b1;  // immediate
                        alu_op = 2'b00;    // ADD (imm -> alu_result)
                    end

                    OP_STORE: begin
                        // STORE uses absolute immediate as address
                        alu_src_a = 1'b0;
                        alu_src_b = 1'b1;
                        alu_op = 2'b00;
                    end

                    OP_JUMP: begin
                        pc_src = 2'b10;    // jump to immediate
                        pc_write = 1'b1;
                    end

                    OP_BEQ: begin
                        // Compare: do subtract to set zero flag, branch if zero
                        alu_src_a = 1'b1;  // rs1
                        alu_src_b = 1'b0;  // rs2
                        alu_op = 2'b01;    // SUB
                        if (zero_flag) begin
                            pc_src = 2'b01; // branch offset
                            pc_write = 1'b1;
                        end
                    end

                    default: begin
                        // NOP or undefined op - do nothing
                    end
                endcase
            end

            MEMORY: begin
                // Memory access: either read (LOAD) or write (STORE)
                case (opcode)
                    OP_LOAD: begin
                        mem_read = 1'b1;
                    end
                    OP_STORE: begin
                        mem_write = 1'b1;
                    end
                    default: begin
                        // no memory op
                    end
                endcase
            end

            WRITEBACK: begin
                case (opcode)
                    OP_ADD, OP_SUB: begin
                        reg_write = 1'b1;
                        mem_to_reg = 1'b0;  // write ALU result
                    end
                    OP_LOAD: begin
                        reg_write = 1'b1;
                        mem_to_reg = 1'b1;  // write memory data
                    end
                    default: begin
                        reg_write = 1'b0;
                    end
                endcase
            end
        endcase
    end

endmodule
