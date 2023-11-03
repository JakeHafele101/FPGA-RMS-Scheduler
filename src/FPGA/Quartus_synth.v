module Quartus_synth (input CLK100MHZ,   //100MHz clock, stepped down to 5MHz
                      input [15:0] sw,
                      input btnC,        //reset
                      input btnL,        //debounced button for manual clock
                      output [15:0] LED, //indicators for outputs to PMOD
                      output [7:0] JA);  //OLED PMOD Port
    
    parameter WIDTH        = 8; //# of serial bits to transmit over MOSI, loaded from i_DATA
    parameter N            = 8; //# of serial bits to transmit over MOSI, loaded from i_DATA
    parameter SCLK_DIVIDER = 20; //divide clock by 1
    
    parameter WAIT_3_US   = 20;
    parameter WAIT_100_MS = 600000;
    
    parameter NUM_COL = 96; //# of columns in OLED array
    parameter NUM_ROW = 64; //# of rows in OLED array
    
    parameter NUM_ASCII_COL = NUM_COL / ASCII_COL_SIZE; //# of cols of ASCII chars (12 Default)
    parameter NUM_ASCII_ROW = NUM_ROW / ASCII_ROW_SIZE; //# of rows of ASCII chars (8 Default)
    
    parameter ASCII_COL_SIZE = 8; //Number of x bits of ASCII char
    parameter ASCII_ROW_SIZE = 8; //Number of y bits of ASCII char
    
    parameter N_COLOR_BITS = 8;
    
    wire [NUM_ASCII_COL * NUM_ASCII_ROW * 8 - 1:0] s_ASCII;
    wire [N_COLOR_BITS-1:0] s_background_color;
    wire [N_COLOR_BITS-1:0] s_text_color;
    
    //Wires to outputs
    wire s_READY, s_CS, s_MOSI, s_SCK, s_DC, s_RES, s_VCCEN, s_PMODEN;
    
    wire s_clk_button_debounce;
    wire s_reset, s_clk_db;
    
    //Debounce button
    button_tick_latch g_button_tick_latch (
    .i_CLK(CLK100MHZ),
    .i_RST(s_reset),
    .i_BTN(btnL),
    .o_TICK(s_clk_button_debounce)
    );
    
    //Invert button inputs so nonlatch is 0, latch is 1
    assign s_clk_db = s_clk_button_debounce;
    assign s_reset  = btnC;
    
    wire s_clk_div;
    wire s_clk, s_clk_div_slow;
    //Clock divider for MIPS processor
    clock_divider
    #(.DVSR(50000000)) g_clock_divider_slow
    (
    .i_CLK(CLK100MHZ),
    .i_RST(s_reset),
    .i_EN(1),
    .o_CLK_DIV(s_clk_div_slow)
    );
    
    reg s_clk_mux;
    /*
     00: debounce button clock
     01: 200 ms Clock
     */
    always @* begin
        case(sw[1:0])
            2'b00: s_clk_mux   = s_clk_db;
            2'b01: s_clk_mux   = s_clk_div_slow;
            default: s_clk_mux = s_clk_db;
        endcase
    end
    
    wire [31:0] s_task0_PC;
    wire [31:0] s_task1_PC;
    wire [31:0] s_task2_PC;
    wire [31:0] s_task3_PC;
    wire [31:0] s_task4_PC;
    wire [31:0] s_task0_dffN_Q;
    wire [31:0] s_task1_dffN_Q;
    wire [31:0] s_task2_dffN_Q;
    wire [31:0] s_task3_dffN_Q;
    wire [31:0] s_task4_dffN_Q;
    
    wire [31:0] s_time;
    wire s_LCM_clear;
    
    wire [4:0] s_task_period_clear, s_task_complete;
    
    wire [2:0] s_task_sel;
    wire s_task_sel_WE;
    
    RMS #(
    .TASK0PERIOD (3),
    .TASK1PERIOD(3),
    .TASK2PERIOD(7),
    .TASK3PERIOD(7),
    .TASK4PERIOD(7),
    
    .TASK0_INITIAL_PC(0),
    .TASK1_INITIAL_PC(0),
    .TASK2_INITIAL_PC(0),
    .TASK3_INITIAL_PC(0),
    .TASK4_INITIAL_PC(0),
    
    .TASK0_FINAL_PC(4),
    .TASK1_FINAL_PC(4),
    .TASK2_FINAL_PC(4),
    .TASK3_FINAL_PC(4),
    .TASK4_FINAL_PC(8),
    
    .LCM(6)
    )
    g_RMS(
    .i_CLK(s_clk_mux),
    .i_Asynch_RST(s_reset),
    .i_dffN_incr(32'h00000001),
    .i_PC_incr(32'h00000004),
    
    .o_time(s_time),
    .o_LCMclear(s_LCM_clear),
    
    .o_Current_Task_Sel(s_task_sel),
    .o_Current_Task_Sel_WE(s_Task_Sel_WE),
    
    .o_Task0_Period_Clear(s_task_period_clear[0]),
    .o_Task1_Period_Clear(s_task_period_clear[1]),
    .o_Task2_Period_Clear(s_task_period_clear[2]),
    .o_Task3_Period_Clear(s_task_period_clear[3]),
    .o_Task4_Period_Clear(s_task_period_clear[4]),
    
    .o_task0_currentPC(s_task0_PC),
    .o_task1_currentPC(s_task1_PC),
    .o_task2_currentPC(s_task2_PC),
    .o_task3_currentPC(s_task3_PC),
    .o_task4_currentPC(s_task4_PC),
    
    .o_task0_dffN_Q(s_task0_dffN_Q),
    .o_task1_dffN_Q(s_task1_dffN_Q),
    .o_task2_dffN_Q(s_task2_dffN_Q),
    .o_task3_dffN_Q(s_task3_dffN_Q),
    .o_task4_dffN_Q(s_task4_dffN_Q),
    
    .o_task0_isComplete(s_task_complete[0]),
    .o_task1_isComplete(s_task_complete[1]),
    .o_task2_isComplete(s_task_complete[2]),
    .o_task3_isComplete(s_task_complete[3]),
    .o_task4_isComplete(s_task_complete[4])
    );
    
    assign LED[4:0] = s_task_period_clear;
    assign LED[9:5] = s_task_complete;
    assign LED[10]  = s_LCM_clear;
    assign LED[11]  = s_task_sel_WE;
    
    RMS_ASCII g_RMS_ASCII(
    .i_task0_currentPC(s_task0_PC),
    .i_task1_currentPC(s_task1_PC),
    .i_task2_currentPC(s_task2_PC),
    .i_task3_currentPC(s_task3_PC),
    .i_task4_currentPC(s_task4_PC),

	.i_task0_dffN_Q(s_task0_dffN_Q),
	.i_task1_dffN_Q(s_task1_dffN_Q),
	.i_task2_dffN_Q(s_task2_dffN_Q),
	.i_task3_dffN_Q(s_task3_dffN_Q),
	.i_task4_dffN_Q(s_task4_dffN_Q),

	.i_task_period_clear(s_task_period_clear),
	.i_task_isComplete(s_task_complete),

	.i_time(s_time),
	.i_task_sel(s_task_sel),
	.i_task_sel_WE(s_task_sel_WE),
	.i_LCM_clear(s_LCM_clear),

    .o_ASCII(s_ASCII),
    .o_BACKGROUND_COLOR(s_background_color),
    .o_TEXT_COLOR(s_text_color)
    );
    
    OLED_interface
    #(.WIDTH(WIDTH),
    .N(N),
    .SCLK_DIVIDER(SCLK_DIVIDER),
    .WAIT_3_US(WAIT_3_US),
    .WAIT_100_MS(WAIT_100_MS),
    .NUM_COL(NUM_COL),
    .NUM_ROW(NUM_ROW),
    .ASCII_COL_SIZE(ASCII_COL_SIZE),
    .ASCII_ROW_SIZE(ASCII_ROW_SIZE),
    .N_COLOR_BITS(N_COLOR_BITS)
    )
    g_OLED_interface
    (.i_CLK(CLK100MHZ),
    .i_RST(s_reset),
    .i_MODE(2'b10), //always in text display mode
    .i_START(1'b1), //auto update
    .i_TEXT_COLOR(s_text_color),
    .i_BACKGROUND_COLOR(s_background_color),
    .i_ASCII(s_ASCII),
    .o_READY(s_READY),
    .o_CS(s_CS),
    .o_MOSI(s_MOSI),
    .o_SCK(s_SCK),
    .o_DC(s_DC),
    .o_RES(s_RES),
    .o_VCCEN(s_VCCEN),
    .o_PMODEN(s_PMODEN)
    );
    
    assign JA[0] = s_CS; //P18
    assign JA[1] = s_MOSI; //M18
    assign JA[2] = 1'b0; //N17, NO CONNECT
    assign JA[3] = s_SCK; //P18
    assign JA[4] = s_DC; //L17
    assign JA[5] = s_RES; //M19
    assign JA[6] = s_VCCEN; //P17
    assign JA[7] = s_PMODEN; //R18
    
endmodule
