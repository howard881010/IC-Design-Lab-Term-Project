module top_pipe
(
input clk,
input rst_n,
input enable,
input [63:0] operand_1,
input [63:0] operand_2,
input [2:0] mode,        // 000: add, 001: sub, 010: mul, 011:div, 100:sin_cos
output reg [63:0] result,
//output [63:0] sin_ans, 
//output [63:0] cos_ans,
output done
);

reg [3:0] state, new_state;
wire [1:0] add_cnt1, add_cnt2, add_cnt3;
wire [5:0] cordic_cnt;

wire [63:0] op1_1, op2_1;
wire [63:0] op1_2, op2_2;
wire [63:0] op1_3, op2_3;

wire sign_same1, sign_same2, sign_same3; // detect the signs of operand1 and operand2 are the sign_same
wire exp_same1, exp_same2, exp_same3;
wire [63:0] X_1, X_2;
wire [63:0] Y_1, Y_2;
wire [63:0] Z_1, Z_2;
//wire op2_bigger1, op2_bigger2, op2_bigger3;
wire [63:0] X_res, Y_res, Z_res;
reg [63:0] operand_comp1, operand_comp2;
reg [63:0] operand_mul1, operand_mul2;
wire [63:0] result_add, result_mul, result_div;
reg done_out;
reg new_done;
wire done_div;
wire done_mul;
wire NAN1, NAN2, NAN3;
//wire [1:0] INF1, INF2, INF3;     // 0 for not, 1 for positive, 2 for negetive
wire [63:0] correct_result;
wire [10:0] exponent;
wire [2:0] quadrant;
reg square_done, new_square_done;

//reg [63:0] op_comp1, op_comp2;

//assign sin_ans = Y_res;
//assign cos_ans = result;

assign done = done_out | done_mul | done_div;


add_v2 U0 
(
.clk(clk), .rst_n(rst_n), 
.op1(op1_1), .op2(op2_1), .mode(mode),
.result(result_add), .state(state), .add_cnt(add_cnt1), .sign_same(sign_same1), .exp_same(exp_same1)//, .NAN(NAN1), .INF(INF1)
);

comp U1
(
.clk(clk), .rst_n(rst_n), 
.operand_1(operand_comp1), .operand_2(operand_comp2), .state(state),
.op1(op1_1), .op2(op2_1), .mode(mode), .sign_same(sign_same1), .exp_same(exp_same1)//, .NAN(NAN1), .INF(INF1)
);


add_v2 U11           
(
.clk(clk), .rst_n(rst_n), 
.op1(op1_2), .op2(op2_2), .mode(mode),
.result(Y_res), .state(state), .add_cnt(add_cnt2), .sign_same(sign_same2), .exp_same(exp_same2)//, .NAN(NAN2), .INF(INF2)
);
comp U13
(
.clk(clk), .rst_n(rst_n), 
.operand_1(Y_1), .operand_2(Y_2), .state(state),
.op1(op1_2), .op2(op2_2), .mode(mode), .sign_same(sign_same2), .exp_same(exp_same2)//, .NAN(NAN2), .INF(INF2)
);


add_v2 U12
(
.clk(clk), .rst_n(rst_n), 
.op1(op1_3), .op2(op2_3), .mode(mode),
.result(Z_res), .state(state), .add_cnt(add_cnt3), .sign_same(sign_same3), .exp_same(exp_same3)//, .NAN(NAN3), .INF(INF3)
);

comp U14
(
.clk(clk), .rst_n(rst_n), 
.operand_1(Z_1), .operand_2(Z_2), .state(state),
.op1(op1_3), .op2(op2_3), .mode(mode), .sign_same(sign_same3), .exp_same(exp_same3)//, .NAN(NAN3), .INF(INF3)
);


cordic U2
(
.clk(clk), .rst_n(rst_n), .state(state), .operand_1(correct_result),
.X_1(X_1), .X_2(X_2), .X_res(result_add),
.Y_1(Y_1), .Y_2(Y_2), .Y_res(Y_res),
.Z_1(Z_1), .Z_2(Z_2), .Z_res(Z_res),
.cordic_cnt(cordic_cnt)
);

value_correct U22
(
.clk(clk), .rst_n(rst_n), .state(state), .operand_1(operand_1), .mode(mode),
.correct_result(correct_result), .exponent(exponent), .quadrant(quadrant)
);

div U3(
.clk(clk),
.rst_n(rst_n),
.enable(enable),
.operand_1(operand_1),
.operand_2(operand_2),
.mode(mode),
.result(result_div),
.done(done_div)
);

mul U4(
.clk(clk),
.rst_n(rst_n),
.enable(enable),
.square_done(square_done),
.operand_1(operand_mul1),
.operand_2(operand_mul2),
.mode(mode),
.result(result_mul),
.done(done_mul)
);



always @* begin
    if (mode == 4 || mode == 5 || mode == 6 || mode == 7) begin
        operand_comp1 = X_1;
        operand_comp2 = X_2;
    end
    else begin
        operand_comp1 = operand_1;
        operand_comp2 = operand_2;
    end
end

always @* begin
    if (mode == 6) begin
        operand_mul1[63] = result_add[63];
            if (exponent[10] == 1)
                operand_mul1[62:52] = result_add[62:52] - exponent[9:0];
            else 
                operand_mul1[62:52] = result_add[62:52] + exponent[9:0];
            operand_mul1[51:0] = result_add[51:0];
        operand_mul2 = 64'b0011111111110011010010000011110100001111111010111111100000100110;
    end
    else begin
        operand_mul1 = operand_1;
        operand_mul2 = operand_2;
    end
end

always @* begin
    result = 0;
    /*if (NAN1 == 1) begin
        result = 64'b1111111111111111111111111111111111111111111111111111111111111111;
    end
    else if (INF1 == 1) begin
        result = 64'b0111111111110000000000000000000000000000000000000000000000000000;
    end
    else if (INF1 == 2) begin
        result = 64'b1111111111110000000000000000000000000000000000000000000000000000;
    end*/
    
    //else begin
        case(mode) //synopsys parallel_case
            0,1,5: result = result_add;
            7: begin
                result[63] = Z_res[63];
                result[62:52] = Z_res[62:52] + 1;
                result[51:0] = Z_res[51:0];
            end
            2, 6: result = result_mul;
            3: result = result_div;
            4: begin
                if (quadrant == 1)
                    result = Y_res;
                else begin
                    result[63] = 1;
                    result[62:0] = Y_res[62:0];
                end
            end

            default: result = 0;
        endcase
    //end
end

parameter IDLE = 4'd0, COMP = 4'd1, ADD = 4'd2, MUL = 4'd3, DIV = 4'd4, SIN_COS = 4'd5, SQUARE_ROOT = 4'd6, CORRECT_MODE = 4'd7, NATURAL_LOG = 4'd8;

always @(posedge clk) begin
    if (~rst_n) begin
        state <= 0;
        done_out <= 0;
        square_done <= 0;
    end
    else begin
        state <= new_state;
        done_out <= new_done;
        square_done <= new_square_done;
    end
end

always @* begin
    new_square_done = 0;
    new_done = 0;
    new_state = 0;
    case (state) //synopsys parallel_case
        IDLE: begin
            if ((mode == 4 || mode == 5 || mode == 6 || mode == 7) && enable) begin
                new_state = CORRECT_MODE;
            end
            /*else if (mode == 7 && enable) begin
                new_state = NATURAL_LOG;
            end
            */
            else if ((mode == 1 || mode == 0) && enable) begin
                new_state = COMP;
            end
            else begin
                new_state = IDLE;
            end
        end
        CORRECT_MODE: begin
            if (mode == 4 || mode == 5) begin
                new_state = SIN_COS;
            end
            else if (mode == 6) begin
                new_state = SQUARE_ROOT;
            end
            else if (mode == 7) begin
                new_state = NATURAL_LOG;
            end
        end
        COMP: begin
            new_state = ADD;
        end
        ADD: begin
            if (add_cnt1 == 3 && (mode == 0 || mode == 1)) begin
                new_state = IDLE;
                new_done = 1;
            end
            else if (mode == 6 && add_cnt1 == 3) begin
                new_state = SQUARE_ROOT;
            end
            else if (mode == 7 && add_cnt1 == 3) begin
                new_state = NATURAL_LOG;
            end
            else if ((mode == 4 || mode == 5) && (add_cnt1 == 3 || add_cnt2 == 3 || add_cnt3 == 3)) begin
                new_state = SIN_COS;
            end
            else begin
                new_state = ADD;
            end
        end
        SIN_COS: begin
            if ((mode == 4 || mode == 5) && add_cnt1 == 0 && cordic_cnt == 30) begin
                new_state = IDLE;
                new_done = 1;
            end
            else begin
                new_state = COMP;
            end
        end
        SQUARE_ROOT: begin
            if (add_cnt1 == 0 && cordic_cnt == 30 && mode == 6) begin
                new_state = IDLE;
                new_square_done = 1;
            end
            else begin
                new_state = COMP;
            end
        end
        NATURAL_LOG: begin
            if (add_cnt1 == 0 && cordic_cnt == 24 && mode == 7) begin
                new_state = IDLE;
                new_done = 1;
            end
            else begin
                new_state = COMP;
            end
        end
        default: new_state = IDLE;
    endcase
end

endmodule

