`timescale 1ns / 1ps

module controller (
    input wire clk,
    input wire reset,
    input wire debug_step,        // Single-step debug signal
    input wire [3:0] opcode,      // Instruction opcode
    input wire zero_flag,         // ALU zero flag
    
    output reg pc_write,          // Program counter write enable
    output reg mem_read,          // Memory read enable
    output reg mem_write,         // Memory write enable
    output reg ir_write,          // Instruction register write
    output reg reg_write,         // Register file write enable
    output reg [1:0] alu_op,      // ALU operation
    output reg [1:0] pc_src,      // PC source select
    output reg alu_src_a,         // ALU source A select
    output reg alu_src_b,         // ALU source B select
    output reg mem_to_reg,        // Memory to register select
    output reg [2:0] state_out    // Current state (for debugging)
);

    // State definitions
    localparam FETCH      = 3'b000;
    localparam DECODE     = 3'b001;
    localparam EXECUTE    = 3'b010;
    localparam MEMORY     = 3'b011;
    localparam WRITEBACK  = 3'b100;

    // Opcode definitions
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

    // FIXED: Next state logic - removed DEBUG_WAIT state
    // debug_step now controls progression naturally
    always @(*) begin
        case (state)
            FETCH: 
                next_state = DECODE;
            
            DECODE: 
                // Only advance if debug_step is high
                next_state = debug_step ? EXECUTE : DECODE;
            
            EXECUTE: 
                next_state = MEMORY;
            
            MEMORY: begin
                // For STORE we don't need WRITEBACK
                if (opcode == OP_STORE)
                    next_state = FETCH;
                // For JUMP and BEQ, go back to FETCH
                else if (opcode == OP_JUMP || opcode == OP_BEQ)
                    next_state = FETCH;
                // For arithmetic and LOAD, go to WRITEBACK
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
                mem_read = 1'b1;    // Read instruction
                ir_write = 1'b1;    // Write instruction register
                pc_write = 1'b1;    // Increment PC
                pc_src = 2'b00;     // PC + 1
            end

            DECODE: begin
                // Wait here if debug_step is low
                // No control signals needed
            end

            EXECUTE: begin
                case (opcode)
                    OP_ADD: begin
                        alu_src_a = 1'b1;  // rs1
                        alu_src_b = 1'b0;  // rs2
                        alu_op = 2'b00;    // ADD
                    end

                    OP_SUB: begin
                        alu_src_a = 1'b1;  // rs1
                        alu_src_b = 1'b0;  // rs2
                        alu_op = 2'b01;    // SUB
                    end

                    OP_LOAD: begin
                        alu_src_a = 1'b0;  // 0
                        alu_src_b = 1'b1;  // immediate
                        alu_op = 2'b00;    // ADD (pass through imm)
                    end

                    OP_STORE: begin
                        alu_src_a = 1'b0;  // 0
                        alu_src_b = 1'b1;  // immediate
                        alu_op = 2'b00;    // ADD (pass through imm)
                    end

                    OP_JUMP: begin
                        pc_src = 2'b10;    // Jump to immediate
                        pc_write = 1'b1;
                    end

                    OP_BEQ: begin
                        alu_src_a = 1'b1;  // rs1
                        alu_src_b = 1'b0;  // rs2
                        alu_op = 2'b01;    // SUB for comparison
                        if (zero_flag) begin
                            pc_src = 2'b01; // Branch offset
                            pc_write = 1'b1;
                        end
                    end
                endcase
            end

            MEMORY: begin
                case (opcode)
                    OP_LOAD: begin
                        mem_read = 1'b1;
                    end
                    OP_STORE: begin
                        mem_write = 1'b1;
                    end
                endcase
            end

            WRITEBACK: begin
                // Enable register write for all writeback operations
                reg_write = 1'b1;
                
                case (opcode)
                    OP_ADD, OP_SUB: begin
                        mem_to_reg = 1'b0;  // Write ALU result
                    end
                    OP_LOAD: begin
                        mem_to_reg = 1'b1;  // Write memory data
                    end
                    default: begin
                        reg_write = 1'b0;  // Safety: disable for unknown opcodes
                    end
                endcase
            end
        endcase
    end

endmodule