module Quartus_synth (
	input i_clk, //50 MHz Clk
	input i_clk_button, //KEY0
	input i_rst, //KEY1
	input [1:0] i_clk_sel, //SW1, SW0
	input [2:0] i_out_sel, //SW4, SW3, SW2
	output [6:0] o_seg0,
	output [6:0] o_seg1,
	output [6:0] o_seg2,
	output [6:0] o_seg3,
	output [6:0] o_seg4,
	output [6:0] o_seg5,
	output [6:0] o_seg6,
	output [6:0] o_seg7,
	output [1:0] o_clk_sel, //LEDR1, LEDR0
	output o_clk_mux,  //LEDR2
	output o_EX_RegWr,//LEDG0
	output o_DMEM_mem_WE, //LEDG1
	output reg o_halt, //LEDG2
	output o_overflow //LEDG3
);

	wire s_clk_button_debounce;
	wire s_reset, s_clk_db;
	
	//Debounce button
	Debouncer g_debounce_clk_button (
		.Clock(i_clk),
		.Manual(i_clk_button),
		.Smooth(s_clk_button_debounce)
	);
	
	//Invert button inputs so nonlatch is 0, latch is 1
	assign s_clk_db = ~s_clk_button_debounce;
	assign s_reset = ~i_rst;
	
	wire s_clk_div;
	
	//Clock divider for MIPS processor
	clock_divider
	#(.DVSR(50000000)) g_clock_divider_slow
	(
		.clk(i_clk),
		.reset(s_reset),
		.en(1),
		.tick(s_clk_div_slow)
	);

	clock_divider
	#(.DVSR(1)) g_clock_divider_fast
	(
		.clk(i_clk),
		.reset(s_reset),
		.en(1),
		.tick(s_clk_div_fast)
	);
	
	//Clk mux
	assign o_clk_sel = i_clk_sel;

	wire s_clk, s_clk_div_fast, s_clk_div_slow;
	reg s_clk_mux;
	/*
	00: debounce button clock
	01: 200 ms Clock
	10: 25 MHz clock
	*/
	always @* begin
		case(i_clk_sel)
			2'b00: s_clk_mux = s_clk_db;
			2'b01: s_clk_mux = s_clk_div_slow;
			2'b10: s_clk_mux = s_clk_div_fast;
			default: s_clk_mux = s_clk_db;
		endcase
	end

	assign s_clk =  o_halt ? 1'b0 : s_clk_mux;

	assign o_clk_mux = s_clk;

	counter g_counter(
		.i_clk(s_clk),
		.i_rst(s_reset),
		.i_en(1'b1),
		.o_Q(s_clk_count)
	);

	/* SW[3:1]
	000 - IF instruction
	001 - EX ALU output
	010 - EX Register Write Address 
	011 - WB data memory output
	100 - Clock counter
	101 - WB RegWrData
	*/
	wire [31:0] s_IF_Imem;
	wire [31:0] s_EX_ALUout;
	wire [4:0] s_EX_RegWrAddr;
	wire [31:0] s_DMEM_DMEM_DATA;
	wire [31:0] s_clk_count;
	wire [31:0] s_WB_RegWrData;
	reg [31:0] s_seg_out;
	
	always @* begin
		case(i_out_sel)
			3'b000: s_seg_out = s_IF_Imem;
			3'b001: s_seg_out = s_EX_ALUout;
			3'b010: s_seg_out = {{27{1'b0}},s_EX_RegWrAddr};
			3'b011: s_seg_out = s_DMEM_DMEM_DATA;
			3'b100: s_seg_out = s_clk_count;
			3'b101: s_seg_out = s_WB_RegWrData;
			default: s_seg_out = s_IF_Imem;
		endcase
	end
	
	//latch halt
	wire s_halt;
	always @(posedge s_clk, posedge s_reset) begin
		if(s_reset)
			o_halt <= 0;
		else if (s_halt)
			o_halt <= 1;
	end
	
	MIPS_Processor g_MIPS_Processor(
		.iClk(s_clk),
		.iRST(s_reset),
		.iInstLd(1'b0),
		.iInstAddr(0),
		.iInstExt(0),
		.o_IF_Imem(s_IF_Imem),
		.o_EX_ALUOut(s_EX_ALUout),
		.o_EX_RegWrAddr(s_EX_RegWrAddr),
		.o_DMEM_DMEM_DATA(s_DMEM_DMEM_DATA),
		.o_EX_RegWr(o_EX_RegWr),
		.o_WB_RegWrData(s_WB_RegWrData),
		.o_DMEM_mem_WE(o_DMEM_mem_WE),
		.o_halt(s_halt),
		.o_overflow(o_overflow)
	);
	
	//Seven seg decoders
	seven_seg_decoder hex0 (.i_x(s_seg_out[3:0]), .o_seg(o_seg0));
	seven_seg_decoder hex1 (.i_x(s_seg_out[7:4]), .o_seg(o_seg1));
	seven_seg_decoder hex2 (.i_x(s_seg_out[11:8]), .o_seg(o_seg2));
	seven_seg_decoder hex3 (.i_x(s_seg_out[15:12]), .o_seg(o_seg3));
	seven_seg_decoder hex4 (.i_x(s_seg_out[19:16]), .o_seg(o_seg4));
	seven_seg_decoder hex5 (.i_x(s_seg_out[23:20]), .o_seg(o_seg5));
	seven_seg_decoder hex6 (.i_x(s_seg_out[27:24]), .o_seg(o_seg6));
	seven_seg_decoder hex7 (.i_x(s_seg_out[31:28]), .o_seg(o_seg7));

endmodule