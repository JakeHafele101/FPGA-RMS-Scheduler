`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/26/2022 10:33:08 PM
// Design Name: 
// Module Name: FIFO_full_test
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


module FIFO_full_test(

    );
    
    parameter T = 2;
    
    parameter DBIT     = 8,  //bits of data in word
              FIFO_W   = 2;  //number of address bits for words in FIFO buffer
              
    
    reg clk, reset;
    reg wr, rd;
    reg [7:0] wr_data;
    
    wire rx_empty, rx_full;
    wire [7:0] rd_data;
    
    FIFO_full #(.B(DBIT), .W(FIFO_W)) fifo_full(.i_clk(clk), .i_reset(reset), .i_wr(wr), .i_rd(rd), .i_wr_data(wr_data), 
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
        wr = 1'b0;
        rd = 1'b0;
        wr_data = 0;
        @(negedge clk); //FIFO empty
        
        //1 write, not empty now
        write_FIFO(8'd10);
        
        //1 read, empty after
        read_FIFO();
        
        //read when empty
        read_FIFO();
        
        //write to full
        write_FIFO(8'd20); //read 20
        write_FIFO(8'd30); //read 20
        write_FIFO(8'd40); //read 20
        write_FIFO(8'd50); //read 20
        
        //verify overrun occurs and first data overwritten, still full, read increments
        write_FIFO(8'd60); //read 30
        write_FIFO(8'd70); //read 40
        write_FIFO(8'd80); //read 50
        write_FIFO(8'd90); //read 60
        read_FIFO(); //read 70, not full now
        read_FIFO(); //read 80
        read_FIFO(); //read 90
        read_FIFO(); //empty now
        read_FIFO(); //empty
        
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
