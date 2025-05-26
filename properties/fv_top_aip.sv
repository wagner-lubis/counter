module fv_customer_counter_aip
#(
    parameter WIDTH = 4
) (
    //#$ports
    input logic                 clk,
    input logic                 rst,
    input logic [WIDTH-1:0]     out
    //$#//
);
    //#$localparams
    //$#//
    fv_constraints #(
        .WIDTH(WIDTH)
    ) fv_constraints_i (.*);

    fv_scenarios #(
        .WIDTH(WIDTH)
    ) scenarios_i (.*);

    fv_counter #(
        .WIDTH(WIDTH)
    ) fv_counter_i (.*);

endmodule


bind customer_counter fv_customer_counter_aip 
#(
    .WIDTH(WIDTH)
) 
fv_customer_counter_aip_i
(
    //#$bind
    .clk (clk),
    .rst (rst),
    .out (out)   
    //$#//
);