`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 01/13/2023 09:55:50 PM
// Design Name:
// Module Name: enhanced_stopwatch_ps2_synth
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module enhanced_stopwatch_ps2_synth(input CLK100MHZ,
                                    input btnC,
                                    input PS2Data,
                                    input PS2Clk,
                                    output [6:0] seg,
                                    output dp,
                                    output [3:0] an,
                                    output [15:0] LED,
                                    output [7:0] JA);
    
    wire s_kb_buf_empty; wire [8:0] s_key_code; wire [7:0] s_ascii_code; wire s_time_out; wire s_go, s_clr, s_up; wire [3:0] s_d3, s_d2, s_d1, s_d0; assign JA[0] = PS2Data; assign JA[1] = PS2Clk; assign JA[2] = s_ascii_code; assign JA[3] = s_time_out; kb_code_shift kb_code_shift(.i_clk(CLK100MHZ), .i_reset(btnC), .i_ps2d(PS2Data), .i_ps2c(PS2Clk), .i_rd_key_code(~s_kb_buf_empty), .o_key_code(s_key_code), .o_time_out(s_time_out), .o_kb_buf_empty(s_kb_buf_empty));
    
    //converts PS2 keys to ASCII
    key_to_ascii_shift key_to_ascii_shift(.i_key_code(s_key_code), .o_ascii_code(s_ascii_code));
    
    //receive interface to handle ascii inputs from PS2 keyboard
    enhanced_stopwatch_receive_interface recieve_ascii(.i_clk(CLK100MHZ), .i_reset(btnC), .i_ascii(s_ascii_code), .i_rd_ascii(~s_kb_buf_empty), .o_go(s_go),
    .o_clr(s_clr), .o_up(s_up));
    
    //stopwatch unit
    enhanced_stopwatch enhanced_stopwatch(.clk(CLK100MHZ), .go(s_go), .clr(s_clr), .up(s_up), .d3(s_d3), .d2(s_d2), .d1(s_d1), .d0(s_d0));
    
    //seven seg mux display
    seven_seg_mux seven_seg_mux(.clk(CLK100MHZ), .reset(btnC), .duty_cycle(4'b1000), .hex3(s_d3), .hex2(s_d2), .hex1(s_d1), .hex0(s_d0), .dp(4'b1010), .an_en(4'b1111), .seg_out({dp, seg}), .an_out(an));
    
endmodule
