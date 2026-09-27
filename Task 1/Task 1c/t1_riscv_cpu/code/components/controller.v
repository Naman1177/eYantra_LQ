
// controller.v - controller for RISC-V CPU

module controller (
    input [6:0]  op,
    input [2:0]  funct3,
    input        funct7b5,
    input        Zero, Lt, Ltu,
    output       [1:0] ResultSrc,
    output       MemWrite,
    output       PCSrc, ALUSrc,
    output       RegWrite, Jump,Jalr,
    output [1:0] ImmSrc,
    output [3:0] ALUControl
);

wire [1:0] ALUOp;
wire       Branch;
reg        BranchTaken;

main_decoder    md (op, ResultSrc, MemWrite, Branch,
                    ALUSrc, RegWrite, Jump,Jalr, ImmSrc, ALUOp);

alu_decoder     ad (op[5], funct3, funct7b5, ALUOp, ALUControl);

// Generalized branch condition, keyed off funct3 exactly as the RISC-V ISA
// encodes it: beq=000, bne=001, blt=100, bge=101, bltu=110, bgeu=111.
// Zero comes from the ALU's a-b subtraction (valid for beq/bne); Lt/Ltu come
// from the ALU's dedicated, always-valid signed/unsigned comparators.
always @(*) begin
    case (funct3)
        3'b000:  BranchTaken = Zero;     // beq:  rs1 == rs2
        3'b001:  BranchTaken = ~Zero;    // bne:  rs1 != rs2
        3'b100:  BranchTaken = Lt;       // blt:  rs1 <  rs2 (signed)
        3'b101:  BranchTaken = ~Lt;      // bge:  rs1 >= rs2 (signed)
        3'b110:  BranchTaken = Ltu;      // bltu: rs1 <  rs2 (unsigned)
        3'b111:  BranchTaken = ~Ltu;     // bgeu: rs1 >= rs2 (unsigned)
        default: BranchTaken = 1'b0;
    endcase
end

// for jump and branch
assign PCSrc = (Branch & BranchTaken) | Jump;

endmodule

