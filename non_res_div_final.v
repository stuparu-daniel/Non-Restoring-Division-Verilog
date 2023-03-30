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
