`timescale 1ns / 1ps

module datapath (
    input wire clk,
    input wire reset,
    
    // Control signals
    input wire pc_write,
    input wire ir_write,
    input wire reg_write,
    input wire [1:0] alu_op,
    input wire [1:0] pc_src,
    input wire alu_src_a,
    input wire alu_src_b,
    input wire mem_to_reg,
    input wire [2:0] state_in,
    
    // Memory interface
    input wire [15:0] mem_data_in,
    output reg [7:0] mem_addr,
    output reg [15:0] mem_data_out,
    
    // Debug outputs
    output wire [15:0] pc_out,
    output wire [15:0] instruction_out,
    output wire zero_flag,
    output wire [3:0] opcode_out,
    output wire [15:0] reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7
);

    // State definitions
    localparam FETCH      = 3'b000;
    localparam DECODE     = 3'b001;
    localparam EXECUTE    = 3'b010;
    localparam MEMORY     = 3'b011;
    localparam WRITEBACK  = 3'b100;

    // Program Counter
    reg [7:0] pc;
    
    // Instruction Register
    reg [15:0] ir;
    
    // Register File
    reg [15:0] registers [0:7];
    
    // ALU signals
    reg [15:0] alu_a, alu_b, alu_result;
    reg [15:0] alu_result_reg;
    reg zero;
    
    // Memory data register
    reg [15:0] mem_data_reg;
    
    // Instruction fields
    wire [3:0] opcode = ir[15:12];
    wire [2:0] rd = ir[11:9];
    wire [2:0] rs1 = ir[8:6];
    wire [5:0] low6 = ir[5:0];
    wire [2:0] rs2 = low6[2:0];
    wire [5:0] imm6 = low6;
    wire [15:0] imm_ext = {10'b0, imm6};         // This pads the upper bits with Zeros
    
    // Outputs
    assign pc_out = {8'b0, pc};
    assign instruction_out = ir;
    assign zero_flag = zero;
    assign opcode_out = opcode;
    assign reg0 = registers[0];
    assign reg1 = registers[1];
    assign reg2 = registers[2];
    assign reg3 = registers[3];
    assign reg4 = registers[4];
    assign reg5 = registers[5];
    assign reg6 = registers[6];
    assign reg7 = registers[7];
    
    // Program Counter Logic
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 8'b0;
        else if (pc_write) begin
            case (pc_src)
                2'b00: pc <= pc + 1;
                2'b01: pc <= pc + imm_ext[7:0];
                2'b10: pc <= imm_ext[7:0];
                default: pc <= pc + 1;
            endcase
        end
    end
    
    // Instruction Register
    always @(posedge clk or posedge reset) begin
        if (reset)
            ir <= 16'b0;
        else if (ir_write)
            ir <= mem_data_in;
    end
    
    // Capture memory data during MEMORY state
    always @(posedge clk or posedge reset) begin
        if (reset)
            mem_data_reg <= 16'b0;
        else if (state_in == MEMORY)
            mem_data_reg <= mem_data_in;
    end
    
    // Register File - CRITICAL FIX: Remove state_in check
    // reg_write is only asserted during WRITEBACK anyway
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 8; i = i + 1)
                registers[i] <= 16'b0;
        end
        else if (reg_write) begin
            if (rd != 3'b0) begin
                if (mem_to_reg)
                    registers[rd] <= mem_data_reg;
                else
                    registers[rd] <= alu_result_reg;
            end
        end
    end
    
    // Register ALU result during EXECUTE
    always @(posedge clk or posedge reset) begin
        if (reset)
            alu_result_reg <= 16'b0;
        else if (state_in == EXECUTE)
            alu_result_reg <= alu_result;
    end
    
    // ALU Source Selection
    always @(*) begin
        alu_a = alu_src_a ? registers[rs1] : 16'b0;
        alu_b = alu_src_b ? imm_ext : registers[rs2];
    end
    
    // ALU Operations
    always @(*) begin
        case (alu_op)
            2'b00: alu_result = alu_a + alu_b;
            2'b01: alu_result = alu_a - alu_b;
            2'b10: alu_result = alu_a & alu_b;
            2'b11: alu_result = alu_a | alu_b;
            default: alu_result = 16'b0;
        endcase
        zero = (alu_result == 16'b0);
    end
    
    // Memory Address and Data Output
    always @(*) begin
        if (state_in == FETCH) begin
            mem_addr = pc;
            mem_data_out = 16'b0;
        end
        else begin
            mem_addr = alu_result_reg[7:0];
            mem_data_out = registers[rs2];
        end
    end

endmodule