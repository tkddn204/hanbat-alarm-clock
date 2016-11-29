// LCD_CONT.v

module LCD_CONT(
    RESETN, CLK,
	 DISPLAY_DATA,
);

input RESETN, CLK;
// LINE 1 -> [15:0], LINE 2 -> [31:16]
input [7:0] DISPLAY_DATA [31:0];
output wire LCD_E;
output reg LCD_RS, LCD_RW;
output reg [7:0] LCD_DATA;

			 
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
                    if(CNT == 17) STATE = LINE2;
                LINE2:
                    if(CNT == 17) STATE = DELAY_T;
                DELAY_T:
                    if(CNT == 10) STATE = LINE1;
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
                    if(CNT >= 17) CNT = 0;
                    else CNT = CNT + 1;
                LINE2:
                    if(CNT >= 17) CNT = 0;
                    else CNT = CNT + 1;
                DELAY_T:
                    if(CNT >= 10) CNT = 0;
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
                        if(CNT == 0)
									begin
										LCD_RS = 1'b0;
										LCD_DATA = 8'b10000000;
									end
								else if(CNT <= 16)
									begin
										// DISPLAY_DATA[15:0]
										LCD_RS = 1'b1;
										LCD_DATA = DISPLAY_DATA[CNT - 1];
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
                        if(CNT == 0)
									begin
										LCD_RS = 1'b0;
										LCD_DATA = 8'b11000000;
									end
								else if(CNT <= 16)
									begin
										// DISPLAY_DATA[31:16]
										LCD_RS = 1'b1;
										LCD_DATA = DISPLAY_DATA[CNT + 15];
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
