module Quartus_synth (input CLK100MHZ,   //100MHz clock, stepped down to 5MHz
                      input [15:0] sw,
                      input btnC,        //reset
                      input btnL,        //debounced button for manual clock
                      output [15:0] LED, //indicators for outputs to PMOD
                      output [7:0] JA);  //OLED PMOD Port

    wire s_clk_button_debounce;
    wire s_reset, s_clk_db;
    
    //Debounce button
    debounce g_debounce_clk_button (
    .clk(CLK100MHZ),
    .reset(s_reset),
    .switch(btnL),
    .db(s_clk_button_debounce)
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
    .TASK4_FINAL_PC(8)
    )
    g_RMS(
    .i_CLK(s_clk_mux),
    .i_Asynch_RST(s_reset),
    .i_dffN_incr(32'h00000007),
    .i_PC_incr(32'h00000004),
    
    .o_time(s_time),
    .o_LCMclear(s_LCM_clear),
    
    .o_Current_Task_Sel(s_task_sel),
    .o_Current_Task_Sel_WE(o_Task_Sel_WE),
    
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
	assign LED[10] = s_LCM_clear;
	assign LED[11] = s_task_sel_WE;
    
endmodule
