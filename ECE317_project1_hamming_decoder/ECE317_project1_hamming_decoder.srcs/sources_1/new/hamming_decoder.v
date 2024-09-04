`timescale 1ns / 1ps

module checkbit_calculator(
    input [7:0] data,
    output [3:0] calc_cb
    );
    assign calc_cb[0] = data[0] ^ data[1] ^ data[3] ^ data[4] ^ data[6];
    assign calc_cb[1] = data[0] ^ data[2] ^ data[3] ^ data[5] ^ data[6];
    assign calc_cb[2] = data[1] ^ data[2] ^ data[3] ^ data[7];
    assign calc_cb[3] = data[4] ^ data[5] ^ data[6] ^ data[7];    
endmodule

module syndrome_calculator(
    input [3:0] cb_calc,
    input [3:0] cb,
    output [3:0] syndrome
    );
    assign syndrome = cb_calc ^ cb;
endmodule

module bit_fix_calculator(
    input [3:0] syndrome,
    input [7:0] data,
    output reg [7:0] fixed_data
    );
    always@(syndrome)begin
        case(syndrome)
            4'd3:
                fixed_data <= data ^ 8'b00000001;
            4'd5:
                fixed_data <= data ^ 8'b00000010;
            4'd6:
                fixed_data <= data ^ 8'b00000100;
            4'd7:
                fixed_data <= data ^ 8'b00001000;
            4'd9:
                fixed_data <= data ^ 8'b00010000;
            4'd10:
                fixed_data <= data ^ 8'b00100000;
            4'd11:
                fixed_data <= data ^ 8'b01000000;
            4'd12:
                fixed_data <= data ^ 8'b10000000;
            default:
                fixed_data <= data;
        endcase
    end
endmodule

module hamming_decoder(
    input [11:0] code,
    output [7:0] data,
    output [3:0] syndrome
    );
    wire[7:0] databits;
    wire[3:0] checkbits, calc_cb_wire, syndrome_wire;
    
    assign databits = {code[11:8], code[6:4], code[2]};
    assign checkbits = {code[7], code[3], code[1:0]};
    
    checkbit_calculator cb_calc(databits, calc_cb_wire);
    syndrome_calculator s_calc(calc_cb_wire, checkbits, syndrome_wire);
    bit_fix_calculator bf_calc(syndrome_wire, databits, data);
    
    assign syndrome = syndrome_wire;
endmodule

module hamming_decoderTB;
    reg[11:0] tb_code;
    wire[7:0] tb_data;
    wire[3:0] tb_syndrome;
    
    hamming_decoder decoder_instance(tb_code, tb_data, tb_syndrome);
    
    initial
    begin
        $monitor($time, "ns tb_code = 0x%h, tb_data = 0x%h, tb_syndrome = 0x%h", tb_code, tb_data, tb_syndrome);
        tb_code = 0;
        
        #10 tb_code = 12'h34f;      // syndrome = 0; no errors
        #10 tb_code = 12'h34e;      // syndrome = 1; error in code 0
        #10 tb_code = 12'h34d;      // syndrome = 2; error in code 1
        #10 tb_code = 12'h34b;      // syndrome = 3; error in code 2
        #10 tb_code = 12'h347;      // syndrome = 4; error in code 3
        #10 tb_code = 12'h35f;      // syndrome = 5; error in code 4
        #10 tb_code = 12'h36f;      // syndrome = 6; error in code 5
        #10 tb_code = 12'h30f;      // syndrome = 7; error in code 6
        #10 tb_code = 12'h3cf;      // syndrome = 8; error in code 7
        #10 tb_code = 12'h24f;      // syndrome = 9; error in code 8
        #10 tb_code = 12'h14f;      // syndrome = 10; error in code 9
        #10 tb_code = 12'h74f;      // syndrome = 11; error in code 10
        #10 tb_code = 12'hb4f;      // syndrome = 12; error in code 11
        #10 $finish;
    end 
endmodule
