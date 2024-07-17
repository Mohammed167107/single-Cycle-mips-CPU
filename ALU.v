module ALU(m ,in1,in2,out);
    input [2:0] m;
    input [31:0] in1,in2;
    reg [31:0] o;
    output reg [31:0] out;
    always@(*) begin
        case(m)
            0:out=in1 | in2;
            3'b001:out=in1 & in2;
            2: out=in1^in2;
            3: out=in1+in2;
            4: out= !(in1 | in2);
            5: out=!(in1 & in2);
            6:out= A<B ?1'b1:1'b0;
            7:begin
                o=~in2+1;
                out=in1+o;
            end
        endcase
    end
endmodule