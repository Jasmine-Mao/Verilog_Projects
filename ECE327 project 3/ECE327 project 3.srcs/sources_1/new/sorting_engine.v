`timescale 1ns / 1ps
// created and tested in vivado

module sorting_engine
    #(
        parameter ARRAY_LENGTH = 10,
        parameter DATA_WIDTH = 8)
    (
        input clk,
        input [ARRAY_LENGTH * DATA_WIDTH - 1:0] array_in,                                           // array_in is the size of the total array
        input valid_in,
        output reg [ARRAY_LENGTH * DATA_WIDTH - 1:0] array_out,                                     // array_out is the size of the total array
        output reg valid_out);
         
        reg [DATA_WIDTH - 1:0] sorting_array [ARRAY_LENGTH - 1:0];                                  // defines an array of (ARRAY_LENGTH - 1) elements of size (DATA_WIDTH - 1)
        integer i, j;                                                                               // integers for running through the for loops
        reg [$clog2(ARRAY_LENGTH) - 1 : 0] iter_counter;                                            // we use a counter to know hopw many iterations we need to go through, sized appropriately
        reg [DATA_WIDTH-1:0] temp;
        // need to create an array to perform sorting manipulations

        initial begin
            valid_out = 0;
            iter_counter = 0;
        end
        
        always@(posedge valid_in) begin                                                             // go through the array creation every time we have new input to the sorting engine
            for(i = 0; i < ARRAY_LENGTH; i = i + 1) begin
                sorting_array[ARRAY_LENGTH - i - 1] = array_in[i * DATA_WIDTH +: DATA_WIDTH];       // assign array values using the indexed part-select
                                                                                                    // ex. sorting_array[0] == array_in[7:0] assuming default DATA_WIDTH
            end
            iter_counter <= 0;
        end
        
        // need an always block that runs the sorting iterations
        always@(posedge clk) begin
            if(valid_in) begin                                                                      // sorting engine is ready to start
                if(iter_counter < ARRAY_LENGTH/2) begin                                             // if there are still iterations to complete
                    $display("counter = %d", iter_counter);
                    for(j = 0; j < (ARRAY_LENGTH - 1)/2 + ((ARRAY_LENGTH - 1) % 2); j = j + 1) begin  // even compare
                        if(sorting_array[j * 2] > sorting_array[j * 2 + 1]) begin                   // in the compare, if the first element is > second, swap
                            temp = sorting_array[2*j];
                            sorting_array[2*j] = sorting_array[2*j+1];
                            sorting_array[2*j+1] = temp;
                        end
                    end
                    for(j = 0; j < (ARRAY_LENGTH - 1)/2; j = j + 1) begin                           // odd compare
                        if(sorting_array[j * 2 + 1] > sorting_array[j * 2 + 2]) begin               // in the compare, if the first element is > second, swap
                            temp = sorting_array[2*j+1];
                            sorting_array[2*j+1] = sorting_array[2*j+2];
                            sorting_array[2*j+2] = temp;
                        end
                    end
                    iter_counter <= iter_counter + 1;                                               // increment the iteration counter
                    for(j = 0; j <  ARRAY_LENGTH; j = j+1) begin
                        $display("sorting_array[%0d] = %0d", j, sorting_array[j]);
                    end
                end
                else begin                                                                          // this else condition is reached when we have gone through all the required iterations
                    for (i = 0; i < ARRAY_LENGTH; i = i + 1) begin
                        array_out[i * DATA_WIDTH +: DATA_WIDTH] = sorting_array[ARRAY_LENGTH - 1 - i];
                    end
                    valid_out <= 1;
                end
            end
            else begin                                                                              // if the valid_in has not been asserted, the sorting engine should not run, therefore no valid out data
                valid_out <= 0;
                iter_counter <= 0;
            end
        end
        
        
endmodule
