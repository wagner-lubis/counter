// -------------------------------------------------
// Copyright(c) LUBIS EDA GmbH, All rights reserved
// Contact: contact@lubis-eda.com
// -------------------------------------------------

module fv_scenarios

#(
    parameter WIDTH = 4
) (
    //#$ports
    input logic                                       clk,
    input logic                                       rst,
    input logic [WIDTH-1:0]                           out
    
    //$#//
);

    default clocking default_clk @ (posedge clk); endclocking


    property upper_bound(counter, value);
        disable iff(rst)
        counter <= value;
    endproperty

    // Scenario-specific assume properties
    `ifdef DEFAULT_UPPERBOUND
        assume_counter_upper_bound: assume property(upper_bound(out, 14));
    `endif

    `ifdef SCENARIO_8_BIT
        assume_counter_upper_bound: assume property(upper_bound(out, 254));
    `endif

    /// These assumptions serve no purpose other than testing gen blocks with assume statement
    generate
        for (genvar i = 1; i < 3; i++) begin
            localparam int value = ((1 << WIDTH) << i); // upper bound to beyound the width
            assume_counter_upper_bound: assume property(upper_bound(out, value));
        end
    endgenerate
    
    
    generate
        for (genvar i = 3; i < 5; i++) begin: useless_assumtpion_gen_block
            localparam int value = ((1 << WIDTH) << i); // upper bound to beyound the width
            assume_counter_upper_bound: assume property(upper_bound(out, value));
        end
    endgenerate

       
endmodule
