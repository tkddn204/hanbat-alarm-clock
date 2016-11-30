
/* CURRENT_TIME BIT LIST
`define   IN_MERIDIAN IN_TIME[17]
`define	 IN_HOUR     IN_TIME[16:12]
`define	 IN_MIN      IN_TIME[11:6]
`define   IN_SEC      IN_TIME[5:0]

 CURRENT_DATE BIT LIST
`define   IN_YEAR     IN_DATE[15:9]
`define	 IN_MONTH    IN_DATE[8:5]
`define	 IN_DAY      IN_DATE[4:0]


 ALARM_TIME BIT LIST
`define	 IN_HOUR     IN_TIME[16:12]
`define	 IN_MIN      IN_TIME[11:6]
`define   IN_SEC      IN_TIME[5:0]
*/

// DISPLAY_CONT.v

module DISPLAY_CONT(
	RESETN, CLK,
	H10, H1, M10, M1, S10, S1, MERIDIAN,
	Y10, Y1, MT10, MT1, D10, D1,
	ALARM_H10, ALARM_H1, ALARM_M10, ALARM_M1, ALARM_S10, ALARM_S1,
	MODE, ALARM_ENABLE, ALARM_DOING,
	LCD_E, LCD_RS, LCD_RW,
	LCD_DATA
);

input RESETN, CLK;
input [5:0] MODE;
input [7:0] H10, H1, M10, M1, S10, S1;
input [7:0] Y10, Y1, MT10, MT1, D10, D1;
input [7:0] ALARM_H10, ALARM_H1, ALARM_M10, ALARM_M1, ALARM_S10, ALARM_S1;
input MERIDIAN, ALARM_ENABLE, ALARM_DOING;
output wire LCD_E;
output reg LCD_RS, LCD_RW;
output reg [7:0] LCD_DATA;

// LINE 1 -> [15:0], LINE 2 -> [31:16]
reg [7:0] DISPLAY_DATA [31:0];

/* MODE */
parameter CURRENT_TIME = 6'b000000,
			 CURRENT_CONTROL_TIME = 6'b010000,
			 CURRENT_CONTROL_HOUR = 6'b010011,
			 CURRENT_CONTROL_MIN = 6'b010101,
			 CURRENT_CONTROL_SEC = 6'b010111,
			 CURRENT_CONTROL_YEAR = 6'b011011,
			 CURRENT_CONTROL_MONTH = 6'b011101,
			 CURRENT_CONTROL_DAY = 6'b011111,
			 ALARM_TIME = 6'b100001,
			 ALARM_CONTROL_TIME = 6'b110001,
			 ALARM_CONTROL_HOUR = 6'b110011,
			 ALARM_CONTROL_MIN = 6'b110101,
			 ALARM_CONTROL_SEC = 6'b110111;
			 
/* MERIDIAN LIST(A, B) */
parameter AM = 8'b01000001,
			 PM = 8'b01010000;
			 
reg [2:0] STATE;
parameter DELAY = 3'b000,
          FUNCTION_SET = 3'b001,
          ENTRY_MODE = 3'b010,
          DISP_ON_OFF = 3'b011,
          LINE1 = 3'b100,
          LINE2 = 3'b101,
          DELAY_T = 3'b110,
          CLEAR_DISP = 3'b111;

reg CONT_START, CONT_START_MODE, BLINK;
integer CNT, LCD_CNT, INC, LIMIT;

always @(posedge CLK)
begin
	if(!RESETN)
		begin
			BLINK = 1'b0;
			CONT_START_MODE = 1'b0;
			CNT = 0;
			LIMIT = 0;
		end
	else
		if(CONT_START == 1'b1)
				begin
					if(LIMIT == 20)
						begin
							CONT_START_MODE = 1'b1;
							CNT = 0;
							LIMIT = 0;
						end
					else if(CNT <= 499)
						begin
							CNT = 0;
							BLINK = !BLINK;
							LIMIT = LIMIT + 1;
						end
					else
						begin
							CNT = CNT + 1;
						end
				end
		else
			CONT_START_MODE =1'b0;
end

always @(posedge CLK)
begin
	if(!RESETN)
		begin
			INC = 0;
			CONT_START = 1'b0;
			while(INC >= 31)
				begin
					DISPLAY_DATA[INC] = 8'b00100000; // space
					INC = INC + 1;
				end
		end
	else
		begin
			case(MODE)
					CURRENT_TIME:
						begin
							DISPLAY_DATA[1] = H10;
							DISPLAY_DATA[2] = H1;
							DISPLAY_DATA[3] = 8'b00111010; // :
							DISPLAY_DATA[4] = M10;
							DISPLAY_DATA[5] = M1;
							DISPLAY_DATA[6] = 8'b00111010; // :
							DISPLAY_DATA[7] = S10;
							DISPLAY_DATA[8] = S1;
							if(MERIDIAN == 1)	// Meridian is On(12)
								begin
									if((H10 >= 8'b00110001) && (H1 >= 8'b00110010))
										begin
											DISPLAY_DATA[10] = PM;
										end
									else
										begin
											DISPLAY_DATA[10] = AM;
										end
									DISPLAY_DATA[11] = 8'b01001101; // M
								end
							else
								begin
									DISPLAY_DATA[10] = 8'b00100000; // space
									DISPLAY_DATA[11] = 8'b00100000; // space
								end
							DISPLAY_DATA[13] = 8'b00100000; // 
							DISPLAY_DATA[14] = 8'b00100000; // 
							DISPLAY_DATA[17] = 8'b00110010; // 2
							DISPLAY_DATA[18] = 8'b00110000; // 0
							DISPLAY_DATA[19] = Y10;
							DISPLAY_DATA[20] = Y1;
							DISPLAY_DATA[21] = 8'b01011001; // Y
							DISPLAY_DATA[22] = MT10;
							DISPLAY_DATA[23] = MT1;
							DISPLAY_DATA[24] = 8'b01001101; // M
							DISPLAY_DATA[25] = D10;
							DISPLAY_DATA[26] = D1;
							DISPLAY_DATA[27] = 8'b01000100; // D
							if(ALARM_DOING == 1)
								begin
									DISPLAY_DATA[29] = 8'b10010001; // note
								end
							else
								begin
									DISPLAY_DATA[29] = 8'b00100000; // space
								end
							if(ALARM_ENABLE == 1)
								begin
									DISPLAY_DATA[30] = 8'b10011000; // alarm
								end
							else
								begin
									DISPLAY_DATA[30] = 8'b00100000; // space
								end
						end
					CURRENT_CONTROL_TIME:
						begin
							CONT_START = 1'b0;
							/*
							DISPLAY_DATA[1] = H10;
							DISPLAY_DATA[2] = H1;
							DISPLAY_DATA[3] = 8'b00111010; // :
							DISPLAY_DATA[4] = M10;
							DISPLAY_DATA[5] = M1;
							DISPLAY_DATA[6] = 8'b00111010; // :
							DISPLAY_DATA[7] = S10;
							DISPLAY_DATA[8] = S1;*/
							if(MERIDIAN == 1)	// Meridian is On(12)
								begin
									if((H10 >= 8'b00110001) && (H1 >= 8'b00110010))
										begin
											DISPLAY_DATA[10] = PM;
										end
									else
										begin
											DISPLAY_DATA[10] = AM;
										end
									DISPLAY_DATA[11] = 8'b01001101; // M
								end
							else
								begin
									DISPLAY_DATA[10] = 8'b00100000; // space
									DISPLAY_DATA[11] = 8'b00100000; // space
								end
							DISPLAY_DATA[14] = 8'b10101001; // special C
							if(ALARM_DOING == 1)
								begin
									DISPLAY_DATA[29] = 8'b10010001; // note
								end
							else
								begin
									DISPLAY_DATA[29] = 8'b00100000; // space
								end
							if(ALARM_ENABLE == 1)
								begin
									DISPLAY_DATA[30] = 8'b10011000; // alarm
								end
							else
								begin
									DISPLAY_DATA[30] = 8'b00100000; // space
								end
						end
					CURRENT_CONTROL_HOUR:
						begin
							CONT_START = 1'b1;
							if(BLINK == 1'b0)
								begin
									DISPLAY_DATA[1] = H10;
									DISPLAY_DATA[2] = H1;
								end
							else
								begin
									DISPLAY_DATA[1] = 8'b00100000; // space
									DISPLAY_DATA[2] = 8'b00100000; // space
								end
							/*
							DISPLAY_DATA[3] = 8'b00111010; // :
							DISPLAY_DATA[4] = M10;
							DISPLAY_DATA[5] = M1;
							DISPLAY_DATA[6] = 8'b00111010; // :
							DISPLAY_DATA[7] = S10;
							DISPLAY_DATA[8] = S1;
							if(CURRENT_TIME[17] == 1)	// Meridian is On(12)
								begin
									if(DISPLAY_DATA[16:12] >= 12)
										begin
											DISPLAY_DATA[10] = PM;
										end
									else
										begin
											DISPLAY_DATA[10] = AM;
										end
									DISPLAY_DATA[11] = 8'b01001101; // M
								end
							else
								begin
									DISPLAY_DATA[10] = 8'b00100000; // space
									DISPLAY_DATA[11] = 8'b00100000; // space
								end
							DISPLAY_DATA[14] = 8'b10101001; // special C
							DISPLAY_DATA[17] = 8'b00110010; // 2
							DISPLAY_DATA[18] = 8'b00110000; // 0
							DISPLAY_DATA[19] = Y10;
							DISPLAY_DATA[20] = Y1;
							DISPLAY_DATA[21] = 8'b01011001; // Y
							DISPLAY_DATA[22] = MT10;
							DISPLAY_DATA[23] = MT1;
							DISPLAY_DATA[24] = 8'b01001101; // M
							DISPLAY_DATA[25] = D10;
							DISPLAY_DATA[26] = D1;
							DISPLAY_DATA[27] = 8'b01000100; // D
							*/
							if(ALARM_DOING == 1)
								begin
									DISPLAY_DATA[29] = 8'b10010001; // note
								end
							else
								begin
									DISPLAY_DATA[29] = 8'b00100000; // space
								end
							/*
							if(ALARM_ENABLE == 1)
								begin
									DISPLAY_DATA[30] = 8'b10011000; // alarm
								end
							else
								begin
									DISPLAY_DATA[30] = 8'b00100000; // space
								end
							*/
						end
					CURRENT_CONTROL_MIN:
						begin
							if(BLINK == 1'b0)
								begin
									DISPLAY_DATA[4] = M10;
									DISPLAY_DATA[5] = M1;
								end
							else
								begin
									DISPLAY_DATA[4] = 8'b00100000; // space
									DISPLAY_DATA[5] = 8'b00100000; // space
								end
							if(ALARM_DOING == 1)
								begin
									DISPLAY_DATA[29] = 8'b10010001; // note
								end
							else
								begin
									DISPLAY_DATA[29] = 8'b00100000; // space
								end
						end
					CURRENT_CONTROL_SEC:
						begin
							if(BLINK == 1'b0)
								begin
									DISPLAY_DATA[7] = S10;
									DISPLAY_DATA[8] = S1;
								end
							else
								begin
									DISPLAY_DATA[7] = 8'b00100000; // space
									DISPLAY_DATA[8] = 8'b00100000; // space
								end
							if(ALARM_DOING == 1)
								begin
									DISPLAY_DATA[29] = 8'b10010001; // note
								end
							else
								begin
									DISPLAY_DATA[29] = 8'b00100000; // space
								end
						end
					CURRENT_CONTROL_YEAR:
						begin
							if(BLINK == 1'b0)
								begin
									DISPLAY_DATA[19] = Y10;
									DISPLAY_DATA[20] = Y1;
								end
							else
								begin
									DISPLAY_DATA[19] = 8'b00100000; // space
									DISPLAY_DATA[20] = 8'b00100000; // space
								end
							if(ALARM_DOING == 1)
								begin
									DISPLAY_DATA[29] = 8'b10010001; // note
								end
							else
								begin
									DISPLAY_DATA[29] = 8'b00100000; // space
								end
						end
					CURRENT_CONTROL_MONTH:
						begin
							if(BLINK == 1'b0)
								begin
									DISPLAY_DATA[22] = MT10;
									DISPLAY_DATA[23] = MT1;
								end
							else
								begin
									DISPLAY_DATA[22] = 8'b00100000; // space
									DISPLAY_DATA[23] = 8'b00100000; // space
								end
							if(ALARM_DOING == 1)
								begin
									DISPLAY_DATA[29] = 8'b10010001; // note
								end
							else
								begin
									DISPLAY_DATA[29] = 8'b00100000; // space
								end
						end
					CURRENT_CONTROL_DAY:
						begin
							if(BLINK == 1'b0)
								begin
									DISPLAY_DATA[25] = D10;
									DISPLAY_DATA[26] = D1;
								end
							else
								begin
									DISPLAY_DATA[25] = 8'b00100000; // space
									DISPLAY_DATA[26] = 8'b00100000; // space
								end
							if(ALARM_DOING == 1)
								begin
									DISPLAY_DATA[29] = 8'b10010001; // note
								end
							else
								begin
									DISPLAY_DATA[29] = 8'b00100000; // space
								end
						end
					ALARM_TIME:
						begin
							DISPLAY_DATA[1] = ALARM_H10;
							DISPLAY_DATA[2] = ALARM_H1;
							DISPLAY_DATA[3] = 8'b00111010; // :
							DISPLAY_DATA[4] = ALARM_M10;
							DISPLAY_DATA[5] = ALARM_M1;
							DISPLAY_DATA[6] = 8'b00111010; // :
							DISPLAY_DATA[7] = ALARM_S10;
							DISPLAY_DATA[8] = ALARM_S1;
							if(MERIDIAN == 1)	// Meridian is On(12)
								begin
									if((H10 >= 8'b00110001) && (H1 >= 8'b00110010))
										begin
											DISPLAY_DATA[10] = PM;
										end
									else
										begin
											DISPLAY_DATA[10] = AM;
										end
									DISPLAY_DATA[11] = 8'b01001101; // M
								end
							else
								begin
									DISPLAY_DATA[10] = 8'b00100000; // space
									DISPLAY_DATA[11] = 8'b00100000; // space
								end
							DISPLAY_DATA[13] = 8'b10011000; // alarm
							DISPLAY_DATA[14] = 8'b00100000; // 
							DISPLAY_DATA[17] = 8'b00100000; // 
							DISPLAY_DATA[18] = 8'b00100000; // 
							DISPLAY_DATA[19] = 8'b00100000; // 
							DISPLAY_DATA[20] = 8'b00100000; // 
							DISPLAY_DATA[21] = 8'b00100000; // 
							DISPLAY_DATA[22] = 8'b00100000; // 
							DISPLAY_DATA[23] = 8'b00100000; // 
							DISPLAY_DATA[24] = 8'b00100000; // 
							DISPLAY_DATA[25] = 8'b00100000; // 
							DISPLAY_DATA[26] = 8'b00100000; // 
							DISPLAY_DATA[27] = 8'b00100000; // 
							if(ALARM_DOING == 1)
								begin
									DISPLAY_DATA[29] = 8'b10010001; // note
								end
							else
								begin
									DISPLAY_DATA[29] = 8'b00100000; // space
								end
							if(ALARM_ENABLE == 1)
								begin
									DISPLAY_DATA[30] = 8'b10011000; // alarm
								end
							else
								begin
									DISPLAY_DATA[30] = 8'b00100000; // space
								end
						end
					ALARM_CONTROL_TIME:
						begin
							CONT_START = 1'b0;
							/*
							DISPLAY_DATA[1] = ALARM_H10;
							DISPLAY_DATA[2] = ALARM_H1;
							DISPLAY_DATA[3] = 8'b00111010; // :
							DISPLAY_DATA[4] = ALARM_M10;
							DISPLAY_DATA[5] = ALARM_M1;
							DISPLAY_DATA[6] = 8'b00111010; // :
							DISPLAY_DATA[7] = ALARM_S10;
							DISPLAY_DATA[8] = ALARM_S1; */
							if(MERIDIAN == 1)	// Meridian is On(12)
								begin
									if((H10 >= 8'b00110001) && (H1 >= 8'b00110010))
										begin
											DISPLAY_DATA[10] = PM;
										end
									else
										begin
											DISPLAY_DATA[10] = AM;
										end
									DISPLAY_DATA[11] = 8'b01001101; // M
								end
							else
								begin
									DISPLAY_DATA[10] = 8'b00100000; // space
									DISPLAY_DATA[11] = 8'b00100000; // space
								end
							DISPLAY_DATA[13] = 8'b10011000; // alarm
							DISPLAY_DATA[14] = 8'b10101001; // special C
							if(ALARM_DOING == 1)
								begin
									DISPLAY_DATA[29] = 8'b10010001; // note
								end
							else
								begin
									DISPLAY_DATA[29] = 8'b00100000; // space
								end
							if(ALARM_ENABLE == 1)
								begin
									DISPLAY_DATA[30] = 8'b10011000; // alarm
								end
							else
								begin
									DISPLAY_DATA[30] = 8'b00111010; // space
								end
						end
					ALARM_CONTROL_HOUR:
						begin
							CONT_START = 1'b1;
							if(BLINK == 1'b0)
								begin
									DISPLAY_DATA[1] = ALARM_H10;
									DISPLAY_DATA[2] = ALARM_H1;
								end
							else
								begin
									DISPLAY_DATA[1] = 8'b00100000; // space
									DISPLAY_DATA[2] = 8'b00100000; // space
								end
							if(ALARM_DOING == 1)
								begin
									DISPLAY_DATA[29] = 8'b10010001; // note
								end
							else
								begin
									DISPLAY_DATA[29] = 8'b00100000; // space
								end
						end
					ALARM_CONTROL_MIN:
						begin
							if(BLINK == 1'b0)
								begin
									DISPLAY_DATA[4] = ALARM_M10;
									DISPLAY_DATA[5] = ALARM_M1;
								end
							else
								begin
									DISPLAY_DATA[4] = 8'b00100000; // space
									DISPLAY_DATA[5] = 8'b00100000; // space
								end
							if(ALARM_DOING == 1)
								begin
									DISPLAY_DATA[29] = 8'b10010001; // note
								end
							else
								begin
									DISPLAY_DATA[29] = 8'b00100000; // space
								end
							
						end
					ALARM_CONTROL_SEC:
						begin
							if(BLINK == 1'b0)
								begin
									DISPLAY_DATA[7] = ALARM_S10;
									DISPLAY_DATA[8] = ALARM_S1;
								end
							else
								begin
									DISPLAY_DATA[7] = 8'b00100000; // space
									DISPLAY_DATA[8] = 8'b00100000; // space
								end
							if(ALARM_DOING == 1)
								begin
									DISPLAY_DATA[29] = 8'b10010001; // note
								end
							else
								begin
									DISPLAY_DATA[29] = 8'b00100000; // space
								end
							
						end
					default:
						begin
							INC = 0;
							while(INC <= 31)
								begin
									DISPLAY_DATA[INC] = 8'b00100000; // space
									INC = INC + 1;
								end
						end
			endcase
		end
end
		 
// DISPLAY part
always @(posedge CLK)
begin
    if (RESETN == 1'b0)
        STATE = DELAY;
    else
        begin
            case(STATE)
                DELAY:
                    if(LCD_CNT == 70) STATE = FUNCTION_SET;
                FUNCTION_SET:
                    if(LCD_CNT == 30) STATE = DISP_ON_OFF;
                DISP_ON_OFF:
                    if(LCD_CNT == 30) STATE = ENTRY_MODE;
                ENTRY_MODE:
                    if(LCD_CNT == 30) STATE = LINE1;
                LINE1:
                    if(LCD_CNT == 17) STATE = LINE2;
                LINE2:
                    if(LCD_CNT == 17) STATE = LINE1;
                DELAY_T:
                    if(LCD_CNT == 17) STATE = LINE1;
                CLEAR_DISP:
                    if(LCD_CNT == 200) STATE = LINE1;
                default: STATE = DELAY;
            endcase
        end
end

always @(posedge CLK)
begin
    if(RESETN == 1'b0)
        LCD_CNT = 0;
    else
        begin
            case(STATE)
                DELAY:
                    if(LCD_CNT >= 70) LCD_CNT = 0;
                    else LCD_CNT = LCD_CNT + 1;
                FUNCTION_SET:
                    if(LCD_CNT >= 30) LCD_CNT = 0;
                    else LCD_CNT = LCD_CNT + 1;
                DISP_ON_OFF:
                    if(LCD_CNT >= 30) LCD_CNT = 0;
                    else LCD_CNT = LCD_CNT + 1;
                ENTRY_MODE:
                    if(LCD_CNT >= 30) LCD_CNT = 0;
                    else LCD_CNT = LCD_CNT + 1;
                LINE1:
                    if(LCD_CNT >= 17) LCD_CNT = 0;
                    else LCD_CNT = LCD_CNT + 1;
                LINE2:
                    if(LCD_CNT >= 17) LCD_CNT = 0;
                    else LCD_CNT = LCD_CNT + 1;
                DELAY_T:
                    if(LCD_CNT >= 17) LCD_CNT = 0;
                    else LCD_CNT = LCD_CNT + 1;
                CLEAR_DISP:
                    if(LCD_CNT >= 200) LCD_CNT = 0;
                    else LCD_CNT = LCD_CNT + 1;
                default: LCD_CNT = 0;
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
                        if(LCD_CNT == 0)
									begin
										LCD_RS = 1'b0;
										LCD_DATA = 8'b10000000;
									end
								else if(LCD_CNT <= 16)
									begin
										// DISPLAY_DATA[15:0]
										LCD_RS = 1'b1;
										LCD_DATA = DISPLAY_DATA[LCD_CNT - 1];
									end
								else
									begin
										LCD_RS = 1'b1;
                              LCD_DATA = 8'b00100000; // space character
									end
                    end
                LINE2:
                    begin
                        LCD_RW = 1'b0;
                        if(LCD_CNT == 0)
									begin
										LCD_RS = 1'b0;
										LCD_DATA = 8'b11000000;
									end
								else if(LCD_CNT <= 16)
									begin
										// DISPLAY_DATA[31:16]
										LCD_RS = 1'b1;
										LCD_DATA = DISPLAY_DATA[LCD_CNT + 15];
									end
								else
									begin
										LCD_RS = 1'b1;
                              LCD_DATA = 8'b00100000; // space character
									end
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
