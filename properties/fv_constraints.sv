// -------------------------------------------------
// Copyright(c) LUBIS EDA GmbH, All rights reserved
// Contact: contact@lubis-eda.com
// -------------------------------------------------


module fv_constraints
#(
    parameter WIDTH = 4     
) (
    //#$ports
    input logic                                       clk,
    input logic                                       rst,
    input logic [WIDTH-1:0]                           out
    //$#//

);
    //#$localparams
    //$#//

    default clocking default_clk @(posedge clk); endclocking

   

endmodule
