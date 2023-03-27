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
       //sign <= in_bus[7];
     end
      else if(ld_sum) begin
        //sign <= rez[7];
        rez <= sum;
      end
      else if( left_shift ) begin
        //sign <= rez[7];
        rez <= rez << 1;
        rez[0] <= lsb;
      end
      //sign <= rez[7];
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
