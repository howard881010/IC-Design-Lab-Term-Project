module mul
(
input clk,
input rst_n,
input enable,
input square_done,
input [63:0] operand_1,
input [63:0] operand_2,
input [2:0] mode,        // 000: add, 001: sub, 010: mul, 011:div, 100:sin_cos
output reg [63:0] result,
output done
);

wire [53:0]mantissa_1;
wire [53:0]mantissa_2;
reg sign_result;
reg [10:0]exp_result;
wire [10:0]carry_exp;
wire [107:0]mantissa_result;
assign mantissa_1 ={2'b01,operand_1[51:0]};
assign mantissa_2 ={2'b01,operand_2[51:0]};
assign carry_exp = exp_result + 1;


mul_mantissa U0(
.rst_n(rst_n),
.clk(clk),
.mode(mode),
.square_done(square_done),
.a(mantissa_1),
.b(mantissa_2),
.en(enable),
.isdone(done),
.product(mantissa_result)
);


always @* begin
    sign_result = operand_1[63]^operand_2[63];
    exp_result = operand_1[62:52] + operand_2[62:52] - 1023;
    if(done == 1 ) begin
        if(operand_1 == 0 || operand_2 == 0)
            result = 0;
        else if (operand_1[62:52] == 11'b11111111111 || operand_2[62:52] == 11'b11111111111)begin
            if(operand_1[51:0] == 52'hfffffffffffff || operand_2[51:0] == 52'hfffffffffffff)
                result = 64'hffffffffffffffff;
            else
                result = {sign_result,11'b11111111111,52'd0};
        end
        else if(mantissa_result[105] == 1)
            if(mantissa_result[52] ==1 )
                if(mantissa_result[51:50] == 2'b00)
                    result = mantissa_result[53] ? {sign_result,carry_exp,mantissa_result[104:53] + 52'd1} : {sign_result,carry_exp,mantissa_result[104:53]} ;
                else
                    result ={sign_result,carry_exp,mantissa_result[104:53] + 52'd1};
            else
                result ={sign_result,carry_exp,mantissa_result[104:53]};
        else
            if(mantissa_result[51] ==1 )
                if(mantissa_result[50:49] == 2'b00)
                    result = mantissa_result[52] ? {sign_result,exp_result,mantissa_result[103:52] + 52'd1} : {sign_result,exp_result,mantissa_result[103:52]} ;
                else
                    result ={sign_result,exp_result,mantissa_result[103:52] + 52'd1};
            else
                result ={sign_result,exp_result,mantissa_result[103:52]};
 
    end
    else
        result = 0;
        

end

endmodule