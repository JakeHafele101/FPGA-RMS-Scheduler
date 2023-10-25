`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/21/2022 02:56:45 PM
// Design Name: 
// Module Name: uart_test
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


module uart_test(

    );
    
    parameter T = 2;
    
    parameter DBIT = 8,      //bits of data in word
              SB_TICK = 16,  //ticks for stop bit. 16 = 1 bit, 24 for 1.5 bits, 32 for 2 bits
              DVSR = 1,     //counter for baud rate of 2 (T/BAUD)
              DVSR_BIT = 4,  //number of bits for DVSR counter for baud rate tick generator
              FIFO_W = 2;    //number of address bits in FIFO buffer (4 words)
              
    parameter TICK = T;
    
    reg clk, reset;
    reg rd_uart, rx;
    reg wr_uart;
    reg [7:0] wr_data;
    
    wire tx_full, tx;
    wire rx_empty;
    wire [7:0] rd_data;
    
    uart #(.DBIT(DBIT), .SB_TICK(SB_TICK), .DVSR(DVSR), .DVSR_BIT(DVSR_BIT), .FIFO_W(FIFO_W))
         uart(.i_clk(clk), .i_reset(reset), .i_rd_uart(rd_uart), .i_wr_uart(wr_uart), .i_rx(rx), 
              .i_wr_data(wr_data), .o_tx_full(tx_full), .o_rx_empty(rx_empty), .o_tx(tx), 
              .o_rd_data(rd_data));
    
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
        rd_uart = 1'b0;
        wr_uart = 1'b0;
        rx = 1'b1;
        wr_data = 8'd0;
        @(negedge clk); //rx_empty
        
        receive(8'd5); //5
        read_FIFO(); //5
        
        //receieve five words. should only take 4 in FIFO buffer
        receive(8'd0);   //0000 0000
        receive(8'd20);  //
        receive(8'd170); //1010 1010
        receive(8'd255); //
        receive(8'd50);  //does not add, full
        
        //read buffered received words from FIFO RX
        read_FIFO(); //10
        read_FIFO(); //20
        read_FIFO(); //30
        read_FIFO(); //40, empty after read
        read_FIFO(); //empty
        
        //send 5 words through FIFO TX to buffer for transmit uart, only 4 send
        transmit_FIFO('d10); //0000 1010
        transmit_FIFO('d20); //0001 0100
        transmit_FIFO('d30); //0001 1110 
        transmit_FIFO('d40); //0010 1000
        transmit_FIFO('d50); //full by now, does not enter into buffer since 4 words already in
        repeat(TICK * 16) @(negedge clk);
        
    end
    
    //loads receive data word one bit at a time
    task receive(input [DBIT-1:0] data_in);
        integer i;
        begin
            rx = 1'b1; //idle
            repeat(TICK * 16) @(negedge clk);
            rx = 1'b0; //start bit
            repeat(TICK * 16) @(negedge clk);
            
            for(i = 0; i < DBIT; i = i + 1) //load data bits
                begin
                    rx = data_in[i];
                    repeat(TICK * 16) @(negedge clk);
                end
                
            rx = 1'b1; //stop bit
            repeat(TICK * 16) @(negedge clk);
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
