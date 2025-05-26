module fv_counter
#(
    parameter WIDTH = 4
)
(
    input logic                                       clk,
    input logic                                       rst,
    input logic [WIDTH-1:0]                           out
);

    default clocking default_clk @ (posedge clk); endclocking

    // Yosys cannot work with this reset assert statement, while other tools can 
    // (jasper can only work with this)
    `ifndef YOSYS_SBY
    property reset_check;
       $past(rst)
    |-> 
        ##0 out == 0;
    endproperty
    `else
    property reset_check;
        ##0 rst
    |-> 
        ##1 out == 0;
    endproperty
    `endif
    assert_reset_check: assert property (reset_check);

    property count_check;
        disable iff (rst) 
        ##0 out
    |-> 
        ##1 out == $past(out,1) + 1;
    endproperty
    
    assert_count_check: assert property (count_check);

    property count_reaches(number);
        disable iff (rst)
        ##0 out == (number - 1)
    |-> 
        ##1 out == number;
    endproperty

    generate
        for (genvar i = 0; i < 4; i++) begin
            localparam int value = (1 << i);
            assert_count_reaches: assert property (count_reaches(value));
        end
    endgenerate

    generate
        for (genvar i = 4; i < 8; i++) begin: count_reach_gen_block
            localparam int value = (1 << i);
            assert_count_reaches: assert property (count_reaches(value));
        end
    endgenerate

    `ifdef DEFAULT_UPPERBOUND
    property count_check_failure;
        disable iff (rst) 
        ##0 out
    |-> 
        ##1 out == $past(out,1) + 2;
    endproperty
    
    assert_count_check_failure: assert property (count_check_failure);
    `endif

    generate
        for (genvar i = 0; i < 2; i++) begin
            cover_fv_counter_out: cover property(out==i);
        end
    endgenerate

    generate
        for (genvar i = 7; i < 9; i++) begin: count_covers_gen_block
            cover_fv_counter_out: cover property(out==i);
        end
    endgenerate

    // Attempt to get hold bounded
    // if we set WIDTH to 64 and time limit to 2s
    // best we get is hold no_pass in onespin
    // and proven (infinite bound) unreachable (witness) covered (precondition) in jasper
    // property count_reaches_big_number;
    //     disable iff (rst) 
    //     ##0 out == 1
    // |-> 
    //     ##[0:$] out == 1 << 32
    // endproperty
    
    // assert_count_reaches_big_number: assert property(count_reaches_big_number);
endmodule