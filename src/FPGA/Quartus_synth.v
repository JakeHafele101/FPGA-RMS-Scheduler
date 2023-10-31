module Quartus_synth (
	input i_clk, //50 MHz Clk
	input i_clk_button, //KEY0
	input i_rst, //KEY1
	input [1:0] i_clk_sel, //SW1, SW0
	input [2:0] i_out_sel, //SW4, SW3, SW2
	output o_task0Complete,
	output o_task1Complete,
	output o_task2Complete,
	output o_task3Complete,
	output o_task4Complete,
	output o_LCMclear,
	output o_task0Clear,
	output o_task1Clear,
	output o_task2Clear,
	output o_task3Clear,
	output o_task4Clear,
	output o_Task_Sel_WE,
	output [6:0] o_seg0,
	output [6:0] o_seg1,
	output [6:0] o_seg2,
	output [6:0] o_seg3,
	output [6:0] o_seg4,
	output [6:0] o_seg5,
	output [6:0] o_seg6,
	output [6:0] o_seg7, //Task Sel
	output [1:0] o_clk_sel, //LEDR1, LEDR0
	output o_clk_mux,  //LEDR2
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
	wire [31:0] s_task0_PC;
	wire [31:0] s_task1_PC;
	wire [31:0] s_task2_PC;
	wire [31:0] s_task3_PC;
	wire [31:0] s_task4_PC;
	wire [31:0] s_time;
	reg [31:0] s_seg_out;
	
	always @* begin
		case(i_out_sel)
			3'b000: s_seg_out = s_task0_PC;
			3'b001: s_seg_out = s_task1_PC;
			3'b010: s_seg_out = s_task2_PC;
			3'b011: s_seg_out = s_task3_PC;
			3'b100: s_seg_out = s_task4_PC;
			3'b101: s_seg_out = s_time;
			default: s_seg_out = s_IF_Imem;
		endcase
	end
	
	wire [2:0] s_task_sel;
	RMS #(
		TASK0PERIOD = 65,
		TASK1PERIOD = 70,
		TASK2PERIOD = 75,
		TASK3PERIOD = 80,
		TASK4PERIOD = 85,

		TASK0_INITIAL_PC = 0,
		TASK1_INITIAL_PC = 100,
		TASK2_INITIAL_PC = 200,
		TASK3_INITIAL_PC = 300,
		TASK4_INITIAL_PC = 400,

		TASK0_FINAL_PC = 15,
		TASK1_FINAL_PC = 120,
		TASK2_FINAL_PC = 235,
		TASK3_FINAL_PC = 340,
		TASK4_FINAL_PC = 455,
	)
	g_RMS(
		i_CLK(s_clk),
        i_Asynch_RST(s_reset),
		i_dffN_incr(32'h00000007),
        i_PC_incr(32'h00000004),
        
    
        o_time(s_time;),
        o_LCMclear(o_LCMclear),

		
        o_Current_Task_Sel(s_task_sel),
        o_Current_Task_Sel_WE(o_Task_Sel_WE),

        o_Task0_Period_Clear(o_task0Clear),
        o_Task1_Period_Clear(o_task1Clear),
        o_Task2_Period_Clear(o_task2Clear),
        o_Task3_Period_Clear(o_task3Clear),
        o_Task4_Period_Clear(o_task4Clear),
        
        o_task0_currentPC(s_task0_PC),
        o_task1_currentPC(s_task1_PC),
        o_task2_currentPC(s_task2_PC),
        o_task3_currentPC(s_task3_PC),
        o_task4_currentPC(s_task4_PC),

        o_task0_isComplete(o_task0Complete),
        o_task1_isComplete(o_task1Complete),
        o_task2_isComplete(o_task2Complete),
        o_task3_isComplete(o_task3Complete),
        o_task4_isComplete(o_task4Complete),
	);
	
	//Seven seg decoders
	seven_seg_decoder hex0 (.i_x(s_seg_out[3:0]), .o_seg(o_seg0));
	seven_seg_decoder hex1 (.i_x(s_seg_out[7:4]), .o_seg(o_seg1));
	seven_seg_decoder hex2 (.i_x(s_seg_out[11:8]), .o_seg(o_seg2));
	seven_seg_decoder hex3 (.i_x(s_seg_out[15:12]), .o_seg(o_seg3));
	seven_seg_decoder hex4 (.i_x(s_seg_out[19:16]), .o_seg(o_seg4));
	seven_seg_decoder hex5 (.i_x(s_seg_out[23:20]), .o_seg(o_seg5));
	seven_seg_decoder hex6 (.i_x(s_seg_out[27:24]), .o_seg(o_seg6));
	seven_seg_decoder hex7 (.i_x(s_task_sel), .o_seg(o_seg7));

endmodule