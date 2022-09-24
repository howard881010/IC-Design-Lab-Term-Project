module value_correct
(
input clk,
input rst_n,
input [63:0] operand_1,
input [3:0] state,
input [2:0] mode,
output reg [63:0] correct_result,
output reg [10:0] exponent,
output reg [2:0] quadrant
);

parameter IDLE = 4'd0, COMP = 4'd1, ADD = 4'd2, MUL = 4'd3, DIV = 4'd4, SIN_COS = 4'd5, SQUARE_ROOT = 4'd6, CORRECT_MODE = 4'd7;

reg [63:0] new_correct_result;
reg [10:0] new_exponent;
reg [2:0] new_quadrant;

always @(posedge clk) begin
    if (~rst_n) begin
        correct_result <= 0;
        exponent <= 0;
        quadrant <= 0;
    end
    else begin
        correct_result <= new_correct_result;
        if (state == CORRECT_MODE && (mode == 4 || mode == 5)) begin
            quadrant <= new_quadrant;
        end
        if (state == CORRECT_MODE && mode == 6) begin
            exponent <= new_exponent;
        end
    end
end

always @* begin
    new_quadrant = 0;
    new_exponent = 0;
    new_correct_result = 0;

    if (state == CORRECT_MODE && (mode == 4 || mode == 5)) begin
        new_correct_result[62:0] = operand_1[62:0];
        new_correct_result[63] = 0;
        if (operand_1[63] == 1) begin
            new_quadrant = 4;
        end
        else begin
            new_quadrant = 1;
        end
    end
    else if (state == CORRECT_MODE && mode == 7) begin
        new_correct_result = operand_1;
    end
    else if (state == CORRECT_MODE && mode == 6) begin
        new_correct_result[63] = operand_1[63];
        new_correct_result[51:0] = operand_1[51:0];

        if (operand_1[62] == 1) begin  // > 2
            new_exponent[10] = 0;
            new_exponent[9:0] = operand_1[62:53] - 10'b1000000000 + 1;
            if (operand_1[52] == 0) begin
                new_correct_result[62:52] = 11'b01111111110;
            end
            else begin
                new_correct_result[62:52] = 11'b01111111111;  
            end  
        end
        else if (operand_1[61:52] < 10'b1111111110) begin
            new_exponent[10] = 1;
            new_exponent[9:0] = 10'b0111111111 - operand_1[62:53];
            if (operand_1[52] == 0) begin
                new_correct_result[62:52] = 11'b01111111110;
            end
            else begin
                new_correct_result[62:52] = 11'b01111111111;  
            end 
        end
        else begin
            new_correct_result[62:52] = operand_1[62:52];
            new_exponent = 0;
        end
    end
end


endmodule