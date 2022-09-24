module add_v2
(
input clk,
input rst_n,
input [63:0] op1,
input [63:0] op2,
input [3:0] state,
//input [2:0] round_bit,
input [2:0] mode,
input exp_same,
input sign_same,
//input NAN,
//input [1:0] INF,
output reg [1:0] add_cnt,
output reg [63:0] result
);

reg [13:0] C;
reg [12:0] G;
reg [12:0] P;
reg carry, new_carry;
reg [1:0] cnt;
integer i;
reg [12:0] tmp_result;
reg [7:0] tmp;
//reg [4:0] shift, shift;     // exponent
reg [5:0] shift, shift1;
reg [51:0] tmp_renormal;
reg [51:0] tmp_shift;
integer a;
//reg [8:0] tmp_exp;


parameter IDLE = 4'd0, COMP = 4'd1, ADD = 4'd2, MUL = 4'd3, DIV = 4'd4, SIN_COS = 4'd12;

always @(posedge clk) begin
    if (~rst_n) begin
        cnt <= 0;
        carry <= 0;
        result <= 0;
        //shift <= 0;
        //shift1 <= 0;
    end
    else begin
        //shift <= shift;
        if (state == ADD) begin
            //if (cnt == 3) begin
                //cnt <= 0;
            //end
            //else begin
                cnt <= cnt + 1;
            //end

            carry <= new_carry;
            /*if (NAN == 1) begin
                result <= 64'b1111111111111111111111111111111111111111111111111111111111111111;
            end
            else if (INF == 1) begin
                result <= 64'b0111111111110000000000000000000000000000000000000000000000000000;
            end
            else if (INF == 2) begin
                result <= 64'b1111111111110000000000000000000000000000000000000000000000000000;
            end
            */
            if (sign_same) begin
                if (cnt == 3) begin
                    //if ((C[13] && exp_same == 0) || (C[13] == 0 && exp_same)) begin
                    if (C[13] ^ exp_same) begin
                        result[63:52] <= op1[63:52] + 1;
                        result[51] <= 0;
                        result[50:38] <= tmp_result[12:0];
                        result[37:0] <= result[38:1];
                    end
                    else if (C[13] && exp_same == 1) begin
                        result[63:52] <= op1[63:52] + 1;
                        result[51] <= 1;
                        result[50:38] <= tmp_result[12:0];
                        result[37:0] <= result[38:1];
                    end
                    else begin
                        result[51:39] <= tmp_result[12:0];
                        if (op1[62:52] == 0) begin
                            result[63:52] <= op2[63:52];
                        end
                        else begin
                            result[63:52] <= op1[63:52];
                        end
                    end
                end
                else begin
                    result[cnt * 13 + 12 -:13] <= tmp_result;
                end
            end
            else begin
                if (cnt == 3) begin
                    if (C[13] && exp_same == 0) begin
                        result[51:39] <= tmp_result[12:0];
                        result[63:52] <= op1[63:52];
                        
                    end
                    else if (op2[62:0] == 0 || (op2[51:0] == 0 && mode == 6)) begin
                        result[51:39] <= tmp_result[12:0];
                        result[63:52] <= op1[63:52];
                    end
                    else begin
                        result[51:0] <= tmp_shift[51:0];
                        result[63:52] <= op1[63:52] - (shift + shift1);
                    end
                end
                else begin
                    result[cnt * 13 + 12 -:13] <= tmp_result;
                end
            end
        end
    end
end

always @* begin
    add_cnt = cnt;
    new_carry = 0;
    //a = 0;
    shift = 0;
    shift1 = 0;
    tmp_renormal = 0;
    tmp_shift = 0;
    //tmp_result = 0;
    //tmp_exp = 0;
    if (state == ADD) begin
        if (cnt == 0) begin     
            C[0] = 0;
        end
        else
            C[0] = carry;
        
        for (i = 0; i < 13; i = i + 1) begin
            G[i] = op1[cnt * 13 + i] & op2[cnt * 13 + i];
            P[i] = op1[cnt * 13 + i] ^ op2[cnt * 13 + i];
            C[i + 1] = G[i] + C[i] * P[i];
            tmp_result[i] = C[i] + op1[cnt * 13 + i] + op2[cnt * 13 + i];
        end
        new_carry = C[13];
        if (cnt == 3 && ~sign_same && (C[13] == 0 || exp_same == 1)) begin    // need to shift to renormalize, the process is to find the first 1
            a = 0;
            for (i = 0; i < 13; i = i + 1) begin
                if (tmp_result[12 - i] == 1) begin
                    if (a == 0)
                        a = i + 1;
                end
            end
            shift = a;
            a = 0;
            if (shift == 0) begin
                for (i = 0; i < 39; i = i + 1) begin
                    if (result[38-i] == 1) begin
                        if (a == 0)
                            a = 14 + i;
                    end
                end
            end
            shift1 = a;
            
            tmp_renormal[51:39] = tmp_result[12:0];
            tmp_renormal[38:0] = result[38:0];
            tmp_shift[51:0] = tmp_renormal[51:0] << (shift + shift1);
            //tmp_exp[8:0] = op1[63:52] - shift;
        end
        
    end
    else begin
        C = 0;
        G = 0;
        P = 0;
        tmp_result = 0;
    end
end

endmodule
