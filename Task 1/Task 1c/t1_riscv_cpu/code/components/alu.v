
// alu.v - ALU module

module alu #(parameter WIDTH = 32) (
    input       [WIDTH-1:0] a, b,       // operands
    input       [3:0] alu_ctrl,         // ALU control
    output reg  [WIDTH-1:0] alu_out,    // ALU output
    output      zero,                   // zero flag (alu_out == 0)
    output      lt,                     // signed   a <  b   (for blt/bge)
    output      ltu                     // unsigned a <  b   (for bltu/bgeu)
);

// ALU control encoding
localparam ALU_ADD  = 4'b0000;
localparam ALU_SUB  = 4'b0001;
localparam ALU_AND  = 4'b0010;
localparam ALU_OR   = 4'b0011;
localparam ALU_XOR  = 4'b0100;
localparam ALU_SLT  = 4'b0101;
localparam ALU_SLTU = 4'b0110;
localparam ALU_SLL  = 4'b0111;
localparam ALU_SRL  = 4'b1000;
localparam ALU_SRA  = 4'b1001;

always @(*) begin
    case (alu_ctrl)
        ALU_ADD:  alu_out = a + b;                                   // ADD, ADDI, load/store address, jalr/auipc base
        ALU_SUB:  alu_out = a - b;                                   // SUB / branch compare
        ALU_AND:  alu_out = a & b;                                   // AND, ANDI
        ALU_OR:   alu_out = a | b;                                   // OR, ORI
        ALU_XOR:  alu_out = a ^ b;                                   // XOR, XORI
        ALU_SLT:  alu_out = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;  // SLT, SLTI
        ALU_SLTU: alu_out = (a < b) ? 32'd1 : 32'd0;                 // SLTU, SLTIU
        ALU_SLL:  alu_out = a << b[4:0];                             // SLL, SLLI
        ALU_SRL:  alu_out = a >> b[4:0];                             // SRL, SRLI
        ALU_SRA:  alu_out = $signed(a) >>> b[4:0];                   // SRA, SRAI
        default:  alu_out = {WIDTH{1'b0}};
    endcase
end

assign zero = (alu_out == 0);

// lt/ltu are computed directly from the operands (not from alu_out), so they
// stay valid for every branch instruction regardless of what alu_ctrl happens
// to be selected that cycle - BLT/BGE/BLTU/BGEU need these, BEQ/BNE use zero.
assign lt  = ($signed(a) < $signed(b));
assign ltu = (a < b);

endmodule

