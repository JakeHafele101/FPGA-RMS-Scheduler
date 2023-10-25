`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/13/2022 07:13:40 PM
// Design Name: 
// Module Name: rising_edge_detector_mealy
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


module rising_edge_detector_mealy(
    input clk, reset,
    input level,
    output reg tick
    );
    
    //assigns state names to bit values for case statement
    localparam zero = 1'b0, 
                one = 1'b1;
                     
    reg [1:0] state_reg, state_next;
                 
    //D FF 
    always @(posedge clk, posedge reset)
        if(reset)
            state_reg = zero;
        else
            state_reg = state_next;
            
    //Next state logic and output logic
    always @*
        begin
            tick = 1'b0;  //default off since rising/falling edge will happen less often
            state_next = state_reg;
            case(state_reg)
                zero: 
                    if(level)
                        begin
                            tick = 1'b1;
                            state_next = one;
                        end
                one: 
                    if(~level)
                        state_next = zero;
            endcase
        end
        
endmodule