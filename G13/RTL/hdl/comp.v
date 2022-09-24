module comp
(
input clk,
input rst_n,
input [63:0] operand_1,
input [63:0] operand_2,
input [3:0] state,
input [2:0] mode,         
output reg [63:0] op1,
output reg [63:0] op2,
output reg sign_same,
output reg exp_same//,
//output reg op2_bigger,
//output reg [2:0] round_bit,
//output reg NAN,
//output reg [1:0] INF
);

reg [63:0] tmp_op1, tmp_op2;
reg [51:0] shift;
reg [5:0] diff;
reg [4:0] a;
reg tmp_sign_same;
reg tmp_exp_same;
//reg [2:0] new_round_bit;
//reg new_op2_bigger;
reg add_sub;     // 0 for addition, 1 for subtraction
//reg tmp_NAN;
//reg [1:0] tmp_INF;

parameter IDLE = 4'd0, COMP = 4'd1, ADD = 4'd2;

always @(posedge clk) begin
    if(~rst_n) begin
        op1 <= 0;
        op2 <= 0;
        sign_same <= 0;
        //round_bit <= 0;
        //op2_bigger <= 0;
        exp_same <= 0;
        //INF <= 0;
        //NAN <= 0;
        
    end
    else begin
        if (state == COMP) begin
            op1 <= tmp_op1;
            op2 <= tmp_op2;
            sign_same <= tmp_sign_same;
            //op2_bigger <= new_op2_bigger;
            //round_bit <= new_round_bit;
            exp_same <= tmp_exp_same;
            //NAN <= tmp_NAN;
            //INF <= tmp_INF;
        end
    end

end

always @* begin
    if (mode == 0 || mode == 4 || mode == 5) begin
        add_sub = 0;
    end
    else if (mode == 1) begin
        add_sub = 1;
    end
    else 
        add_sub = 0;
end

always @* begin
    tmp_op1 = 0;
    tmp_op2 = 0;
    shift = 0;
    shift = 0;
    //new_round_bit = 0;
    tmp_exp_same = 0;
    tmp_sign_same = 0;
    diff = 0;
    //tmp_NAN = 0;
    //tmp_INF = 0;
    //new_op2_bigger = 0;

    if (state == COMP) begin
        if (((operand_2[63] == operand_1[63]) && add_sub == 0) || ((operand_2[63] != operand_1[63]) && add_sub == 1) || (operand_2[62:0] == 0) || (operand_1[62:0] == 0)) 
            tmp_sign_same = 1;
        

        if (operand_2 == 0) begin
            tmp_op1 = operand_1;
            tmp_op2[63] = operand_1[63];
            tmp_op2[62:0] = 0;
        end
        else if (operand_1 == 0) begin
            tmp_op1[63] = operand_2[63];
            tmp_op1[62:0] = 0;
            tmp_op2 = operand_2;
        end
        /*else if (operand_1[62:51] == 12'b111111111111 || operand_2[62:51] == 12'b111111111111) begin      // detection of NAN
            tmp_NAN = 1;
        end
        else if (operand_1[62:52] == 11'b11111111111 || operand_2[62:52] == 11'b11111111111) begin      // detection of INF
            if ((operand_1[62:52] == operand_2[62:52]) && (((operand_2[63] == operand_1[63]) && add_sub == 1) || ((operand_2[63] != operand_1[63]) && add_sub == 0)))
                tmp_NAN = 1;
            else if (operand_1[63:52] == 12'b111111111111)
                tmp_INF = 2;
            else if ((operand_2[63:52] == 12'b111111111111 && add_sub == 0) && (operand_2[63:52] == 12'b011111111111 && add_sub == 1))
                tmp_INF = 2;
            else 
                tmp_INF = 1;
        end*/
        else if (operand_1[62:52] > operand_2[62:52]) begin
            tmp_op1[62:0] = operand_1[62:0];
            //tmp_op2[63] = operand_1[63];
            tmp_op2[62:52] = operand_1[62:52];
            diff = operand_1[62:52] - operand_2[62:52];
            if (diff > 52) begin
                shift[51:0] = 0;
            end
            else begin
                shift[51:0] = operand_2[51:0] >> diff;
                shift[52-diff] = 1;
            end
            
            /*if (diff > 2)
                new_round_bit = operand_2[diff -:3];
            else if (diff > 1)
                new_round_bit[2:1] = operand_2[diff -:2];
            else
                new_round_bit[2] = operand_2[diff];
            */
            
            if (((operand_2[63] == operand_1[63]) && add_sub == 0) || ((operand_2[63] != operand_1[63]) && add_sub == 1)) begin        // pos + pos or neg + neg
                //tmp_op2[51:0] = operand_2[51:0] >> diff;
                //tmp_op2[52-diff] = 1;
                tmp_op2[51:0] = shift;
            end
            else begin                                      // pos + neg 
                if (operand_2[diff-1])  //round
                    tmp_op2[51:0] = ~(shift + 1) + 1;
                else 
                    tmp_op2[51:0] = ~shift + 1;
            end

            //
            //if (add_sub == 0) begin
                tmp_op2[63] = operand_1[63];
                tmp_op1[63] = operand_1[63];
            //end
            //else begin
                //tmp_op2[63] = operand_1[63];
                //tmp_op1[63] = operand_1[63];
            //end

        end
        else if (operand_2[62:52] > operand_1[62:52])begin
            //new_op2_bigger = 1;
            tmp_op2[62:0] = operand_2[62:0];
            tmp_op1[62:52] = operand_2[62:52];
            //tmp_op1[63] = operand_2[63];
            diff = operand_2[62:52] - operand_1[62:52];
            if (diff > 52) begin
                shift[51:0] = 0;
            end
            else begin
                shift[51:0] = operand_1[51:0] >> diff;
                shift[52-diff] = 1;    
            end
            
            /*if (diff > 2)
                new_round_bit = operand_1[diff -:3];
            else if (diff > 1)
                new_round_bit[2:1] = operand_1[diff -:2];
            else
                new_round_bit[2] = operand_1[diff];
            */

            if (((operand_2[63] == operand_1[63]) && add_sub == 0) || ((operand_2[63] != operand_1[63]) && add_sub == 1)) begin
                //tmp_op1[51:0] = operand_1[51:0] >> diff;
                //tmp_op1[52-diff] = 1;
                tmp_op1[51:0] = shift;
            end
            else begin
                if (operand_1[diff-1])  //round
                    tmp_op1[51:0] = ~(shift+1) + 1;
                else 
                    tmp_op1[51:0] = ~shift + 1;
                //tmp_op1[51:0] = ~(operand_1[51:0] >> diff) + 1;
            end
            if (add_sub == 0) begin
                tmp_op2[63] = operand_2[63];
                tmp_op1[63] = operand_2[63];
            end
            else begin
                tmp_op2[63] = ~operand_2[63];
                tmp_op1[63] = ~operand_2[63];
            end
        end
        else begin
            tmp_exp_same = 1;
            if (((operand_2[63] == operand_1[63]) && add_sub == 0) || ((operand_2[63] != operand_1[63]) && add_sub == 1)) begin
                if (add_sub == 0) begin
                    tmp_op1 = operand_1;
                    tmp_op2 = operand_2;
                end
                else begin
                    tmp_op1 = operand_1;
                    tmp_op2[63] = ~operand_2[63];
                    tmp_op2[62:0] = operand_2[62:0];
                end
            end
            else begin
                if (operand_2[51:0] > operand_1[51:0]) begin          // direct or compare 1 or 0
                    tmp_op1[62:52] = operand_1[62:52];     // exp is tre sign_same 
                    tmp_op2[62:52] = operand_2[62:52];

                    tmp_op1[51:0] = (~operand_1[51:0]) + 1;
                    tmp_op2[51:0] = operand_2[51:0];
                    if (add_sub == 0) begin
                        tmp_op2[63] = operand_2[63];
                        tmp_op1[63] = operand_2[63];
                    end
                    else begin
                        tmp_op2[63] = ~operand_2[63];
                        tmp_op1[63] = ~operand_2[63];
                    end
                end
                else if (operand_2[51:0] < operand_1[51:0]) begin
                    tmp_op1[62:52] = operand_1[62:52];     // exp is tre sign_same 
                    tmp_op2[62:52] = operand_2[62:52];
                    tmp_op2[51:0] = (~operand_2[51:0]) + 1;
                    tmp_op1[51:0] = operand_1[51:0];
                    if (add_sub == 0) begin
                        tmp_op2[63] = operand_1[63];
                        tmp_op1[63] = operand_1[63];
                    end
                    else begin
                        tmp_op2[63] = operand_1[63];
                        tmp_op1[63] = operand_1[63];
                    end
                end
                else begin
                    tmp_op2 = 0;
                    tmp_op1 = 0;
                end
            end
        end
    end
end

endmodule