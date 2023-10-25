module seven_seg_decoder(
input [3:0] i_x,
output reg [6:0] o_seg
);	
	always@*
	begin
		case(i_x)
			4'b0000: o_seg = 'b0000001;//0
			4'b0001: o_seg = 'b1001111;//1
			4'b0010: o_seg = 'b0010010;//2
			4'b0011: o_seg = 'b0000110;//3
			4'b0100: o_seg = 'b1001100;//4
			4'b0101: o_seg = 'b0100100;//5
			4'b0110: o_seg = 'b0100000;//6
			4'b0111: o_seg = 'b0001111;//7
			4'b1000: o_seg = 'b0000000;//8
			4'b1001: o_seg = 'b0000100;//9
			4'b1010: o_seg = 'b0001000;//A
			4'b1011: o_seg = 'b1100000;//b
			4'b1100: o_seg = 'b0110001;//C
			4'b1101: o_seg = 'b1000010;//d
			4'b1110: o_seg = 'b0110000;//E
			4'b1111: o_seg = 'b0111000;//F
		endcase
	end
endmodule
			