module div_mantissa

#(
parameter DATAWIDTH=24
)
(
    input clk,
    input rst_n,
    input en,
    input [DATAWIDTH-1:0] dividend,
    input [DATAWIDTH-1:0] divisor,
    input [2:0]mode,
    output isdone,
    //output ready,
    output [DATAWIDTH-1:0] quotient//,
    //output [DATAWIDTH-1:0] remainder
);

reg [DATAWIDTH*2-1:0] dividend_e;
reg [DATAWIDTH*2-1:0] divisor_e;
reg [DATAWIDTH-1:0] quotient_e;
//reg [DATAWIDTH-1:0] remainder_e;


reg [1:0] state, n_state;

reg [DATAWIDTH-1:0] CNT;

parameter IDLE =2'b00, SUB  =2'b01, SHIFT=2'b10, DONE =2'b11;

always@(posedge clk)
    if(~rst_n) 
        state <= IDLE;
    else 
        state <= n_state;

always @(*) begin
    if(~rst_n)
        n_state = IDLE;
    else
        case(state) //synopsys parallel_case
        IDLE: begin
            if(en && mode == 3)
                n_state = SUB;
            else   
                n_state = IDLE;
        end
        SUB: begin
            n_state = SHIFT;
        end
        SHIFT: begin
            if(CNT<DATAWIDTH-1) 
                n_state = SUB;
            else 
                n_state = DONE;
        end
        DONE: n_state = IDLE;
        endcase
end

 
always@(posedge clk) begin
    if(~rst_n)begin
        dividend_e <= 0;
        divisor_e <= 0;
        quotient_e <= 0;
        //remainder_e <= 0;
        CNT <= 0;
    end 
    else begin 
        case(state)//synopsys parallel_case
        IDLE:begin
                dividend_e <= {{DATAWIDTH{1'b0}},dividend};
                divisor_e <= {{DATAWIDTH{1'b0}},divisor};
        end
        SUB:begin
            if(dividend_e>=divisor_e)begin
                quotient_e <= {quotient_e[DATAWIDTH-2:0],1'b1};
                dividend_e <= dividend_e-divisor_e;
            end
            else begin
                quotient_e <= {quotient_e[DATAWIDTH-2:0],1'b0};
                dividend_e <= dividend_e;
            end
        end
        SHIFT:begin
            if(CNT<DATAWIDTH-1)begin
                dividend_e <= dividend_e << 1;
                CNT <= CNT+1;		 
            end
            else begin
                //remainder_e <= dividend_e[DATAWIDTH*2-1:DATAWIDTH];
            end
        end
        DONE:begin
            CNT <= 0;
        end	 
        endcase
    end
end
  
assign quotient  = quotient_e;
//assign remainder = remainder_e;

//assign ready=(state==IDLE)? 1'b1:1'b0;
assign isdone=(state==DONE)? 1'b1:1'b0;
	       
endmodule
