`timescale 1ns / 1ps
// written, simulated, and synthesized in Vivado

// the memory tester design is of a state machine that iterates through the 3 stages of each test - writing, reading, and verifying.
// the state machine logic is split into 3 main components. a reset stage, 3 states for test 1, and 3 states for test 2.
// the logic for test 1 and test 2 are the same with the exception of the value being written/read is 0x00 for test 1 and 0xff for test 2

module mst(
    input clock,
    input reset,
    input enable,
    input [7:0] rdd,     
    output reg [7:0] rda,
    output reg [7:0] wrd,
    output reg [7:0] wra,
    output reg we,
    output [8:0] t1attempts,
    output [8:0] t1fails,
    output [8:0] t2attempts,
    output [8:0] t2fails,
    output done
    );
    reg [7:0] test_address = 0;
    reg [8:0] t1_attempt_counter, 
              t1_fail_counter, 
              t2_attempt_counter, 
              t2_fail_counter;    
          
    reg done_out = 1'b0; 
    reg [5:0] state;
    parameter rst  = 6'b000000,                     // FSM parameters, one hot encoded
              t1_w = 6'b000001,                     // t1 write, read, and verify
              t1_r = 6'b000010,
              t1_v = 6'b000100,
              t2_w = 6'b001000,                     // t2 write, read, and verift
              t2_r = 6'b010000,
              t2_v = 6'b100000;
    initial begin
        done_out <= 1'b0;
        we <= 1'b0;
        rda <= {8{1'b0}};
        wrd <= {8{1'b0}};
        wra <= {8{1'b0}};
        t1_attempt_counter <= {9{1'b0}};
        t1_fail_counter <= {9{1'b0}};
        t2_attempt_counter <= {9{1'b0}};
        t2_fail_counter <= {9{1'b0}};
    end
    
    always@(negedge clock) begin
        if(reset) begin
            state <= rst;
        end
        else begin
            case(state)
                rst: begin                                                                  // reset state
                    test_address <= {8{1'b0}};                                              // set the test address and attempt/fail numbers all to 0 in preperation for a fresh test run
                    t1_attempt_counter <= {9{1'b0}};
                    t1_fail_counter <= {9{1'b0}};
                    t2_attempt_counter <= {9{1'b0}};
                    t2_fail_counter <= {9{1'b0}};
                    if(!done_out)                                                           // this checks to see if the entire test is complete. if it has not been asserted complete,
                        state <= t1_w;                                                      // it continues to perform the first write of test 1
                end
                t1_w: begin                                                                 // write state. assert the write enable, increment the attempt counter, and pass the desired
                    we = 1'b1;                                                              // address and data to the memory module for writing purposes
                    t1_attempt_counter = t1_attempt_counter + 1;
                    wra <= test_address;
                    wrd <= 8'h00;
                    state <= t1_r;
                end
                t1_r: begin                                                                 // read state. deassert the write enable and pass the test address to the memory module for
                    we = 1'b0;                                                              // reading purposes
                    rda = test_address;
                    state <= t1_v;
                end
                t1_v: begin                                                                 // verification state. check to ensure the read value is in fact 0x00. if that is not the
                    if(rdd != 8'h00) begin                                                  // case, increment the fail counter
                        t1_fail_counter = t1_fail_counter + 1;
                    end
                    if(test_address == 8'hff) begin                                         // this if statement checks to see if we have iterated over all the memory. if our test address
                        //$display("iterated through all addresses");                       // has reached 0xff, we have completed the test. reset the test address for test 2 and move
                        test_address = 8'h00;                                               // on to test 2
                        state <= t2_w;
                    end
                    else begin                                                              // we reach here if we have not completed iterating through memory. in this case, increment
                        test_address = test_address + 1;                                    // the test address and return to test 1's write stage
                        state <= t1_w;
                    end
                end
                t2_w: begin                                                                 // same logic as test 1
                    we = 1'b1;
                    t2_attempt_counter = t2_attempt_counter + 1;
                    wra <= test_address;
                    wrd <= 8'hFF;
                    state <= t2_r;
                end 
                t2_r: begin                                                                 // same logic as test 1
                    we = 1'b0;
                    rda = test_address;
                    state <= t2_v;
                end
                t2_v: begin
                    if(rdd != 8'hFF) begin                                                  // as in test 1, verify that we have read the correct value
                        t2_fail_counter = t2_fail_counter + 1;
                    end
                    if(test_address == 8'hff) begin                                         // if we have completed iterating through all of memory, assert the done signal to
                        done_out <= 1'b1;                                                   // indicate that all tests have been complete. move to the reset state to reset everything back to 
                        state <= rst;                                                       // 0
                    end
                    else begin                                                              // otherwise increment the address asbefore
                        test_address = test_address + 1;
                        state <= t2_w;
                    end
                end
                default:
                    state <= rst;
            endcase 
        end        
    end
    assign t1attempts = t1_attempt_counter;                                                 // assign out the attempt counters and the done signal
    assign t1fails = t1_fail_counter;
    assign t2attempts = t2_attempt_counter;
    assign t2fails = t2_fail_counter;
    assign done = done_out;
endmodule
