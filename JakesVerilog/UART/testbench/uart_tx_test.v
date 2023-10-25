`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/22/2022 12:28:10 PM
// Design Name: 
// Module Name: uart_tx_test
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


module uart_tx_test(

    );
    
    parameter T = 2;
    
    parameter DBIT     = 8,  //bits of data in word
              SB_TICK  = 16, //ticks for stop bit. 16 = 1 bit, 24 for 1.5 bits, 32 for 2 bits
              DVSR     = 1,  //counter for baud rate of 2 (T/BAUD)
              DVSR_BIT = 4,  //number of bits for DVSR counter for baud rate tick generator
              FIFO_W   = 2;  //number of address bits for words in FIFO buffer
              
    
    reg clk, reset;
    reg wr_uart;
    reg [DBIT-1:0] wr_data;
    
    wire [DBIT-1:0] tx_fifo_out;
    wire tx_empty, tx_full;
    
    wire tx;
    wire tick, tx_done_tick;
    
    baud_rate_generator #(.M(DVSR), .N(DVSR_BIT))baud_gen(.i_clk(clk), .i_reset(reset), .o_count(), .o_baud_tick(tick));
    
    FIFO #(.B(DBIT), .W(FIFO_W)) fifo_tx(.i_clk(clk), .i_reset(reset), .i_wr(wr_uart), .i_rd(tx_done_tick), .i_wr_data(wr_data), 
                                         .o_empty(tx_empty), .o_full(tx_full), .o_rd_data(tx_fifo_out));
                                         
    uart_tx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) tx_unit(.i_clk(clk), .i_reset(reset), .i_tx_start(~tx_empty), .i_s_tick(tick), 
                                                      .i_data(tx_fifo_out), .o_tx_done_tick(tx_done_tick), .o_tx(tx));

    
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
        wr_uart = 1'b0;
        wr_data = 'd0;
        @(negedge clk); //rx_empty
        
        transmit_FIFO('d10); //0000 1010
        @(negedge tx_done_tick);
        
        transmit_FIFO('d20); //0001 0100
        @(negedge tx_done_tick);

        transmit_FIFO('d30); //0001 1110 
        @(negedge tx_done_tick);
        
        transmit_FIFO('d40); //0010 1000
        @(negedge tx_done_tick);
        
        transmit_FIFO('d50); //full by now, does not enter into buffer since 4 words already in
        @(negedge tx_done_tick);
        
        @(posedge tx_empty);
        $stop;
    end
    
    //loads receive data word one bit at a time
    task transmit_FIFO(input [DBIT-1:0] data_in);
        begin
            repeat(1) @(negedge clk);
            wr_data = data_in;
            repeat(1) @(negedge clk);
            wr_uart = 1'b1;
            repeat(1) @(negedge clk);
            wr_uart = 1'b0;
            repeat(1) @(negedge clk);
        end
    endtask
    
endmodule
