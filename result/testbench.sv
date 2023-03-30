// Code your testbench here
// or browse Examples
module non_res_div_tb;
  
  reg clk;
  initial begin
    clk = 0;
    forever 
         #10 clk = ~clk;
  end
  
  reg [7:0] in_bus;
  reg rst, begin_div;
  wire fin;
  wire [7:0] out_bus;
  initial begin
    rst = 0;
    in_bus = 8'd0;
    begin_div = 0;
    #10;
    rst = 1;
    #10
    rst = 0;
    #10;
    rst = 1;
    #20;
    begin_div = 1;
    #20;
    begin_div = 0;
    in_bus = 8'b0001_1111;
    #20;
    in_bus = 8'b1010_1001;
    #20;
    in_bus = 8'b0100_1111;
    #20;
  end
  
  
  non_res_div_3_0 dut(.in_bus(in_bus), .begin_div(begin_div), .clk(clk), .rst(rst), .fin(fin), .out_bus(out_bus));
  
endmodule