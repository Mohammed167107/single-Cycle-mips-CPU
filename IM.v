module Instruction_Memory(
    input [31:0] PC,
    output reg [31:0] instruction
);
    reg [31:0] IM [255:0];

    initial begin
        IM[0]=32'b10001100000000010000000000000100;
        IM[1]=32'b10001100000011000000000000001100;
        IM[2]=32'b10001100000000110000000000010100;
        IM[3]=32'b10001100000001000000000000011100;
        IM[4]=32'b00000000001000110010100000101010;
        IM[5]=32'b00110100101001100000001111111111;
        IM[6]=32'b00000000100011000100000000100010;
        IM[7]=32'b00001100000000000000000000001011;
        IM[8]=32'b00000000101001100011100000100110;
        IM[9]=32'b10101100000001110000000000001000;
        IM[10]=32'b00001000000000000000000000001110;
        IM[11]=32'b00110001000010010000011111111111;
        IM[12]=32'b00010000011001100000000000000001;
        IM[13]=32'b00000011111000000000000000001000;
        IM[14]=32'b00000000111010010101000000100101;
        IM[15]=32'b00000001000000010101100000101010;

        // Initialize other locations as needed
    end

    always @(PC) begin
        instruction = IM[PC >> 2]; // Divide by 4 to get the correct word address
    end
endmodule

/*  The output

# Time =                    0, PC = 00000000, Instruction = xxxxxxxx
# Time =                   15, PC = 00000000, Instruction = 00000010
# Time =                   20, PC = 00000004, Instruction = 00000010
# Time =                   35, PC = 00000004, Instruction = 00000020
# Time =                   40, PC = 00000008, Instruction = 00000020
# Time =                   55, PC = 00000008, Instruction = 00000030
# Time =                   60, PC = 0000000c, Instruction = 00000030
# Time =                   75, PC = 0000000c, Instruction = 00000040
# Time =                   80, PC = 00000010, Instruction = 00000040
# Time =                   95, PC = 00000010, Instruction = 00000050
# Time =                  100, PC = 00000014, Instruction = 00000050
# Time =                  115, PC = 00000014, Instruction = xxxxxxxx

*/
