// LCD_cont.v

module LCD_cont(
    RESETN, CLK,
	 H10, H1, M10, M1, S10, S1,
	 Y10, Y1, MT10, MT1, D10, D1,
	 TIME_FORMAT, MERIDIAN, MODE, BLINK,
	 RING_ALARM, SET_ALARM,
    LCD_E, LCD_RS, LCD_RW,
    LCD_DATA
);

input RESETN, CLK;
input [7:0] H10, H1, M10, M1, S10, S1, MERIDIAN;
input [7:0] Y10, Y1, MT10, MT1, D10, D1;
input [1:0] MODE;
input [2:0] BLINK;
input TIME_FORMAT, RING_ALARM, SET_ALARM;
output LCD_E, LCD_RS, LCD_RW;
output [7:0] LCD_DATA;

wire LCD_E;
reg LCD_RS, LCD_RW;
reg [7:0] LCD_DATA;

reg [2:0] STATE;

parameter DELAY = 3'b000,
          FUNCTION_SET = 3'b001,
          ENTRY_MODE = 3'b010,
          DISP_ON_OFF = 3'b011,
          LINE1 = 3'b100,
          LINE2 = 3'b101,
          DELAY_T = 3'b110,
          CLEAR_DISP = 3'b111;
			 
/* MODE LIST */
// 10 -> State Bit
//  1 -> Control Bit
parameter CURRENT_TIME = 2'b00,
			 CURRENT_CONTROL_TIME = 2'b01,
			 ALARM_TIME = 2'b10,
			 ALARM_CONTROL_TIME = 2'b11;
			 
/* CURRENT BLINK LIST */
parameter BLINK_NO = 3'b000,
			 BLINK_HOUR = 3'b001,
			 BLINK_MIN = 3'b010,
			 BLINK_SEC = 3'b011,
			 BLINK_MERIDIAN = 3'b100,
			 BLINK_YEAR = 3'b101,
			 BLINK_MONTH = 3'b110,
			 BLINK_DAY = 3'b111;
			 
integer CNT;
integer EACH_BLINK = 0;
integer DOT_BLINK = 0;

always @(posedge CLK)
begin
    if (RESETN == 1'b0)
        STATE = DELAY;
    else
        begin
            case(STATE)
                DELAY:
                    if(CNT == 70) STATE = FUNCTION_SET;
                FUNCTION_SET:
                    if(CNT == 30) STATE = DISP_ON_OFF;
                DISP_ON_OFF:
                    if(CNT == 30) STATE = ENTRY_MODE;
                ENTRY_MODE:
                    if(CNT == 30) STATE = LINE1;
                LINE1:
                    if(CNT == 20) STATE = LINE2;
                LINE2:
                    if(CNT == 20) STATE = DELAY_T;
                DELAY_T:
                    if(CNT == 56) STATE = LINE1;
                CLEAR_DISP:
                    if(CNT == 200) STATE = LINE1;
                default: STATE = DELAY;
            endcase
        end
end

always @(posedge CLK)
begin
    if(RESETN == 1'b0)
        CNT = 0;
    else
        begin
            case(STATE)
                DELAY:
                    if(CNT >= 70) CNT = 0;
                    else CNT = CNT + 1;
                FUNCTION_SET:
                    if(CNT >= 30) CNT = 0;
                    else CNT = CNT + 1;
                DISP_ON_OFF:
                    if(CNT >= 30) CNT = 0;
                    else CNT = CNT + 1;
                ENTRY_MODE:
                    if(CNT >= 30) CNT = 0;
                    else CNT = CNT + 1;
                LINE1:
                    if(CNT >= 20) CNT = 0;
                    else CNT = CNT + 1;
                LINE2:
                    if(CNT >= 20) CNT = 0;
                    else CNT = CNT + 1;
                DELAY_T:
                    if(CNT >= 56) CNT = 0;
                    else CNT = CNT + 1;
                CLEAR_DISP:
                    if(CNT >= 200) CNT = 0;
                    else CNT = CNT + 1;
                default: CNT = 0;
            endcase
        end
end

always @(posedge CLK)
begin
    if(RESETN == 1'b0)
        begin
            LCD_RS = 1'b1;
            LCD_RW = 1'b1;
            LCD_DATA = 8'b00000000;
        end
    else
        begin
            case(STATE)
                FUNCTION_SET:
                    begin
                        LCD_RS = 1'b0;
                        LCD_RW = 1'b0;
                        LCD_DATA = 8'b00111100;
                    end
                DISP_ON_OFF:
                    begin
                        LCD_RS = 1'b0;
                        LCD_RW = 1'b0;
                        LCD_DATA = 8'b00001100;
                    end
                ENTRY_MODE:
                    begin
                        LCD_RS = 1'b0;
                        LCD_RW = 1'b0;
                        LCD_DATA = 8'b00000110;
                    end
                LINE1:
                    begin
                        LCD_RW = 1'b0;
                        
                        case(CNT)
                            0:
                                begin
                                    LCD_RS = 1'b0;
                                    LCD_DATA = 8'b10000000;
                                end
                            1:
                                begin
                                    LCD_RS = 1'b1;
                                    LCD_DATA = 8'b00100000; //
                                end
                            2:
                                begin
                                    LCD_RS = 1'b1;
												if(BLINK == BLINK_HOUR)
													if(EACH_BLINK == 1)
														begin
															EACH_BLINK = 0;
															LCD_DATA = 8'b00100000; //
														end
													else
														begin
															EACH_BLINK = 1;
															LCD_DATA = H10; // H10
														end
												else 
													LCD_DATA = H10; 			// H10
                                end
									 3:
                                begin
                                    LCD_RS = 1'b1;
												if(BLINK == BLINK_HOUR)
													if(EACH_BLINK == 1)
														begin
															EACH_BLINK = 0;
															LCD_DATA = 8'b00100000; //
														end
													else
														begin
															EACH_BLINK = 1;
															LCD_DATA = H1; // H1
														end
												else 
													LCD_DATA = H1; 			// H1
                                end
									 4:
                                begin
                                    LCD_RS = 1'b1;
												if(DOT_BLINK == 0)
													begin
														DOT_BLINK = 1;
														LCD_DATA = 8'b00100000; // 
													end
												else
													begin
														DOT_BLINK = 0;
														LCD_DATA = 8'b00111010; // :(clock count)
													end
                                end
									 5:
                                begin
                                    LCD_RS = 1'b1;
												if(BLINK == BLINK_MIN)
													if(EACH_BLINK == 1)
														begin
															EACH_BLINK = 0;
															LCD_DATA = 8'b00100000; //
														end
													else
														begin
															EACH_BLINK = 1;
															LCD_DATA = M10; // M10
														end
												else 
													LCD_DATA = M10; 			// M10
                                end
									 6:
                                begin
                                    LCD_RS = 1'b1;
												if(BLINK == BLINK_MIN)
													if(EACH_BLINK == 1)
														begin
															EACH_BLINK = 0;
															LCD_DATA = 8'b00100000; //
														end
													else
														begin
															EACH_BLINK = 1;
															LCD_DATA = M1; // H1
														end
												else 
													LCD_DATA = M1; 			// M1
                                end
									 7:
                                begin
                                    LCD_RS = 1'b1;
												if(DOT_BLINK == 1)
														LCD_DATA = 8'b00100000; // 
												else 				
														LCD_DATA = 8'b00111010; // :(clock count)
                                end
									 8:
                                begin
                                    LCD_RS = 1'b1;
												if(BLINK == BLINK_SEC)
													if(EACH_BLINK == 1)
														begin
															EACH_BLINK = 0;
															LCD_DATA = 8'b00100000; //
														end
													else
														begin
															EACH_BLINK = 1;
															LCD_DATA = S10; // S10
														end
												else 
													LCD_DATA = S10; 			// S10
                                end
									 9:
                                begin
                                    LCD_RS = 1'b1;
												if(BLINK == BLINK_SEC)
													if(EACH_BLINK == 1)
														begin
															EACH_BLINK = 0;
															LCD_DATA = 8'b00100000; //
														end
													else
														begin
															EACH_BLINK = 1;
															LCD_DATA = S1; // S1
														end
												else 
													LCD_DATA = S1; 			// S1
                                end
									 10:
                                begin
                                    LCD_RS = 1'b1;
                                    LCD_DATA = 8'b00100000; //
                                end
									 11:
                                begin
                                    LCD_RS = 1'b1;
												if(TIME_FORMAT == 1)
													if(BLINK == BLINK_MERIDIAN)
														if(EACH_BLINK == 1)
															begin
																EACH_BLINK = 0;
																LCD_DATA = 8'b00100000; //
															end
														else
															begin
																EACH_BLINK = 1;
																LCD_DATA = MERIDIAN; // meridian(A / P)
															end
													else
														LCD_DATA = MERIDIAN; // meridian(A / P)
												else
													   LCD_DATA = 8'b00100000; //
                                end
									 12:
                                begin
                                    LCD_RS = 1'b1;
												if(TIME_FORMAT == 1)
													if(BLINK == BLINK_MERIDIAN)
														if(EACH_BLINK == 1)
															begin
																EACH_BLINK = 0;
																LCD_DATA = 8'b00100000; //
															end
														else
															begin
																EACH_BLINK = 1;
																LCD_DATA = 8'b01001101; // M
															end
													else
														LCD_DATA = 8'b01001101; // M
												else
														LCD_DATA = 8'b00100000; //
                                end
                            13:
                                begin
                                    LCD_RS = 1'b1;
                                    LCD_DATA = 8'b00100000; //
                                end
                            14:
                                begin
                                    LCD_RS = 1'b1;
												if((MODE == ALARM_TIME) || (MODE == ALARM_CONTROL_TIME))
														LCD_DATA = 8'b10011000; // alarm
												else
														LCD_DATA = 8'b00100000; // 
                                end
                            15:
                                begin
                                    LCD_RS = 1'b1;
												if((MODE == CURRENT_CONTROL_TIME) || (MODE == ALARM_CONTROL_TIME))
														LCD_DATA = 8'b10101001; // special C
												else
														LCD_DATA = 8'b00100000; // 
                                end
                            16:
                                begin
                                    LCD_RS = 1'b1;
                                    LCD_DATA = 8'b00100000; //
                                end
                            default:
                                begin
                                    LCD_RS = 1'b1;
                                    LCD_DATA = 8'b00100000; //
                                end
                        endcase
                    end
                LINE2:
                    begin
                        LCD_RW = 1'b0;
                        
                        case(CNT)
                            0:
                                begin
                                    LCD_RS = 1'b0;
                                    LCD_DATA = 8'b11000000;
                                end
                            1:
                                begin
                                    LCD_RS = 1'b1;
                                    LCD_DATA = 8'b00100000; //
                                end
                            2:
                                begin
                                    LCD_RS = 1'b1;
												if(BLINK == BLINK_SEC)
													if(EACH_BLINK == 1)
														begin
															EACH_BLINK = 0;
															LCD_DATA = 8'b00100000; //
														end
													else
														begin
															EACH_BLINK = 1;
															LCD_DATA = 8'b00110010; // 2
														end
												else 
													LCD_DATA = 8'b00110010; // 2
                                end
                            3:
                                begin
                                    LCD_RS = 1'b1;
												if(BLINK == BLINK_SEC)
													if(EACH_BLINK == 1)
														begin
															EACH_BLINK = 0;
															LCD_DATA = 8'b00100000; //
														end
													else
														begin
															EACH_BLINK = 1;
															LCD_DATA = 8'b00110000; // 0
														end
												else 
													LCD_DATA = 8'b00110000; // 0
                                end
                            4:
                                begin
                                    LCD_RS = 1'b1;
												if(BLINK == BLINK_SEC)
													if(EACH_BLINK == 1)
														begin
															EACH_BLINK = 0;
															LCD_DATA = 8'b00100000; //
														end
													else
														begin
															EACH_BLINK = 1;
															LCD_DATA = Y10; // Y10
														end
												else 
													LCD_DATA = Y10; // Y10
                                end
                            5:
                                begin
                                    LCD_RS = 1'b1;
												if(BLINK == BLINK_SEC)
													if(EACH_BLINK == 1)
														begin
															EACH_BLINK = 0;
															LCD_DATA = 8'b00100000; //
														end
													else
														begin
															EACH_BLINK = 1;
															LCD_DATA = Y1; // Y1
														end
												else 
													LCD_DATA = Y1; // Y1
                                end
                            6:
                                begin
                                    LCD_RS = 1'b1;
                                    LCD_DATA = 8'b01011001; // Y
                                end
                            7:
                                begin
                                    LCD_RS = 1'b1;
												if(BLINK == BLINK_SEC)
													if(EACH_BLINK == 1)
														begin
															EACH_BLINK = 0;
															LCD_DATA = 8'b00100000; //
														end
													else
														begin
															EACH_BLINK = 1;
															LCD_DATA = MT10; // MT10	
														end
												else 
													LCD_DATA = MT10; // MT10
                                end
                            8:
                                begin
                                    LCD_RS = 1'b1;
												if(BLINK == BLINK_SEC)
													if(EACH_BLINK == 1)
														begin
															EACH_BLINK = 0;
															LCD_DATA = 8'b00100000; //
														end
													else
														begin
															EACH_BLINK = 1;
															LCD_DATA = MT1; // MT1
														end
												else 
													LCD_DATA = MT1; // MT1
                                end
                            9:
                                begin
                                    LCD_RS = 1'b1;
                                    LCD_DATA = 8'b01001101; // M
                                end
                            10:
                                begin
                                    LCD_RS = 1'b1;
												if(BLINK == BLINK_SEC)
													if(EACH_BLINK == 1)
														begin
															EACH_BLINK = 0;
															LCD_DATA = 8'b00100000; //
														end
													else
														begin
															EACH_BLINK = 1;
															LCD_DATA = D10; // D10
														end
												else 
													LCD_DATA = D10; // D10
                                end
                            11:
                                begin
                                    LCD_RS = 1'b1;
												if(BLINK == BLINK_SEC)
													if(EACH_BLINK == 1)
														begin
															EACH_BLINK = 0;
															LCD_DATA = 8'b00100000; //
														end
													else
														begin
															EACH_BLINK = 1;
															LCD_DATA = D1; // D1
														end
												else 
													LCD_DATA = D1; // D1
                                end
                            12:
                                begin
                                    LCD_RS = 1'b1;
                                    LCD_DATA = 8'b01000100; // D
                                end
                            13:
                                begin
                                    LCD_RS = 1'b1;
                                    LCD_DATA = 8'b00100000; //
                                end
                            14:
                                begin
                                    LCD_RS = 1'b1;
												if(RING_ALARM == 1)
														LCD_DATA = 8'b10010001; // note
												else
														LCD_DATA = 8'b00100000; //
                                end
                            15:
                                begin
                                    LCD_RS = 1'b1;
												if(SET_ALARM == 1)
														LCD_DATA = 8'b10011000; // alarm
												else
														LCD_DATA = 8'b00100000; // 
                                end
                            16:
                                begin
                                    LCD_RS = 1'b1;
                                    LCD_DATA = 8'b00100000; //
                                end
                            default:
                                begin
                                    LCD_RS = 1'b1;
                                    LCD_DATA = 8'b00100000;	//
                                end
                        endcase
                    end
                DELAY_T:
                    begin
                        LCD_RS = 1'b0;
                        LCD_RW = 1'b0;
                        LCD_DATA = 8'b00000010;
                    end
                CLEAR_DISP:
                    begin
                        LCD_RS = 1'b0;
                        LCD_RW = 1'b0;
                        LCD_DATA = 8'b00000001;
                    end
                default:
                    begin
                        LCD_RS = 1'b1;
                        LCD_RW = 1'b1;
                        LCD_DATA = 8'b00000000;
                    end
            endcase
        end
end

assign LCD_E = !CLK;

endmodule
