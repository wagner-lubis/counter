module customer_counter #(
    parameter WIDTH = 4
) 
(   
  input logic                  clk,               
  input logic                  rst,             
  output logic [WIDTH-1:0]     out
);   

  always_ff @ (posedge clk, posedge rst) begin
    if (rst)
      out <= 0;
    else
      out <= out + 1;
  end
endmodule