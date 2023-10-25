`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/03/2023 12:30:38 AM
// Design Name: 
// Module Name: stopwatch_uart_test
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


module stopwatch_uart_test(

    );
    
    parameter T = 2;
    
    parameter DVSR     = 0,  //ms count every clock tick
              DBIT     = 8,  //bits of data in word
              FIFO_W   = 8;  //number of address bits for words in FIFO buffer
              
    
    reg clk, reset;
    reg rx_fifo_wr;
    reg [7:0] i_ascii;
    
    wire go, clr, up, tx_start_tick;
    wire [3:0] d3, d2, d1, d0;
    
    wire [7:0] tx_ascii;
    wire tx_fifo_wr;
    
    wire rx_empty, rx_full;
    wire tx_empty, tx_full;
    wire [7:0] rx_ascii, o_ascii;
    
    
    FIFO_full #(.B(DBIT), .W(FIFO_W)) fifo_full_rx(.i_clk(clk), .i_reset(reset), .i_wr(rx_fifo_wr), .i_rd(~rx_empty), .i_wr_data(i_ascii), 
                                                   .o_empty(rx_empty), .o_full(rx_full), .o_rd_data(rx_ascii));
                                                
    enhanced_stopwatch_receive_interface recieve_ascii(.i_clk(clk), .i_reset(reset), .i_ascii(rx_ascii), .i_rd_ascii(~rx_empty), .o_go(go), 
                                                       .o_clr(clr), .o_up(up), .o_tx_start_tick(tx_start_tick));
                                                       
    enhanced_stopwatch #(.DVSR(DVSR))stopwatch(.clk(clk), .go(go), .clr(clr), .up(up), .d3(d3), .d2(d2), .d1(d1), .d0(d0));
    
    enhanced_stopwatch_transmit_interface transmit_ascii(.i_clk(clk), .i_reset(reset), .i_start(tx_start_tick), .i_d3(d3), .i_d2(d2), 
                                                         .i_d1(d1), .i_d0(d0), .o_ascii(tx_ascii), .o_fifo_wr(tx_fifo_wr));
                                                         
    FIFO_full #(.B(DBIT), .W(FIFO_W)) fifo_full_tx(.i_clk(clk), .i_reset(reset), .i_wr(tx_fifo_wr), .i_rd(~tx_empty), .i_wr_data(tx_ascii), 
                                                   .o_empty(tx_empty), .o_full(tx_full), .o_rd_data(o_ascii));

always begin
        clk = 1'b1;
        #(T/2);
        clk = 1'b0;
        #(T/2);
    end
    
    initial begin
        reset = 1'b1;
        #(T/2);
        reset = 1'b0;
    end
    
    initial begin
        rx_fifo_wr = 1'b0;
        i_ascii = 8'h00;
        @(negedge clk); //FIFO empty
                
        //count up for a while, pause, then transmit time
        ascii_rx(8'h47); //"G", set go to 1
        repeat(100 * T) @(negedge clk);
        ascii_rx(8'h50); //"P", set go to 0
        ascii_rx(8'h52); //"R", sends time to tx
        repeat(20 * T) @(negedge clk);
        
        ascii_rx(8'h55); //"U", inverts up to count DOWN
        ascii_rx(8'h47); //"G", set go to 1
        repeat(10 * T) @(negedge clk);
        ascii_rx(8'h52); //"R", sends time to tx
        repeat(10) @(negedge clk);
        
        $stop;
    end
    
    task ascii_rx(input [7:0] i_data);
        begin
            i_ascii = i_data;
            repeat(1) @(negedge clk);
            rx_fifo_wr = 1'b1;
            repeat(1) @(negedge clk);
            rx_fifo_wr = 1'b0;
            repeat(1) @(negedge clk);
        end
    endtask
    
endmodule
