`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// written and tested with Vivado
//////////////////////////////////////////////////////////////////////////////////


module PD(
    input clk,
    input reset,
    input enable,
    input [3:0] din,
    output pattern1,
    output pattern2
);
    reg [7:0] current_state;
    reg output_pattern1;
    reg output_pattern2;
    
    parameter idle    = 8'b0000_0000,       // idle state
              state_1 = 8'b0000_0001,
              state_2 = 8'b0000_0010,    // when the input = 0
              state_3 = 8'b0000_0100,    // when the input = 5
              state_4 = 8'b0000_1000,    // when the input = 3
              state_5 = 8'b0001_0000,    // when the input = 1
              state_6 = 8'b0010_0000,    // when the input = 6
              state_7 = 8'b0100_0000,    // when the input = 1
              state_8 = 8'b1000_0000;    // when the input = 2
    
    always@(posedge clk or posedge reset) begin
    if(reset) begin
        current_state <= idle;
        output_pattern1 <= 0;
        output_pattern2 <= 0;
        //$display("t=%0t, Reset asserted. State: idle", $time);
    end
    else begin
            case(current_state)
                idle: begin
                    output_pattern1 <= 0;
                    output_pattern2 <= 0;
                    current_state <= state_1;
                    //$display("t=%0t, State: idle -> state_1", $time);
                end
                state_1: begin
                    if(enable) begin
                        case(din)
                            4'd0: begin
                                current_state <= state_2;
                                //$display("t=%0t, State: state_1 -> state_2, din: %b", $time, din);
                            end
                            default: begin
                                current_state <= state_1;
                                //$display("t=%0t, State: state_1, din: %b", $time, din);
                            end
                        endcase
                    end
                end
                state_2: begin
                    if(enable) begin
                        case(din)
                            4'd5: begin
                                current_state <= state_3;
                                //$display("t=%0t, State: state_2 -> state_3, din: %b", $time, din);
                            end
                            4'd6: begin
                                current_state <= state_6;
                                //$display("t=%0t, State: state_2 -> state_6, din: %b", $time, din);
                            end
                            4'd0: begin
                                current_state <= state_2;
                            end
                            default: begin
                                current_state <= state_1;
                                //$display("t=%0t, State: state_2, din: %b", $time, din);
                            end
                        endcase
                    end
                end
                state_3: begin
                    if(enable) begin
                        case(din)
                            4'd3: begin
                                current_state <= state_4;
                                //$display("t=%0t, State: state_3 -> state_4, din: %b", $time, din);
                            end
                            4'd0: begin
                                current_state <= state_2;
                            end
                            default: begin
                                current_state <= state_1;
                                //$display("t=%0t, State: state_3, din: %b", $time, din);
                            end
                        endcase
                    end
                end
                state_4: begin
                    if(enable) begin
                        case(din)
                            4'd1: begin
                                output_pattern1 <= 1;
                                current_state <= state_5;
                                //$display("t=%0t, State: state_4 -> state_5, din: %b", $time, din);
                            end
                            4'd0: begin
                                current_state <= state_2;
                            end
                            default: begin
                                current_state <= state_1;
                                //$display("t=%0t, State: state_4, din: %b", $time, din);
                            end
                        endcase
                    end
                end    
                state_5: begin
                    current_state <= idle;
                    //$display("t=%0t, State: state_5 -> idle, pattern1 set", $time);
                end
                state_6: begin
                    if(enable) begin
                        case(din)
                            4'd1: begin
                                current_state <= state_7;
                                //$display("t=%0t, State: state_6 -> state_7, din: %b", $time, din);
                            end
                            4'd0: begin
                                current_state <= state_2;
                            end
                            default: begin
                                current_state <= state_1;
                                //$display("t=%0t, State: state_6, din: %b", $time, din);
                            end
                        endcase
                    end
                end
                state_7: begin
                    if(enable) begin
                        case(din)
                            4'd9: begin
                                output_pattern2 <= 1;
                                current_state <= state_8;
                                //$display("t=%0t, State: state_7 -> state_8, din: %b", $time, din);
                            end
                            4'd0: begin
                                current_state <= state_2;
                            end
                            default: begin
                                current_state <= idle;
                                //$display("t=%0t, State: state_7, din: %b", $time, din);
                            end
                        endcase
                    end
                end
                state_8: begin
                    current_state <= idle;
                    //$display("t=%0t, State: state_8 -> idle, pattern2 set", $time);
                end
                default: begin
                    current_state <= state_1;
                    //$display("t=%0t, State: default -> state_1", $time);
                end
            endcase
        end
    end


assign pattern1 = output_pattern1;
assign pattern2 = output_pattern2;
    
endmodule
