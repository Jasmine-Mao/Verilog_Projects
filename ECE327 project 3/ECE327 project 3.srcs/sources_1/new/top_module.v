`timescale 1ns / 1ps

module top_module;

    parameter ARRAY_LENGTH = 10;
    parameter DATA_WIDTH = 8;

    // Signals created for 3 different array lengths and data widths
    reg clk;
    reg [ARRAY_LENGTH * DATA_WIDTH - 1:0] array_in_10_8;
    reg valid_in_10_8;
    wire [ARRAY_LENGTH * DATA_WIDTH - 1:0] array_out_10_8;
    wire valid_out_10_8;
    
    reg [15 * 3 - 1:0] array_in_15_3;
    reg valid_in_15_3;
    wire [15 * 3 - 1:0] array_out_15_3;
    wire valid_out_15_3;
    
    reg [30 * 10 - 1:0] array_in_30_10;
    reg valid_in_30_10;
    wire [30 * 10 - 1:0] array_out_30_10;
    wire valid_out_30_10;

    sorting_engine #(
        .ARRAY_LENGTH(ARRAY_LENGTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut_10_8 (
        .clk(clk),
        .array_in(array_in_10_8),
        .valid_in(valid_in_10_8),
        .array_out(array_out_10_8),
        .valid_out(valid_out_10_8)
    );
    
    sorting_engine #(
        .ARRAY_LENGTH(15),
        .DATA_WIDTH(3)
    ) dut_15_3 (
        .clk(clk),
        .array_in(array_in_15_3),
        .valid_in(valid_in_15_3),
        .array_out(array_out_15_3),
        .valid_out(valid_out_15_3)
    );
    
    sorting_engine #(
        .ARRAY_LENGTH(30),
        .DATA_WIDTH(10)
    ) dut_30_10 (
        .clk(clk),
        .array_in(array_in_30_10),
        .valid_in(valid_in_30_10),
        .array_out(array_out_30_10),
        .valid_out(valid_out_30_10)
    );

    always #10 clk = ~clk;

    initial begin
        $monitor($time, " Array_in = %p, Valid_in = %0d, Valid_out = %0d, Array_out = %p", array_in_10_8, valid_in_10_8, valid_out_10_8, array_out_10_8);

        clk = 0;
        array_in_10_8 = 0;
        valid_in_10_8 = 0;
        
        array_in_15_3 = 0;
        valid_in_15_3 = 0;
        
        array_in_30_10 = 0;
        valid_in_30_10 = 0;

        #20 array_in_10_8 = {8'd5, 8'd2, 8'd7, 8'd1, 8'd9, 8'd3, 8'd6, 8'd4, 8'd0, 8'd8}; // Example input array
        #20 valid_in_10_8 = 1;
        wait(valid_out_10_8 == 1);
        
        #20 valid_in_10_8 = 0;
        array_in_10_8 = {8'd11, 8'd15, 8'd0, 8'd4, 8'd19, 8'd11, 8'd7, 8'd4, 8'd0, 8'd8};
        #20 valid_in_10_8 = 1;
        wait(valid_out_10_8 == 1);
        
        #20 valid_in_15_3 = 0;
        array_in_15_3 = {3'd1, 3'd5, 3'd3, 3'd0, 3'd7, 3'd2, 3'd6, 3'd4, 3'd1, 3'd3, 3'd7, 3'd2, 3'd0, 3'd6, 3'd5};
        #20 valid_in_15_3 = 1;
        wait(valid_out_15_3 == 1);
        
        #20 valid_in_30_10 = 0;
        array_in_30_10 = {10'd672,10'd318,10'd241,10'd459,10'd899,10'd871,10'd724,10'd8,10'd310,10'd491,10'd185,10'd1013,10'd133,10'd346,10'd777,10'd519,10'd963,10'd208,10'd641,10'd799,10'd684,10'd945,10'd602,10'd362,10'd485,10'd162,10'd526,10'd920,10'd47,10'd854};
        #20 valid_in_30_10 = 1;
        wait(valid_out_30_10 == 1);
        #10

        $finish;
    end

endmodule
