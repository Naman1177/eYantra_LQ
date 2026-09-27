// t1_riscv_cpu.v - Top Module to test riscv_cpu

module t1_riscv_cpu (
    input         clk, reset,
    input         Ext_MemWrite,
    input  [31:0] Ext_WriteData, Ext_DataAdr,
    output        MemWrite,
    output [31:0] WriteData, DataAdr, ReadData,
    output [31:0] PC, Result
);

wire [31:0] Instr;
wire [31:0] DataAdr_rv32, WriteData_rv32;
wire        MemWrite_rv32;

wire [31:0] RawReadData;     // whole word combinationally read back from data_mem
wire [31:0] AlignedReadData; // byte/half/word extended value fed into the CPU as ReadData
wire [31:0] StoreMerged;     // whole word written into data_mem (read-modify-write result)
wire [31:0] MemWrData_eff;   // data actually driving data_mem's write port

// instantiate processor and memories
riscv_cpu rvcpu    (clk, reset, PC, Instr,
                    MemWrite_rv32, DataAdr_rv32,
                    WriteData_rv32, AlignedReadData, Result);
instr_mem instrmem (PC, Instr);
data_mem  datamem  (clk, MemWrite, DataAdr, MemWrData_eff, RawReadData);

// sub-word read-modify-write (SB/SH) and load sign/zero-extension
// (LB/LH/LBU/LHU) on top of the word-only data_mem - see mem_align.v.
// funct3 = Instr[14:12] carries the width/sign encoding for whichever of
// load or store is actually executing this cycle.
mem_align   align  (DataAdr[1:0], Instr[14:12], WriteData_rv32, RawReadData,
                    StoreMerged, AlignedReadData);

assign MemWrite     = (Ext_MemWrite && reset) ? 1 : MemWrite_rv32;
assign WriteData    = (Ext_MemWrite && reset) ? Ext_WriteData : WriteData_rv32;
assign DataAdr      = reset ? Ext_DataAdr : DataAdr_rv32;
assign MemWrData_eff = (Ext_MemWrite && reset) ? Ext_WriteData : StoreMerged;
assign ReadData      = AlignedReadData;

endmodule

