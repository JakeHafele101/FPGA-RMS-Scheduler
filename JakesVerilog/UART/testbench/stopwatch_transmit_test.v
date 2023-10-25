`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/01/2023 10:26:18 PM
// Design Name: 
// Module Name: stopwatch_transmit_test
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


module stopwatch_transmit_test(

    );
    
    parameter T = 2;
    
    parameter DBIT     = 8,  //bits of data in word
              FIFO_W   = 8;  //number of address bits for words in FIFO buffer
              
    
    reg clk, reset;
    reg start;
    reg [3:0] d3, d2, d1, d0;
    
    wire [7:0] ascii;
    wire fifo_wr;
    
    wire rx_empty, rx_full;
    wire [7:0] rd_data;
    
    enhanced_stopwatch_transmit_interface transmit_ascii(.i_clk(clk), .i_reset(reset), .i_start(start), .i_d3(d3), .i_d2(d2), 
                                                         .i_d1(d1), .i_d0(d0), .o_ascii(ascii), .o_fifo_wr(fifo_wr));
                                                         
    FIFO_full #(.B(DBIT), .W(FIFO_W)) fifo_full(.i_clk(clk), .i_reset(reset), .i_wr(fifo_wr), .i_rd(~rx_empty), .i_wr_data(ascii), 
                                                .o_empty(rx_empty), .o_full(rx_full), .o_rd_data(rd_data));

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
        start = 1'b0;
        d3 = 4'h0;
        d2 = 4'h0;
        d1 = 4'h0;
        d0 = 4'h0;
        @(negedge clk); //FIFO empty
        
        transmit_time(.i_d3(4'h4), .i_d2(4'h2), .i_d1(4'h7), .i_d0(4'h5)); //4.27.4
        @(posedge rx_empty);
        
        transmit_time(.i_d3(4'h0), .i_d2(4'h0), .i_d1(4'h0), .i_d0(4'h0)); //0.00.0, min
        @(posedge rx_empty);
        
        transmit_time(.i_d3(4'h9), .i_d2(4'h5), .i_d1(4'h9), .i_d0(4'h9)); //9.59.9, max
        @(posedge rx_empty);
        
        $stop;
    end
    
    task transmit_time(input [3:0] i_d3, i_d2, i_d1, i_d0);
        begin
            d3 = i_d3;
            d2 = i_d2;
            d1 = i_d1;
            d0 = i_d0;
            repeat(1) @(negedge clk);
            start = 1'b1;
            repeat(1) @(negedge clk);
            start = 1'b0;
            repeat(1) @(negedge clk);
        end
    endtask
    
endmodule
