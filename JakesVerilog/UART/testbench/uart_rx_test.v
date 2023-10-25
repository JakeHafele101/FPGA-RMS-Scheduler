`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/21/2022 03:43:56 PM
// Design Name: 
// Module Name: uart_rx_test
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


module uart_rx_test(

    );
    
    parameter T = 2;
    
    parameter DBIT     = 8,  //bits of data in word
              SB_TICK  = 16, //ticks for stop bit. 16 = 1 bit, 24 for 1.5 bits, 32 for 2 bits
              DVSR     = 1,  //counter for baud rate of 2 (T/BAUD)
              DVSR_BIT = 4,  //number of bits for DVSR counter for baud rate tick generator
              FIFO_W   = 2;  //number of address bits for words in FIFO buffer
              
    
    reg clk, reset;
    reg rx;
    reg rd_uart;
    
    wire tick, rx_done_tick;
    wire [7:0] rx_data_out;
    wire rx_empty, rx_full;
    wire [7:0] rd_data;
    
    
    baud_rate_generator #(.M(DVSR), .N(DVSR_BIT))baud_gen(.i_clk(clk), .i_reset(reset), .o_count(), .o_baud_tick(tick));
    
    uart_rx #(.DBIT(DBIT), .SB_TICK(SB_TICK)) rx_unit(.i_clk(clk), .i_reset(reset), .i_rx(rx), .i_s_tick(tick), 
                                                      .o_rx_done_tick(rx_done_tick), .o_data(rx_data_out));
    
    FIFO #(.B(DBIT), .W(FIFO_W)) fifo_rx(.i_clk(clk), .i_reset(reset), .i_wr(rx_done_tick), .i_rd(rd_uart), .i_wr_data(rx_data_out), 
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
        rx = 1'b1;
        rd_uart = 1'b0;
        @(negedge clk); //rx_empty
        
        receive(8'd5); //5
        repeat(16) @(negedge tick);
        read_FIFO(); //5
        
        //receieve five words. should only take 4 in FIFO buffer
        receive(8'd0); 
        receive(8'd20);
        receive(8'd170); //10101010
        receive(8'd255); //full after 40
        receive(8'd50); //does not add, full
        
        read_FIFO(); //10
        read_FIFO(); //20
        read_FIFO(); //30
        read_FIFO(); //40, empty after read
        read_FIFO(); //empty
        
    end
    
    //loads receive data word one bit at a time
    task receive(input [DBIT-1:0] data_in);
        integer i;
        begin
            rx = 1'b1; //idle
            repeat(16) @(negedge tick);
            rx = 1'b0; //start bit
            repeat(16) @(negedge tick);
            
            for(i = 0; i < DBIT; i = i + 1) //load data bits
                begin
                    rx = data_in[i];
                    repeat(16) @(negedge tick);
                end
                
            rx = 1'b1; //stop bit
            repeat(16) @(negedge tick);
        end
    endtask
    
    task read_FIFO();
        begin
            repeat(1) @(negedge clk);
            rd_uart = 1'b1;
            repeat(1) @(negedge clk);
            rd_uart = 1'b0;
            repeat(20) @(negedge clk);
        end
    endtask
    
endmodule
