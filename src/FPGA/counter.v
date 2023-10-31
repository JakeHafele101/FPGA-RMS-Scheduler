module counter (
    input i_clk,
    input i_rst,
    input i_en,
    output reg [31:0] o_Q
);

always @(posedge i_clk, posedge i_rst) begin
    if(i_rst)
        o_Q <= 0;
    else if(i_en)
        o_Q <= o_Q + 1;
end
    
endmodule