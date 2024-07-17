module Processor(clk, reset, enable);
    input clk, reset, enable;
    
    wire [31:0] pcOut,PC, nextPC,nextPC1, instruction, PC_plus_4, branch_target, /*jump_target,*/ ALU_result, ALU_input2, mem_data, write_data;
    wire [31:0] read_data1, read_data2, sign_ext_imm, shifted_imm; 
    wire [27:0] shifted_jump;
    wire [4:0] write_reg;
    wire [2:0] alu_op;
    wire [1:0] reg_dst, mem_to_reg ;
    wire reg_write, mem_write, mem_read, pc_src ,jump, branch, zero,alu_src;

    // Program Counter
    REG32negclk ProgramCounter(PC, pcOut, clk, reset, enable);

    // Instruction Memory
    Instruction_Memory IM(PC, instruction);

    // Adder for PC + 4
    Adder32bit PCAdder(PC_plus_4, PC, 32'd4);

    // Control Unit
    ControlUnit CU(instruction[31:26], instruction[5:0],alu_op, reg_dst,mem_to_reg,alu_src, reg_write, mem_read,mem_write, branch, jump,pc_src);

    // Shift Left for Jump Address
    ShiftLeft26_by2 JumpShift(shifted_jump, instruction[25:0]);   

    // Mux for Write Register
    Mux_3_to_1_5bit WriteRegMux(write_reg, reg_dst,5'd31 , instruction[15:11],instruction[20:16] );

    // Register File
    RegFile RF(read_data1, read_data2, instruction[25:21], instruction[20:16],write_data, write_reg, reg_write, clk, reset);

    // Sign Extend
    SignExtend SE(sign_ext_imm, instruction[15:0]);
    
    // Mux for ALU input 2
    Mux_2_to_1_32bit ALUMux(ALU_input2, alu_src, sign_ext_imm, read_data2);

    // ALU
    ALU alu(alu_op, read_data1, ALU_input2,ALU_result );

    // Data Memory
    Data_Memory DM(mem_data, ALU_result, read_data2, mem_write, mem_read, clk);

    // Comparator for Branch
    Comparator32bit CMP(zero, read_data1, read_data2);
    wire aNd;
    assign aNd= branch && zero;

    ShiftLeft32_by2 SL2(shifted_imm, sign_ext_imm);

    // Adder for Branch Target
    Adder32bit BranchAdder(branch_target, PC_plus_4, sign_ext_imm/*Later shift Later*/);

    Mux_2_to_1_32bit PCBranchMux(nextPC, aNd, branch_target,PC_plus_4);
    Mux_2_to_1_32bit PCJumpMux(nextPC1, jump, {PC_plus_4[31:28], shifted_jump}, read_data1);
    Mux_2_to_1_32bit PCpick(pcOut,pc_src,nextPC1,nextPC);
    // Mux for Write Data
    Mux_3_to_1_32bit WriteDataMux(write_data, mem_to_reg,PC_plus_4 , mem_data,ALU_result);
endmodule
module Adder32bit(out, a, b);
    input [31:0] a, b;
    output [31:0] out;
    assign out = a + b;
endmodule
module SignExtend(out, in);
    input [15:0] in;
    output [31:0] out;
    assign out = {{16{in[15]}}, in};
endmodule
module Comparator32bit(equal, a, b);
    input [31:0] a, b;
    output equal;
    assign equal = (a == b);
endmodule
module ShiftLeft26_by2(out, in);
    input [25:0] in;
    output [27:0] out;
    assign out = {in, 2'b00};
endmodule
module ShiftLeft32_by2(out, in);
    input [31:0] in;
    output [31:0] out;
    assign out = in << 2;
endmodule
module Mux_3_to_1_5bit(out, s, i2, i1, i0);
    input [4:0] i2, i1, i0;
    input [1:0] s;
    output [4:0] out;
    assign  out = (s == 2'b00) ? i0 : (s == 2'b01) ? i1 : i2;
endmodule
module Mux_3_to_1_32bit(out, s, i2, i1, i0);
    input [31:0] i2, i1, i0;
    input [1:0] s;
    output [31:0] out;
    assign  out = (s == 2'b00) ? i0 : (s == 2'b01) ? i1 : i2;
endmodule
module Mux_2_to_1_32bit(out, s, i1, i0);
    input [31:0] i1, i0;
    input s;
    output [31:0] out;
    assign  out = s ? i1 : i0;
endmodule

module tb;
    reg clk, reset, enable;

    Processor uut (.clk(clk), .reset(reset), .enable(enable));

    initial begin
        clk = 1;
        reset = 1;
        enable = 1;
        #50 reset = 0;
    end

    always #25 clk = ~clk;
endmodule