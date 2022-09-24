module mul_mantissa
(
input rst_n,
input clk,
input [2:0]mode,
input square_done,
input [53:0] a,
input [53:0] b,
input en,
output reg isdone,
output [107:0]product
);
reg n_isdone;
reg[2:0] state, n_state;
reg[53:0] ra, n_ra;
reg[53:0] rs, n_rs;
reg[108:0] rp, n_rp;
reg[6:0] P_CNT, n_P_CNT;

always @(posedge clk) begin
     if(~rst_n) begin
          state <= 0;
          ra <= 0;
          rs <= 0;
          rp <= 0;
          P_CNT <= 0;
          isdone <= 0;
     end
     else begin
          state <= n_state;
          ra <= n_ra;
          rs <= n_rs;
          rp <= n_rp;
          P_CNT <= n_P_CNT;
          isdone <= n_isdone;
     end
end


always @* begin
     n_state = state;
     n_ra = a;
     n_rs = (~a+1);
     n_rp = rp;
     n_P_CNT = P_CNT;
     n_isdone = isdone;

     case(state) //synopsys parallel_case
          3'd0: begin
               n_rp = {54'd0,b,1'b0};
               if((en && mode == 2) || square_done ==1)
                    n_state = state+1;
               else
                    n_state = state;  
          end
          3'd1: begin
               if(P_CNT==54) begin
                    n_P_CNT =0;
                    n_state = state+2;
               end
               else if(rp[1:0]==2'b01) begin
                    n_rp = {rp[108:55]+ra,rp[54:0]};
                    n_state = state+1;
               end
               else if(rp[1:0]==2'b10) begin
                    n_rp = {rp[108:55]+rs,rp[54:0]};
                    n_state = state+1;
               end
               else
                    n_state = state+1;
               end
          3'd2: begin
               n_rp = {rp[108],rp[108:1]};
               n_P_CNT = P_CNT+1;
               n_state = state-1;
          end
          3'd3: begin
               n_isdone = 1;
               n_state = state+1;
          end
          3'd4: begin
               n_isdone = 0;
               n_state = 0;
          end
     endcase

end

assign product=rp[108:1];

endmodule