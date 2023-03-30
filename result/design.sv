// Code your design here
module reg_m(
  input clk, rst, ld_in_bus, 
  input [7:0] in_bus,
  output reg [7:0] rez
);
  always @ ( posedge clk or negedge rst )
    if ( !rst ) rez <= 0;
    else if ( ld_in_bus ) rez <= in_bus;
endmodule

module reg_q(
  input clk, rst, ld_in_bus, left_shift, set_lsb, lsb,
  input [7:0] in_bus,
  output reg [7:0] rez
);

  always @ ( posedge clk or negedge rst )
    if ( !rst ) rez <= 0;
      else if ( ld_in_bus ) rez <= in_bus;
      else if( left_shift ) begin
        rez <= rez << 1;
      end
      else if(set_lsb) begin
        rez[0] <= lsb;  
      end
endmodule

module reg_a(
  input clk, rst, ld_in_bus, ld_sum, left_shift, lsb,
  input [7:0] in_bus,
  input [7:0] sum,
  output reg [7:0] rez
);

  always @ ( posedge clk or negedge rst ) begin
    if ( !rst ) rez <= 0;
      else if ( ld_in_bus ) begin
       rez <= in_bus;
     end
      else if(ld_sum) begin
        rez <= sum;
      end
      else if( left_shift ) begin
        rez <= rez << 1;
        rez[0] <= lsb;
      end
    end

endmodule

module reg_out(
  input clk, rst, ld_in_bus,
  input [7:0] in1,
  input [7:0] in2,
  output reg [7:0] rez
);

reg aux;

always @ (posedge clk or negedge rst) begin
  if(!rst) begin
    rez <= 0;
    aux <= 0;
  end
  else if(ld_in_bus)
    if(aux == 0) begin
      rez <= in1;
      aux <= 1;
    end
    else begin
      rez <= in2;
      aux <= 0;
    end    
end

endmodule

module reg_sign(
  input clk, rst, ld, in,
  output reg rez
  );
  
  always @ (posedge clk or negedge rst) begin
    if(!rst)
      rez <= 0;
    else
      if(ld)
        rez <= in;
  end
  
endmodule

module reg_counter(
  input clk, rst, increment,
  output reg [2:0] rez,
  output reg count_is_7
);

always @ (posedge clk or negedge rst) begin
  if(!rst) begin
    rez <= 3'b000;
    count_is_7 <= 0;
  end
  else if(rez == 3'b111) begin
    rez <= 3'b000;
    count_is_7 <= 1;
    end
  else if(increment)
    rez <= rez + 1;
end

endmodule


module FAC(
  input x, y, c_in,
  output z, c_out
  );
  
  assign z = x ^ y ^ c_in;
  assign c_out = (x & y) | (x & c_in) | (y & c_in);
  
endmodule

module parallel_adder_subtractor(
  input operation_type,
  input sign_in,
  input [7:0] x,
  input [7:0] y,
  output [7:0] result,
  output sign_out
);

  wire [9:0] carries;
  wire [8:0] sum;
  
  reg [8:0] x_ext;
  reg [8:0] y_ext;
  
  assign carries[0] = ~operation_type;
  
  always @(*) begin
    x_ext = {sign_in, x};
    y_ext = {1'b0, y};
  end
  
  genvar i;
  generate
    for (i = 0; i < 9; i = i + 1) begin
      FAC add_inst(.x(x_ext[i]), .y((operation_type) ? y_ext[i] : ~y_ext[i]), .c_in(carries[i]), .z(sum[i]), .c_out(carries[i+1]));
    end
  endgenerate
  
  assign result = sum[7:0];
  assign sign_out = sum[8];
  
endmodule

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
  input sign, cnt7,
  output reg ld_a,
  output reg ld_m,
  output reg ld_q,
  output reg ld_sign,
  output reg operation,
  output reg left,
  output reg set_lsb,
  output reg ld_sum,
  output reg increment,
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
  increment = 0;
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
	               increment = 0;
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
	               if(cnt7) begin
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
	               if(cnt7)
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
	                 increment = 1;
	               end
	             end 
	      
	           `END:
	             begin
	                 set_lsb = 0;
	                 ld_sum = 0;
	                 fin = 1;
	                 increment = 0;
	                 state_next = `IDLE;
	             end
  endcase
  
end

endmodule


module non_res_div_3_0(
  input [7:0] in_bus,
  input begin_div,
  input clk, rst,
  output fin,
  output [7:0] out_bus
  );
  
  wire [7:0] a;
  wire [7:0] q;
  wire [7:0] m;
  wire [7:0] rez;
  wire [2:0] count;
  wire left;
  wire ld_a;
  wire ld_q;
  wire ld_m;
  wire ld_sign;
  wire sign_in;
  wire sign_out;
  wire ld_sum;
  wire set_lsb;
  wire increment;
  wire cnt7;
  wire finish;
  wire operation;
  wire [7:0] out;
  
  
  reg_sign inst0(.clk(clk), .rst(rst), .ld(ld_sign), .in(sign_out), .rez(sign_in));
  
  reg_a inst1(.clk(clk), .rst(rst), .ld_in_bus(ld_a), .ld_sum(ld_sum), .left_shift(left), .lsb(q[7]), .in_bus(in_bus), .sum(rez), .rez(a));
  
  reg_q inst2(.clk(clk), .rst(rst), .ld_in_bus(ld_q), .left_shift(left), .set_lsb(set_lsb), .lsb(~sign_in), .in_bus(in_bus), .rez(q));
  
  reg_m inst3(.clk(clk), .rst(rst), .ld_in_bus(ld_m), .in_bus(in_bus), .rez(m));
  
  reg_counter inst4(.clk(clk), .rst(rst), .increment(increment), .rez(count), .count_is_7(cnt7));
  
  parallel_adder_subtractor pa(.operation_type(operation), .sign_in(sign_in), .x(a), .y(m), .result(rez), .sign_out(sign_out));
  
  control_unit cu(.clk(clk), .rst(rst), .begin_div(begin_div), .sign(sign_in), .cnt7(cnt7), .ld_a(ld_a), .ld_m(ld_m), .ld_q(ld_q), .ld_sign(ld_sign), .operation(operation), 
                  .left(left), .set_lsb(set_lsb), .ld_sum(ld_sum), .increment(increment), .fin(finish));
                  
  reg_out inst5(.clk(clk), .rst(rst), .ld_in_bus(fin), .in1(a), .in2(q), .rez(out));               
                  
  assign fin = finish;
  assign out_bus = out;                
                  
  
endmodule