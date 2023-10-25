`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/15/2022 02:16:55 PM
// Design Name: 
// Module Name: debounce_FSMD
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


module debounce_FSMD(
    input clk, reset,
    input sw,
    output reg db_level, db_tick
    );
    
    //state declarations
    localparam [1:0] zero = 2'b00,
                     wait1 = 2'b01,
                     one = 2'b10,
                     wait0 = 2'b11;
   //counter integer for wait tick (2^N * 10ns = 20ms)
   parameter N = 21;
   
   //signal declaration
   reg [1:0] state_reg, state_next;
   reg [N-1:0] q_reg;    //count register in data path
   wire [N-1:0] q_next;
   wire q_zero;          //internal status signal to control path
   reg q_load, q_dec;    //control signals to data path
   
   //FSMD state and data registers
   always @(posedge clk, posedge reset)
    if(reset)
        begin
            state_reg <= zero;
            q_reg <= 0;
        end
    else
        begin
            state_reg <= state_next;
            q_reg <= q_next;
        end
    
    //FSMD data path (counter) next-state logic
    assign q_next = (q_load) ? {N{1'b1}} :       //load 1...1 
                    (q_dec)  ? q_reg - 1 :       //decrement q by 1
                               q_reg;
    
    assign q_zero = (q_next == 0);
    
    //FSMD control path next-state logic
    always @*
    begin
        state_next = state_reg;
        q_load = 1'b0;
        q_dec = 1'b0;
        db_tick = 1'b0;
        
        case(state_reg)
            zero:
                begin
                    db_level = 1'b0;
                    if(sw)
                        begin
                            state_next = wait1;
                            q_load = 1'b1;       //loads coutner to 1...1
                        end
                end
            wait1:
                begin
                    db_level = 1'b1;
                    q_dec = 1'b1;
                    if(q_zero && sw)
                        begin
                            state_next = one;
                            db_tick = 1'b1;
                        end
                    else if(q_zero && ~sw)
                        state_next = zero;
                
                end
            one:
                begin
                    db_level = 1'b1;
                    if(~sw)
                        begin
                            state_next = wait0;
                            q_load = 1'b1;
                        end
                end
            wait0:
                begin
                    db_level = 1'b0;
                    q_dec = 1'b1;
                    if(q_zero && ~sw)
                        state_next = zero;
                    else if(q_zero && sw)
                        state_next = one;
                end
            default: state_next = zero;
        endcase
    end
    
endmodule
