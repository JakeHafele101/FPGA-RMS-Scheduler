`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/01/2023 04:29:00 PM
// Design Name: 
// Module Name: uart_tx_full_test
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


module uart_tx_full_test(

    );
    
    parameter T = 2;
    
    parameter DVSR     = 1,  //counter for baud rate of 2 (T/BAUD)
              DVSR_BIT = 4,  //number of bits for DVSR counter for baud rate tick generator
              FIFO_W   = 2;  //number of address bits for words in FIFO buffer
              
    
    reg clk, reset;
    reg wr_uart;
    reg [7:0] wr_data;
    reg [1:0] data_num, stop_num, par;
    
    wire [7:0] tx_fifo_out;
    wire tx_empty, tx_full;
    
    wire tx;
    wire tick, tx_done_tick;
            
    baud_rate_generator #(.M(DVSR), .N(DVSR_BIT))baud_gen(.i_clk(clk), .i_reset(reset), .o_count(), .o_baud_tick(tick));
    
    FIFO_full #(.W(FIFO_W)) fifo_tx(.i_clk(clk), .i_reset(reset), .i_wr(wr_uart), .i_rd(tx_done_tick), .i_wr_data(wr_data), 
                                    .o_empty(tx_empty), .o_full(tx_full), .o_rd_data(tx_fifo_out));
                                         
    
    uart_tx_full tx_unit(.i_clk(clk), .i_reset(reset), .i_tx_start(~tx_empty), .i_baud_tick(tick), .i_data_num(data_num), 
                         .i_stop_num(stop_num), .i_par(par), .i_data(tx_fifo_out), .o_tx_done_tick(tx_done_tick), .o_tx(tx));
    
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
        wr_data = 8'd0;
        data_num = 2'b10; //8 data bits received
        stop_num = 2'b00; //1 stop bit received
        par = 2'b00;      //no parity bit received
        @(negedge clk);   
        
//        data_num_test();
//        stop_num_test();
//        parity_test();
        adhoc_test();
        
        $stop;
    end
    
    //loads receive data word one bit at a time
    task transmit_FIFO(input [7:0] data_in);
        begin
            wr_data = data_in;
            repeat(1) @(negedge clk);
            wr_uart = 1'b1;
            repeat(1) @(negedge clk);
            wr_uart = 1'b0;
            repeat(1) @(negedge clk);
        end
    endtask
    
    task data_num_test();
        begin
            data_num = 2'b11; //8 data bits received by default
            repeat(2) @(negedge clk);
            transmit_FIFO(8'b10000001);
            @(negedge tx_done_tick);
            
            data_num = 2'b10; //8 data bits received
            repeat(2) @(negedge clk);
            transmit_FIFO(8'b10000001);
            @(negedge tx_done_tick);
           
            data_num = 2'b01; //7 data bits received
            repeat(2) @(negedge clk);
            transmit_FIFO(8'b11000001);
            @(negedge tx_done_tick);
            
            data_num = 2'b00; //6 data bits received
            repeat(2) @(negedge clk);
            transmit_FIFO(8'b11100001);
            @(negedge tx_done_tick);
            
            data_num = 2'b10;
        end
    endtask
    
    task stop_num_test();
        begin
            stop_num = 2'b11; //2 stop bits received by default (32 ticks)
            repeat(2) @(negedge clk);
            transmit_FIFO(8'b00000000);
            @(negedge tx_done_tick);
            
            stop_num = 2'b10; //2 stop bits received (32 ticks)
            repeat(2) @(negedge clk);
            transmit_FIFO(8'b00000001);
            @(negedge tx_done_tick);
           
            stop_num = 2'b01; //1.5 stop bits received (24 ticks)
            repeat(2) @(negedge clk);
            transmit_FIFO(8'b00000010);
            @(negedge tx_done_tick);
            
            stop_num = 2'b00; //1 data bit received (16 ticks)
            repeat(2) @(negedge clk);
            transmit_FIFO(8'b00000011);
            @(negedge tx_done_tick);
            
        end
    endtask
    
    task parity_test();
        begin
            
            par = 2'b11; //no parity
            repeat(2) @(negedge clk);
            transmit_FIFO(8'b00000011); //no parity bit
            @(negedge tx_done_tick);
            
            transmit_FIFO(8'b00000001); //no parity bit
            @(negedge tx_done_tick);
            
            par = 2'b00; //no parity
            repeat(2) @(negedge clk);
            transmit_FIFO(8'b00000011); //no parity bit
            @(negedge tx_done_tick);
            
            transmit_FIFO(8'b00000001); //no parity bit
            @(negedge tx_done_tick);
           
            par = 2'b01; //even parity
            repeat(2) @(negedge clk);
            transmit_FIFO(8'b00000011); //parity bit 0
            @(negedge tx_done_tick);
            
            transmit_FIFO(8'b00000001); //parity bit 1
            @(negedge tx_done_tick);
            
            par = 2'b10; //odd parity
            repeat(2) @(negedge clk);
            transmit_FIFO(8'b00000011); //parity bit 1
            @(negedge tx_done_tick);
            
            transmit_FIFO(8'b00000001); //parity bit 0
            @(negedge tx_done_tick);
        end
    endtask
    
    task adhoc_test();
        begin
            // 8 data bits, no parity, 16 tick stop
            data_num = 2'b10; //8 data bits received
            stop_num = 2'b00; //1 stop bit received
            par = 2'b00;      //no parity bit received
            repeat(2) @(negedge clk);
            transmit_FIFO(8'b00000000);
            @(negedge tx_done_tick);
            
            //7 data bits, even parity, 24 tick stop
            data_num = 2'b01; //7 data bits received
            stop_num = 2'b01; //1.5 stop bit received
            par = 2'b01;      //even parity
            repeat(2) @(negedge clk);
            transmit_FIFO(8'b00000010);
            @(negedge tx_done_tick);
            
            //6 data bits, odd parity, 32 tick stop
            data_num = 2'b00; //6 data bits received
            stop_num = 2'b10; //2 stop bit received
            par = 2'b10;      //odd parity
            repeat(2) @(negedge clk);
            transmit_FIFO(8'b00000100);
            @(negedge tx_done_tick);
        end
    endtask
    
endmodule
