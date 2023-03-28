`define IDLE 4'b0000
`define LD_A 4'b0001
`define LD_Q 4'b0010
`define LD_M 4'b0011
`define CHECK_SIGN 4'b0100
`define ADD 4'b0101
`define SUB 4'b0110
`define SET_LSB_Q 4'b0111
`define LEFT_SHIFT 4'b1000
`define CHECK_COUNT 4'b1001
`define END 4'b1010

module control_unit(
  input clk, rst,
  input begin_div,
  input sign,
  output reg ld_a,
  output reg ld_m,
  output reg ld_q,
  output reg ld_sign,
  output reg operation,
  output reg left,
  output reg set_lsb,
  output reg ld_sum,
  output reg [2:0] count,
  output reg fin
);

reg [3:0] state_next, state_reg;

always @(posedge clk or negedge rst) begin
		if(!rst)
			state_reg <= 4'b0000;
		else
			state_reg <= state_next;
	 end
	 
initial begin
  ld_a = 0;
  ld_q = 0;
  ld_m = 0;
  ld_sign = 0;
  operation = 0;
  set_lsb = 0;
  count = 0;
  ld_sum = 0;
  left = 0;
  fin = 0;
end
	 
always @(state_reg, begin_div) begin
  
  state_next = state_reg;
  case(state_reg)
    
    `IDLE: 
	         begin
	         state_next = `IDLE;
	         if(begin_div) begin
	           state_next = `LD_A;
	           ld_a = 1;
	           end 
	         end
	         
	   `LD_A:
	         begin
	             ld_a = 0;
	             state_next = `LD_Q;
	             ld_q = 1;
	         end
	               
	    `LD_Q:
	         begin
	             ld_q = 0;
	             state_next = `LD_M;
	             ld_m = 1;
	         end
	         
	    `LD_M:
	         begin
	             ld_m = 0;
	             left = 1;
	             state_next = `LEFT_SHIFT;
	         end
	         
	     `LEFT_SHIFT:
	           begin
	               left = 0;
	               state_next = `CHECK_SIGN;
	           end
	      
	      `CHECK_SIGN:
	         begin
	           ld_sum = 1;
	           ld_sign = 1;
	           if(sign) begin
	             state_next = `ADD;
	             operation = 1;
	             end
	           else begin
	             state_next = `SUB;
	             operation = 0;
	             end
	         end
	         
	       `ADD:
	           begin
	               operation = 0;
	               ld_sum = 0;
	               ld_sign = 0;
	               if(count == 3'b111) begin
	                 set_lsb = 1;
	                 state_next = `END;
	                 end
	               else begin
	                 set_lsb = 1;
	                 state_next = `SET_LSB_Q;
	                 end
	           end
	           
	         `SUB:
	           begin
	               operation = 1;
	               ld_sum = 0;
	               ld_sign = 0;
	               set_lsb = 1;
	               state_next = `SET_LSB_Q;
	           end
	           
	          `SET_LSB_Q:
	            begin
	                ld_sum = 0;
	                set_lsb = 0;
                  state_next = `CHECK_COUNT;
	            end
	           
	          `CHECK_COUNT:
	             begin
	               set_lsb = 0;
	               if(count == 3'b111)
	                 begin
	                   if(sign) begin
	                     ld_sum = 1;
	                     operation = 1;
	                     state_next = `ADD; //correction step
	                     end
	                   else
	                      state_next = `END;  
	                 end
	               else begin
	                 state_next = `LEFT_SHIFT;
	                 left = 1;
	                 count = count + 1;
	               end
	             end 
	      
	           `END:
	             begin
	                 set_lsb = 0;
	                 ld_sum = 0;
	                 fin = 1;
	                 count = 0;
	                 state_next = `IDLE;
	             end
  endcase
  
end

endmodule
