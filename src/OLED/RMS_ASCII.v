module RMS_ASCII(input [31:0] i_task0_currentPC, i_task1_currentPC, i_task2_currentPC, i_task3_currentPC, i_task4_currentPC,
                 input [31:0] i_task0_dffN_Q, i_task1_dffN_Q, i_task2_dffN_Q, i_task3_dffN_Q, i_task4_dffN_Q,
                 input [4:0] i_task_period_clear, i_task_isComplete,
                 input [31:0] i_time, 
                 input [2:0] i_task_sel,
                 input i_task_sel_WE, i_LCM_clear,
                 output [NUM_ASCII_COL * NUM_ASCII_ROW * 8 - 1:0] o_ASCII, //output ASCII
                 output [N_COLOR_BITS - 1 : 0] o_BACKGROUND_COLOR, o_TEXT_COLOR);
    
    parameter NUM_COL = 96; //# of columns in OLED array
    parameter NUM_ROW = 64; //# of rows in OLED array
    
    parameter NUM_ASCII_COL = NUM_COL / ASCII_COL_SIZE; //# of cols of ASCII chars (12 Default)
    parameter NUM_ASCII_ROW = NUM_ROW / ASCII_ROW_SIZE; //# of rows of ASCII chars (8 Default)
    
    parameter ASCII_COL_SIZE = 8; //Number of x bits of ASCII char
    parameter ASCII_ROW_SIZE = 8; //Number of y bits of ASCII char
    
    parameter N_COLOR_BITS = 8;
    
    wire [23:0] s_t0_currentPC_ASCII, s_t1_currentPC_ASCII, s_t2_currentPC_ASCII, s_t3_currentPC_ASCII, s_t4_currentPC_ASCII;
    wire [23:0] s_t0_dffN_ASCII, s_t1_dffN_ASCII, s_t2_dffN_ASCII, s_t3_dffN_ASCII, s_t4_dffN_ASCII;
    wire [7:0] s_t0_isComplete_ASCII, s_t1_isComplete_ASCII, s_t2_isComplete_ASCII, s_t3_isComplete_ASCII, s_t4_isComplete_ASCII;
    wire [23:0] s_time_ASCII;
    wire [7:0] s_task_SEL_ASCII, s_task_SEL_WE_ASCII;
    wire [7:0] s_LCM_Clear_ASCII;

    hex_to_ASCII g_t0_currentPC0(
    .i_hex(i_task0_currentPC[3:0]),
    .o_ASCII(s_t0_currentPC_ASCII[7:0])
    );
    
    hex_to_ASCII g_t0_currentPC1(
    .i_hex(i_task0_currentPC[7:4]),
    .o_ASCII(s_t0_currentPC_ASCII[15:8])
    );
    
    hex_to_ASCII g_t0_currentPC2(
    .i_hex(i_task0_currentPC[11:8]),
    .o_ASCII(s_t0_currentPC_ASCII[23:16])
    );
    
    hex_to_ASCII g_t0_dffN0(
    .i_hex(i_task0_dffN_Q[3:0]),
    .o_ASCII(s_t0_dffN_ASCII[7:0])
    );

    hex_to_ASCII g_t0_dffN1(
    .i_hex(i_task0_dffN_Q[7:4]),
    .o_ASCII(s_t0_dffN_ASCII[15:8])
    );

    hex_to_ASCII g_t0_dffN2(
    .i_hex(i_task0_dffN_Q[11:8]),
    .o_ASCII(s_t0_dffN_ASCII[23:16])
    );

    hex_to_ASCII g_t0_complete(
    .i_hex({7'b0000000, i_task_isComplete[0]}),
    .o_ASCII(s_t0_isComplete_ASCII)
    );

    hex_to_ASCII g_t1_currentPC0(
    .i_hex(i_task1_currentPC[3:0]),
    .o_ASCII(s_t1_currentPC_ASCII[7:0])
    );
    
    hex_to_ASCII g_t1_currentPC1(
    .i_hex(i_task1_currentPC[7:4]),
    .o_ASCII(s_t1_currentPC_ASCII[15:8])
    );
    
    hex_to_ASCII g_t1_currentPC2(
    .i_hex(i_task1_currentPC[11:8]),
    .o_ASCII(s_t1_currentPC_ASCII[23:16])
    );
    
    hex_to_ASCII g_t1_dffN0(
    .i_hex(i_task1_dffN_Q[3:0]),
    .o_ASCII(s_t1_dffN_ASCII[7:0])
    );

    hex_to_ASCII g_t1_dffN1(
    .i_hex(i_task1_dffN_Q[7:4]),
    .o_ASCII(s_t1_dffN_ASCII[15:8])
    );

    hex_to_ASCII g_t1_dffN2(
    .i_hex(i_task1_dffN_Q[11:8]),
    .o_ASCII(s_t1_dffN_ASCII[23:16])
    );

    hex_to_ASCII g_t1_complete(
    .i_hex({7'b0000000, i_task_isComplete[1]}),
    .o_ASCII(s_t1_isComplete_ASCII)
    );

    hex_to_ASCII g_t2_currentPC0(
    .i_hex(i_task2_currentPC[3:0]),
    .o_ASCII(s_t2_currentPC_ASCII[7:0])
    );
    
    hex_to_ASCII g_t2_currentPC1(
    .i_hex(i_task2_currentPC[7:4]),
    .o_ASCII(s_t2_currentPC_ASCII[15:8])
    );
    
    hex_to_ASCII g_t2_currentPC2(
    .i_hex(i_task2_currentPC[11:8]),
    .o_ASCII(s_t2_currentPC_ASCII[23:16])
    );
    
    hex_to_ASCII g_t2_dffN0(
    .i_hex(i_task2_dffN_Q[3:0]),
    .o_ASCII(s_t2_dffN_ASCII[7:0])
    );

    hex_to_ASCII g_t2_dffN1(
    .i_hex(i_task2_dffN_Q[7:4]),
    .o_ASCII(s_t2_dffN_ASCII[15:8])
    );

    hex_to_ASCII g_t2_dffN2(
    .i_hex(i_task2_dffN_Q[11:8]),
    .o_ASCII(s_t2_dffN_ASCII[23:16])
    );

    hex_to_ASCII g_t2_complete(
    .i_hex({7'b0000000, i_task_isComplete[2]}),
    .o_ASCII(s_t2_isComplete_ASCII)
    );

    hex_to_ASCII g_t3_currentPC0(
    .i_hex(i_task3_currentPC[3:0]),
    .o_ASCII(s_t3_currentPC_ASCII[7:0])
    );
    
    hex_to_ASCII g_t3_currentPC1(
    .i_hex(i_task3_currentPC[7:4]),
    .o_ASCII(s_t3_currentPC_ASCII[15:8])
    );
    
    hex_to_ASCII g_t3_currentPC2(
    .i_hex(i_task3_currentPC[11:8]),
    .o_ASCII(s_t3_currentPC_ASCII[23:16])
    );
    
    hex_to_ASCII g_t3_dffN0(
    .i_hex(i_task3_dffN_Q[3:0]),
    .o_ASCII(s_t3_dffN_ASCII[7:0])
    );

    hex_to_ASCII g_t3_dffN1(
    .i_hex(i_task3_dffN_Q[7:4]),
    .o_ASCII(s_t3_dffN_ASCII[15:8])
    );

    hex_to_ASCII g_t3_dffN2(
    .i_hex(i_task3_dffN_Q[11:8]),
    .o_ASCII(s_t3_dffN_ASCII[23:16])
    );

    hex_to_ASCII g_t3_complete(
    .i_hex({7'b0000000, i_task_isComplete[3]}),
    .o_ASCII(s_t3_isComplete_ASCII)
    );

    hex_to_ASCII g_t4_currentPC0(
    .i_hex(i_task4_currentPC[3:0]),
    .o_ASCII(s_t4_currentPC_ASCII[7:0])
    );
    
    hex_to_ASCII g_t4_currentPC1(
    .i_hex(i_task4_currentPC[7:4]),
    .o_ASCII(s_t4_currentPC_ASCII[15:8])
    );
    
    hex_to_ASCII g_t4_currentPC2(
    .i_hex(i_task4_currentPC[11:8]),
    .o_ASCII(s_t4_currentPC_ASCII[23:16])
    );
    
    hex_to_ASCII g_t4_dffN0(
    .i_hex(i_task4_dffN_Q[3:0]),
    .o_ASCII(s_t4_dffN_ASCII[7:0])
    );

    hex_to_ASCII g_t4_dffN1(
    .i_hex(i_task4_dffN_Q[7:4]),
    .o_ASCII(s_t4_dffN_ASCII[15:8])
    );

    hex_to_ASCII g_t4_dffN2(
    .i_hex(i_task4_dffN_Q[11:8]),
    .o_ASCII(s_t4_dffN_ASCII[23:16])
    );

    hex_to_ASCII g_t4_complete(
    .i_hex({7'b0000000, i_task_isComplete[4]}),
    .o_ASCII(s_t4_isComplete_ASCII)
    );

    hex_to_ASCII g_time0(
    .i_hex(i_time[3:0]),
    .o_ASCII(s_time_ASCII[7:0])
    );

    hex_to_ASCII g_time1(
    .i_hex(i_time[7:4]),
    .o_ASCII(s_time_ASCII[15:8])
    );

    hex_to_ASCII g_time2(
    .i_hex(i_time[11:8]),
    .o_ASCII(s_time_ASCII[23:16])
    );

    hex_to_ASCII g_task_sel(
    .i_hex({1'b0, i_task_sel}),
    .o_ASCII(s_task_SEL_ASCII)
    );

    hex_to_ASCII g_i_task_sel_WE(
    .i_hex({3'b000, i_task_sel_WE}),
    .o_ASCII(s_task_SEL_WE_ASCII)
    );

    hex_to_ASCII g_LCM_ASCII(
    .i_hex({3'b000, i_LCM_clear}),
    .o_ASCII(s_LCM_Clear_ASCII)
    );
    
    assign o_BACKGROUND_COLOR = 8'b00000011; //blue
    assign o_TEXT_COLOR       = 8'b11111111; //white
    assign o_ASCII = {"T0 ", s_t0_currentPC_ASCII, " ", s_t0_dffN_ASCII, " ", s_t0_isComplete_ASCII,
                    "T1 ", s_t1_currentPC_ASCII, " ", s_t1_dffN_ASCII, " ", s_t1_isComplete_ASCII,
                    "T2 ", s_t2_currentPC_ASCII, " ", s_t2_dffN_ASCII, " ", s_t2_isComplete_ASCII,
                    "T3 ", s_t3_currentPC_ASCII, " ", s_t3_dffN_ASCII, " ", s_t3_isComplete_ASCII,
                    "T4 ", s_t4_currentPC_ASCII, " ", s_t4_dffN_ASCII, " ", s_t4_isComplete_ASCII,
                    "TIME: ", s_time_ASCII, "   ",
                    "SEL: ", s_task_SEL_ASCII, " WE: ", s_task_SEL_WE_ASCII,
                    "LCM CLEAR: ", s_LCM_Clear_ASCII};
    
    
endmodule
