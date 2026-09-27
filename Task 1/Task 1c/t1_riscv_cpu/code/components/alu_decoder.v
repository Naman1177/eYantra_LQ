
// alu_decoder.v - logic for ALU decoder

module alu_decoder (
    input            opb5,
    input [2:0]      funct3,
    input            funct7b5,
    input [1:0]      ALUOp,
    output reg [3:0] ALUControl
);

always @(*) begin
    case (ALUOp)
        2'b00: ALUControl = 4'b0000;             // addition (lw/sw/jalr/auipc-base address calc)
        2'b01: ALUControl = 4'b0001;             // subtraction (branch comparisons use zero/lt/ltu from the ALU directly)
        default:
            case (funct3) // R-type or I-type ALU
                3'b000: begin
                    // True for R-type subtract only. funct7b5 (instr[30]) is just
                    // an ordinary immediate bit for ADDI, so it must be ignored
                    // unless this is genuinely an R-type instruction (opb5=1).
                    if   (funct7b5 & opb5) ALUControl = 4'b0001; // sub
                    else ALUControl = 4'b0000; // add, addi
                end
                3'b001:  ALUControl = 4'b0111; // sll, slli   (shift amount = b[4:0])
                3'b010:  ALUControl = 4'b0101; // slt, slti
                3'b011:  ALUControl = 4'b0110; // sltu, sltiu
                3'b100:  ALUControl = 4'b0100; // xor, xori
                3'b101: begin
                    // Unlike ADD/SUB, funct7b5 genuinely selects srl vs sra for
                    // BOTH R-type and I-type shift-immediate encodings (imm[10]
                    // doubles as this bit for SRLI/SRAI), so no opb5 gating here.
                    if (funct7b5) ALUControl = 4'b1001; // sra, srai
                    else          ALUControl = 4'b1000; // srl, srli
                end
                3'b110:  ALUControl = 4'b0011; // or, ori
                3'b111:  ALUControl = 4'b0010; // and, andi
                default: ALUControl = 4'bxxxx; // ???
            endcase
    endcase
end

endmodule

