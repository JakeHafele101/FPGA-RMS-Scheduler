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


module stopwatch_receive_test(

    );
    
    parameter T = 2;
    
    parameter DBIT     = 8,  //bits of data in word
              FIFO_W   = 2;  //number of address bits for words in FIFO buffer
              
    
    reg clk, reset;
    reg wr, rd;
    reg [7:0] wr_data;
    
    wire rx_empty, rx_full;
    wire [7:0] rd_data;
    wire go, clr, up, tx_start_tick;
    
    FIFO_full #(.B(DBIT), .W(FIFO_W)) fifo_full(.i_clk(clk), .i_reset(reset), .i_wr(wr), .i_rd(~rx_empty), .i_wr_data(wr_data), 
                                                .o_empty(rx_empty), .o_full(rx_full), .o_rd_data(rd_data));
                                                
    enhanced_stopwatch_receive_interface recieve_ascii(.i_clk(clk), .i_reset(reset), .i_ascii(rd_data), .i_rd_ascii(~rx_empty), .o_go(go), 
                                                       .o_clr(clr), .o_up(up), .o_tx_start_tick(tx_start_tick));

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
        wr = 1'b0;
        rd = 1'b0;
        wr_data = 0;
        @(negedge clk); //FIFO empty
        
        //update go
        write_FIFO(8'h47); //"G", sets go to 1, clr to 0
        write_FIFO(8'h50); //"P", sets go to 0
        
        write_FIFO(8'h67); //"g", sets go to 1, clr to 0
        write_FIFO(8'h70); //"p", sets go to 0
        
        //update up
        write_FIFO(8'h55); //"U", inverts up
        write_FIFO(8'h55); //"U", inverts up
        
        write_FIFO(8'h75); //"u", inverts up
        write_FIFO(8'h75); //"u", inverts up
        
        //set tx tick 
        write_FIFO(8'h52); //"R", tx_tick set to 1 for one cycle
        write_FIFO(8'h72); //"r", tx_tick set to 1 for one cycle
        
        //clear command (sets go to 0, clr to 1, and up to 1)
        write_FIFO(8'h47); //"G", sets go to 1, clr to 0
        write_FIFO(8'h55); //"U", inverts up to 0
        write_FIFO(8'h43); //"C", go to 0, clr to 1, up to 1
        
        write_FIFO(8'h47); //"G", sets go to 1, clr to 0
        write_FIFO(8'h55); //"U", inverts up to 0
        write_FIFO(8'h63); //"c"
        
        $stop;
    end
    
    task write_FIFO(input [7:0] i_data);
        begin
            wr_data = i_data;
            repeat(1) @(negedge clk);
            wr = 1'b1;
            repeat(1) @(negedge clk);
            wr = 1'b0;
            repeat(1) @(negedge clk);
        end
    endtask
    
    task read_FIFO();
        begin
            repeat(1) @(negedge clk);
            rd = 1'b1;
            repeat(1) @(negedge clk);
            rd = 1'b0;
            repeat(1) @(negedge clk);
        end
    endtask
    
    
endmodule