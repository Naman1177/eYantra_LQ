
// mem_align.v - byte/halfword access on top of a word-only data memory
//
// data_mem.v only stores/returns whole 32-bit words, indexed by
// wr_addr[31:2]. This module is instantiated between riscv_cpu and
// data_mem so SB/SH/LB/LH/LBU/LHU work without modifying data_mem.v:
//
//   - store_merged: takes the word data_mem currently holds at this
//     address (mem_rd_data, read combinationally at the SAME address
//     used for the write) and overwrites only the targeted byte/half-
//     word lane with the low bits of store_data, leaving the other
//     byte(s) in that word untouched (read-modify-write).
//   - load_data: takes that same word and extracts/sign- or zero-
//     extends the targeted byte/halfword back out to 32 bits.
//
// funct3 is Instr[14:12]: it carries the same width/sign encoding for
// both loads and stores (000=byte,001=half,010=word,100=byte-unsigned,
// 101=half-unsigned), and since a given cycle is never both a load and
// a store, reading it unconditionally for both outputs is safe - only
// the one that's actually in use (gated by MemWrite/ResultSrc upstream)
// has any effect.

module mem_align (
    input      [1:0]  addr_lsb,     // byte address's low 2 bits (offset within the word)
    input      [2:0]  funct3,       // Instr[14:12]: access width/sign
    input      [31:0] store_data,   // raw rs2 value from the CPU (low bits used)
    input      [31:0] mem_rd_data,  // word currently read from data_mem at this address
    output reg [31:0] store_merged, // word to actually write into data_mem
    output reg [31:0] load_data     // value returned to the CPU as ReadData
);

always @(*) begin
    case (funct3)
        3'b000: begin // SB - store byte, leave other 3 bytes of the word alone
            case (addr_lsb)
                2'b00: store_merged = {mem_rd_data[31:8],  store_data[7:0]};
                2'b01: store_merged = {mem_rd_data[31:16], store_data[7:0], mem_rd_data[7:0]};
                2'b10: store_merged = {mem_rd_data[31:24], store_data[7:0], mem_rd_data[15:0]};
                2'b11: store_merged = {store_data[7:0], mem_rd_data[23:0]};
            endcase
        end
        3'b001: begin // SH - store halfword, leave the other half alone
            if (addr_lsb[1]) store_merged = {store_data[15:0], mem_rd_data[15:0]};
            else             store_merged = {mem_rd_data[31:16], store_data[15:0]};
        end
        default: store_merged = store_data; // SW (010) - full word overwrite
    endcase
end

always @(*) begin
    case (funct3)
        3'b000: begin // LB - sign-extend byte
            case (addr_lsb)
                2'b00: load_data = {{24{mem_rd_data[7]}},  mem_rd_data[7:0]};
                2'b01: load_data = {{24{mem_rd_data[15]}}, mem_rd_data[15:8]};
                2'b10: load_data = {{24{mem_rd_data[23]}}, mem_rd_data[23:16]};
                2'b11: load_data = {{24{mem_rd_data[31]}}, mem_rd_data[31:24]};
            endcase
        end
        3'b001: begin // LH - sign-extend halfword
            if (addr_lsb[1]) load_data = {{16{mem_rd_data[31]}}, mem_rd_data[31:16]};
            else             load_data = {{16{mem_rd_data[15]}}, mem_rd_data[15:0]};
        end
        3'b100: begin // LBU - zero-extend byte
            case (addr_lsb)
                2'b00: load_data = {24'b0, mem_rd_data[7:0]};
                2'b01: load_data = {24'b0, mem_rd_data[15:8]};
                2'b10: load_data = {24'b0, mem_rd_data[23:16]};
                2'b11: load_data = {24'b0, mem_rd_data[31:24]};
            endcase
        end
        3'b101: begin // LHU - zero-extend halfword
            if (addr_lsb[1]) load_data = {16'b0, mem_rd_data[31:16]};
            else             load_data = {16'b0, mem_rd_data[15:0]};
        end
        default: load_data = mem_rd_data; // LW (010)
    endcase
end

endmodule
