module div
(
input clk,
input rst_n,
input enable,
input [63:0] operand_1,
input [63:0] operand_2,
input [2:0] mode,        // 000: add, 001: sub, 010: mul, 011:div, 100:sin_cos
output reg [63:0] result,
output done
);
parameter DATAWIDTH = 57;
wire [56:0]mantissa_1;
wire [56:0]mantissa_2;
reg sign_result;
reg [10:0]exp_result;
wire [10:0]back_exp;
wire [56:0]mantissa_result;
//wire [56:0]remainder;
assign mantissa_1 = (operand_1[62:52] == 8'd0) ? {4'b0000,1'b0,operand_1[51:0]} : {4'b0000,1'b1,operand_1[51:0]};
assign mantissa_2 = (operand_2[62:52] == 8'd0) ? {4'b0000,1'b0,operand_2[51:0]} : {4'b0000,1'b1,operand_2[51:0]};
assign back_exp = exp_result - 1;


div_mantissa #(
.DATAWIDTH (DATAWIDTH)
)
U0(
.rst_n(rst_n),
.clk(clk),
.en(enable),
.mode(mode),
.dividend(mantissa_1),
.divisor(mantissa_2),
.isdone(done),
.quotient(mantissa_result)//,
//.remainder(remainder)
);


always @* begin
    sign_result = operand_1[63]^operand_2[63];
    exp_result = operand_1[62:52] - operand_2[62:52] + 1023;
    if(done == 1 ) begin
        if(operand_1 == 0)
            result = 64'd0;
        else if(operand_2 == 0)
            result =64'hffffffff_ffffffff;
        else if (operand_1[62:52] == 11'b11111111111 || operand_2[62:52] == 11'b11111111111)begin
            if(operand_1[51:0] == 52'hfffffffffffff || operand_2[51:0] == 52'hfffffffffffff)
                result = 64'hffffffffffffffff;
            else
                result = {sign_result,11'b11111111111,52'd0};
        end
        else if(mantissa_result[56] == 1)//don't need renormalize
            if(mantissa_result[3] ==1 )//need rounding or not
                if(mantissa_result[2:1] == 2'b00)
                    result = mantissa_result[4] ? {sign_result,exp_result,mantissa_result[55:4] + 52'd1} : {sign_result,exp_result,mantissa_result[55:4]} ;
                else
                    result ={sign_result,exp_result,mantissa_result[55:4] + 52'd1};
            else
                result ={sign_result,exp_result,mantissa_result[55:4]};
        else//need renormalize
            if(mantissa_result[2] ==1 )//need rounding or not
                if(mantissa_result[1:0] == 2'b00)
                    result = mantissa_result[3] ? {sign_result,back_exp,mantissa_result[54:3] + 52'd1} : {sign_result,back_exp,mantissa_result[54:3]} ;
                else
                    result ={sign_result,back_exp,mantissa_result[54:3] + 52'd1};
            else
                result ={sign_result,back_exp,mantissa_result[54:3]};
    end
    else
        result = 64'd0;
        

end

endmodule