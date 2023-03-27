
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

  wire [8:0] carries;
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
