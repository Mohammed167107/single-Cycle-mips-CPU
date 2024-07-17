module REG32negclk (Q, D, clk, reset, enable);
    input clk, reset, enable;
    reg [31:0] pc;
    input [31:0] D;
    output [31:0] Q;

    always @(posedge clk) begin
        if (!reset) begin
            pc <= 32'b0;
        end else if (enable) begin
            pc <= D;
        end
    end
    assign Q=pc;
endmodule

module Mux_32_to_1_32bit(out, s, in);
    input [1023:0] in;
    input [4:0] s;
    output reg [31:0] out;

    always @(in or s) begin
        case (s)
            5'd0 : out = in[31:0];
            5'd1 : out = in[63:32];
            5'd2 : out = in[95:64];
            5'd3 : out = in[127:96];
            5'd4 : out = in[159:128];
            5'd5 : out = in[191:160];
            5'd6 : out = in[223:192];
            5'd7 : out = in[255:224];
            5'd8 : out = in[287:256];
            5'd9 : out = in[319:288];
            5'd10 : out = in[351:320];
            5'd11 : out = in[383:352];
            5'd12 : out = in[415:384];
            5'd13 : out = in[447:416];
            5'd14 : out = in[479:448];
            5'd15 : out = in[511:480];
            5'd16 : out = in[543:512];
            5'd17 : out = in[575:544];
            5'd18 : out = in[607:576];
            5'd19 : out = in[639:608];
            5'd20 : out = in[671:640];
            5'd21 : out = in[703:672];
            5'd22 : out = in[735:704];
            5'd23 : out = in[767:736];
            5'd24 : out = in[799:768];
            5'd25 : out = in[831:800];
            5'd26 : out = in[863:832];
            5'd27 : out = in[895:864];
            5'd28 : out = in[927:896];
            5'd29 : out = in[959:928];
            5'd30 : out = in[991:960];
            5'd31 : out = in[1023:992];
        endcase
    end
endmodule

module Decoder2to4 (out, in, enable);
    input enable;
    input [1:0] in;
    output reg [3:0] out;

    always @(in or enable) begin
        if (enable) begin
            case (in)
                2'b00 : out = 4'b0001;
                2'b01 : out = 4'b0010;
                2'b10 : out = 4'b0100;
                2'b11 : out = 4'b1000;
            endcase
        end else begin
            out = 4'b0000;
        end
    end
endmodule

module Decoder3to8 (out, in, enable);
    input enable;
    input [2:0] in;
    output reg [7:0] out;

    always @(in or enable) begin
        if (enable) begin
            case (in)
                3'b000 : out = 8'b00000001;
                3'b001 : out = 8'b00000010;
                3'b010 : out = 8'b00000100;
                3'b011 : out = 8'b00001000;
                3'b100 : out = 8'b00010000;
                3'b101 : out = 8'b00100000;
                3'b110 : out = 8'b01000000;
                3'b111 : out = 8'b10000000;
            endcase
        end else begin
            out = 8'b00000000;
        end
    end
endmodule

module Decoder5to32 (out, in, enable);
    input enable;
    input [4:0] in;
    output [31:0] out;

    wire [3:0] dec2to4_out;
    wire [7:0] dec3to8_out[3:0];

    Decoder2to4 dec2to4_inst (.out(dec2to4_out), .in(in[4:3]), .enable(enable));

    generate
        genvar i;
        for (i = 0; i < 4; i = i + 1) begin : dec3to8_gen
            Decoder3to8 dec3to8_inst (.out(dec3to8_out[i]), .in(in[2:0]), .enable(dec2to4_out[i]));
        end
    endgenerate

    assign out = {dec3to8_out[3], dec3to8_out[2], dec3to8_out[1], dec3to8_out[0]};
endmodule

module RegFile(
    readdata1, readdata2, readreg1, readreg2,
    writedata, writereg, regwrite, clk, reset
);
    input regwrite, clk, reset;
    input [4:0] readreg1, readreg2, writereg;
    input [31:0] writedata;
    output [31:0] readdata1, readdata2;

    reg [31:0] registers [31:0];
    integer i;

    always @(posedge clk) begin
        if (!reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (regwrite) begin
            registers[writereg] = writedata;
        end
    end
    assign readdata1 = registers[readreg1];
    assign readdata2 = registers[readreg2];
endmodule