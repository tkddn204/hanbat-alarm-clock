
/* IN_TIME BIT LIST
`define	 IN_HOUR     IN_TIME[16:12]
`define	 IN_MIN      IN_TIME[11:6]
`define   IN_SEC      IN_TIME[5:0]

 IN_DATE BIT LIST
`define   IN_YEAR     IN_DATE[15:9]
`define	 IN_MONTH    IN_DATE[8:5]
`define	 IN_DAY      IN_DATE[4:0]


 IN_ALARM_TIME BIT LIST
`define	 IN_HOUR     IN_TIME[16:12]
`define	 IN_MIN      IN_TIME[11:6]
`define   IN_SEC      IN_TIME[5:0]
*/

// KEY_CONT.v

module KEY_CONT(
	RESETN, CLK,
	KEY, IN_TIME, IN_DATE, IN_ALARM_TIME,
	MODE, ALARM_ENABLE, SETTING, ALARM_SETTING, SETTING_OK,
	OUT_TIME, OUT_DATE, OUT_ALARM_TIME, MERIDIAN
);

input RESETN, CLK;
input [4:0] KEY;
input [16:0] IN_ALARM_TIME;
input [16:0] IN_TIME;
input [15:0] IN_DATE;
input SETTING_OK;
output reg MERIDIAN;
output reg [16:0] OUT_ALARM_TIME;
output reg [16:0] OUT_TIME;
output reg [15:0] OUT_DATE;
output reg [5:0] MODE;
output reg ALARM_ENABLE, SETTING, ALARM_SETTING;

reg [5:0] MODE_BUFF;

/* KEY LIST */
parameter MENU = 5'b10000,
			 SET = 5'b01000,
			 CANCEL = 5'b00100,
			 UP = 5'b00010,
			 DOWN= 5'b00001;
			 
/* MODE
  100000    -> Current(0), Alarm(1) Control TIME Bit
  10000     -> No(0), Controlling(1) Time Bit
  1000 ~ 10 -> Control Bit
  1         -> Current Time Counting Continue(0), Stop(1) Bit
*/
parameter CURRENT_TIME = 6'b000000,
			 CURRENT_CONTROL_HOUR = 6'b010011,
			 CURRENT_CONTROL_MIN = 6'b010101,
			 CURRENT_CONTROL_SEC = 6'b010111,
			 CURRENT_CONTROL_YEAR = 6'b011011,
			 CURRENT_CONTROL_MONTH = 6'b011101,
			 CURRENT_CONTROL_DAY = 6'b011111,
			 ALARM_TIME = 6'b100000,
			 ALARM_CONTROL_HOUR = 6'b110010,
			 ALARM_CONTROL_MIN = 6'b110100,
			 ALARM_CONTROL_SEC = 6'b110110;

reg CONT_STOP, STOP_OK;
integer CNT, LIMIT;

always @(posedge CLK)
begin
	if(!RESETN)
		begin
			CONT_STOP = 1'b0;
			LIMIT = 0;
		end
	else
		begin
			if(LIMIT == 999999)
				begin
					CONT_STOP = 1'b1;
					LIMIT = 0;
				end
			else if((MODE != CURRENT_TIME) || (MODE != ALARM_TIME))
				begin
					LIMIT = LIMIT + 1;
				end
			else
				begin
					CONT_STOP = 1'b0;
					LIMIT = 0;
				end
		end
end

always @(posedge CLK)
begin
	if(!RESETN)
		begin
			MODE = CURRENT_TIME;
		end
	else
		begin
			MODE = MODE_BUFF;
		end
end

always @(posedge CLK)
begin
	if(!RESETN)
		begin
			MODE_BUFF = CURRENT_TIME;
			OUT_ALARM_TIME = 0;
			OUT_TIME = 16'b0000000000000001; // 16'b0000/000000/000001;
			OUT_DATE = 16'b0010000000100001; // 16'b0010000/0001/00001;
			ALARM_ENABLE = 0;
			MERIDIAN = 0;
			SETTING = 0;
			ALARM_SETTING = 0;
			CNT = 0;
			STOP_OK = 0;
		end
	else if(SETTING_OK)
		begin
			SETTING = 0;
			ALARM_SETTING = 0;
		end
	else if((CONT_STOP == 1'b1) && (STOP_OK = 1'b0))
				begin
					if(MODE_BUFF[5] == 0)
						begin
							SETTING = 1;
							OUT_TIME = IN_TIME;
							MODE_BUFF = CURRENT_TIME;
						end
					else
						begin
							ALARM_SETTING = 1;
							OUT_ALARM_TIME = IN_ALARM_TIME;
							MODE_BUFF = ALARM_TIME;
						end
					STOP_OK = 1'b1;
				end
	else
		begin
			STOP_OK = 1'b0;
			case(KEY)
				MENU:
					begin
						if(CNT >= 22999)
							begin
								case(MODE)
									CURRENT_TIME:
										begin
											MODE_BUFF = ALARM_TIME;
										end
									CURRENT_CONTROL_HOUR:
										begin
											MODE_BUFF = CURRENT_CONTROL_MIN;
										end
									CURRENT_CONTROL_MIN:
										begin
											MODE_BUFF = CURRENT_CONTROL_SEC;
										end
									CURRENT_CONTROL_SEC:
										begin
											MODE_BUFF = CURRENT_CONTROL_YEAR;
										end
									CURRENT_CONTROL_YEAR:
										begin
											MODE_BUFF = CURRENT_CONTROL_MONTH;
										end
									CURRENT_CONTROL_MONTH:
										begin
											MODE_BUFF = CURRENT_CONTROL_DAY;
										end
									CURRENT_CONTROL_DAY:
										begin
											MODE_BUFF = CURRENT_CONTROL_HOUR;
										end
									ALARM_TIME:
										begin
											MODE_BUFF = CURRENT_TIME;
										end
									ALARM_CONTROL_HOUR:
										begin
											MODE_BUFF = ALARM_CONTROL_MIN;
										end
									ALARM_CONTROL_MIN:
										begin
											MODE_BUFF = ALARM_CONTROL_SEC;
										end
									ALARM_CONTROL_SEC:
										begin
											MODE_BUFF = ALARM_CONTROL_HOUR;
										end
									default:
										begin
											MODE_BUFF = CURRENT_TIME;
										end
								endcase
								CNT = 0;
							end
						else
							CNT = CNT + 1;
					end
				SET:
					begin
						if(CNT >= 22999)
							begin
								case(MODE)
									CURRENT_TIME:
										begin
											MODE_BUFF = CURRENT_CONTROL_HOUR;
										end
									CURRENT_CONTROL_HOUR:
										begin
											SETTING = 1;
											MODE_BUFF = CURRENT_TIME;
										end
									CURRENT_CONTROL_MIN:
										begin
											SETTING = 1;
											MODE_BUFF = CURRENT_TIME;
										end
									CURRENT_CONTROL_SEC:
										begin
											SETTING = 1;
											MODE_BUFF = CURRENT_TIME;
										end
									CURRENT_CONTROL_YEAR:
										begin
											SETTING = 1;
											MODE_BUFF = CURRENT_TIME;
										end
									CURRENT_CONTROL_MONTH:
										begin
											SETTING = 1;
											MODE_BUFF = CURRENT_TIME;
										end
									CURRENT_CONTROL_DAY:
										begin
											SETTING = 1;
											MODE_BUFF = CURRENT_TIME;
										end
									ALARM_TIME:
										begin
											MODE_BUFF = ALARM_CONTROL_HOUR;
										end
									ALARM_CONTROL_HOUR:
										begin
											ALARM_SETTING = 1;
											MODE_BUFF = ALARM_TIME;
										end
									ALARM_CONTROL_MIN:
										begin
											ALARM_SETTING = 1;
											MODE_BUFF = ALARM_TIME;
										end
									ALARM_CONTROL_SEC:
										begin
											ALARM_SETTING = 1;
											MODE_BUFF = ALARM_TIME;
										end
									default:
										begin
											// Show Alarm Time for 3 seconds...
											// Not operate
										end
								endcase
								CNT = 0;
							end
						else
							CNT = CNT + 1;
					end
				CANCEL:
					begin
						if(CNT >= 22999)
							begin
								case(MODE)
									CURRENT_TIME:
										begin
											// MERIDIAN change...
											if(MERIDIAN == 0) MERIDIAN = 1;
											else MERIDIAN = 0;
										end
									CURRENT_CONTROL_HOUR:
										begin
											SETTING = 0;
											OUT_TIME = IN_TIME;
											MODE_BUFF = CURRENT_TIME;
										end
									CURRENT_CONTROL_MIN:
										begin
											SETTING = 0;
											OUT_TIME = IN_TIME;
											MODE_BUFF = CURRENT_TIME;
										end
									CURRENT_CONTROL_SEC:
										begin
											SETTING = 0;
											OUT_TIME = IN_TIME;
											MODE_BUFF = CURRENT_TIME;
										end
									CURRENT_CONTROL_YEAR:
										begin
											SETTING = 0;
											OUT_TIME = IN_TIME;
											MODE_BUFF = CURRENT_TIME;
										end
									CURRENT_CONTROL_MONTH:
										begin
											SETTING = 0;
											OUT_TIME = IN_TIME;
											MODE_BUFF = CURRENT_TIME;
										end
									CURRENT_CONTROL_DAY:
										begin
											SETTING = 0;
											OUT_TIME = IN_TIME;
											MODE_BUFF = CURRENT_TIME;
										end
									ALARM_TIME:
										begin
											// Alarm ON/OFF...
											if(ALARM_ENABLE == 1) ALARM_ENABLE = 0;
											else ALARM_ENABLE = 1;
										end
									ALARM_CONTROL_HOUR:
										begin
											ALARM_SETTING = 0;
											OUT_ALARM_TIME = 0;
											MODE_BUFF = ALARM_TIME;
										end
									ALARM_CONTROL_MIN:
										begin
											ALARM_SETTING = 0;
											OUT_ALARM_TIME = 0;
											MODE_BUFF = ALARM_TIME;
										end
									ALARM_CONTROL_SEC:
										begin
											ALARM_SETTING = 0;
											OUT_ALARM_TIME = 0;
											MODE_BUFF = ALARM_TIME;
										end
									default:
										begin
											// MERIDIAN change...
											if(MERIDIAN == 0) MERIDIAN = 1;
											else MERIDIAN = 0;
										end
								endcase
								CNT = 0;
							end
						else
							CNT = CNT + 1;
					end
				UP:
					begin
						if(CNT >= 22999)
							begin
								case(MODE)
									CURRENT_TIME:
										begin
											// Nothing Special...
										end
									CURRENT_CONTROL_HOUR:
										begin
											if(OUT_TIME[16:12] >= 5'b10111) // more than 23
												OUT_TIME[16:12] = 5'b00000;
											else
												OUT_TIME[16:12] = OUT_TIME[16:12] + 5'b00001;
										end
									CURRENT_CONTROL_MIN:
										begin
											if(OUT_TIME[11:6] >= 6'b111011) // more than 59
												OUT_TIME[11:6] = 6'b000000;
											else
												OUT_TIME[11:6] = OUT_TIME[11:6] + 6'b000001;
										end
									CURRENT_CONTROL_SEC:
										begin
											if(OUT_TIME[5:0] >= 6'b111011) // more than 59
												OUT_TIME[5:0] = 6'b000000;
											else
												OUT_TIME[5:0] = OUT_TIME[5:0] + 6'b000001;
										end
									CURRENT_CONTROL_YEAR:
										begin
											if(OUT_DATE[15:9] >= 7'b1100011) // more than 99
												OUT_DATE[15:9] = 7'b0000000;
											else
												OUT_DATE[15:9] = OUT_DATE[15:9] + 7'b0000001;
										end
									CURRENT_CONTROL_MONTH:
										begin
											if(OUT_DATE[8:5] >= 4'b1100) // more than 12
												OUT_DATE[8:5] = 4'b0001;
											else
												OUT_DATE[8:5] = OUT_DATE[8:5] + 4'b0001;
										end
									CURRENT_CONTROL_DAY:
										begin
											if(OUT_DATE[4:0] >= 5'b11111) // more than 31
												OUT_DATE[4:0] = 5'b00001;
											else
												OUT_DATE[4:0] = OUT_DATE[4:0] + 5'b00001;
										end
									ALARM_TIME:
										begin
											// Nothing Special...
										end
									ALARM_CONTROL_HOUR:
										begin
											if(OUT_ALARM_TIME[16:12] >= 5'b10111) // more than 23
												OUT_ALARM_TIME[16:12] = 5'b00000;
											else
												OUT_ALARM_TIME[16:12] = OUT_ALARM_TIME[16:12] + 5'b00001;
										end
									ALARM_CONTROL_MIN:
										begin
											if(OUT_ALARM_TIME[11:6] >= 6'b111011) // more than 59
												OUT_ALARM_TIME[11:6] = 6'b000000;
											else
												OUT_ALARM_TIME[11:6] = OUT_ALARM_TIME[11:6] + 6'b000001;
										end
									ALARM_CONTROL_SEC:
										begin
											if(OUT_ALARM_TIME[5:0] >= 6'b111011) // more than 59
												OUT_ALARM_TIME[5:0] = 6'b000000;
											else
												OUT_ALARM_TIME[5:0] = OUT_ALARM_TIME[5:0] + 6'b000001;
										end
									default:
										begin
											// Nothing Special...
										end
								endcase
								CNT = 0;
							end
						else
							CNT = CNT + 1;
					end
				DOWN:
					begin
						if(CNT >= 22999)
							begin
								case(MODE)
									CURRENT_TIME:
										begin
											// Nothing Special...
										end
									CURRENT_CONTROL_HOUR:
										begin
											if(OUT_TIME[16:12] <= 5'b00000) // less than 0
												OUT_TIME[16:12] = 5'b10111;
											else
												OUT_TIME[16:12] = OUT_TIME[16:12] - 5'b00001;
										end
									CURRENT_CONTROL_MIN:
										begin
											if(OUT_TIME[11:6] <= 6'b000000) // less than 0
												OUT_TIME[11:6] = 6'b111011;
											else
												OUT_TIME[11:6] = OUT_TIME[11:6] - 6'b000001;
										end
									CURRENT_CONTROL_SEC:
										begin
											if(OUT_TIME[5:0] <= 6'b000000) // less than 0
												OUT_TIME[5:0] = 6'b111011;
											else
												OUT_TIME[5:0] = OUT_TIME[5:0] - 6'b000001;
										end
									CURRENT_CONTROL_YEAR:
										begin
											if(OUT_DATE[15:9] <= 7'b0000000) // less than 0
												OUT_DATE[15:9] = 7'b1100011;
											else
												OUT_DATE[15:9] = OUT_DATE[15:9] - 7'b0000001;
										end
									CURRENT_CONTROL_MONTH:
										begin
											if(OUT_DATE[8:5] <= 4'b0001) // less than 1
												OUT_DATE[8:5] = 4'b1100;
											else
												OUT_DATE[8:5] = OUT_DATE[8:5] - 4'b0001;
										end
									CURRENT_CONTROL_DAY:
										begin
											if(OUT_DATE[4:0] <= 5'b00001) // less than 1
												OUT_DATE[4:0] = 5'b11111;
											else
												OUT_DATE[4:0] = OUT_DATE[4:0] - 5'b00001;
										end
									ALARM_TIME:
										begin
											// Nothing Special...
										end
									ALARM_CONTROL_HOUR:
										begin
											if(OUT_ALARM_TIME[16:12] <= 5'b00000) // less than 0
												OUT_ALARM_TIME[16:12] = 5'b10111;
											else
												OUT_ALARM_TIME[16:12] = OUT_ALARM_TIME[16:12] - 5'b00001;
										end
									ALARM_CONTROL_MIN:
										begin
											if(OUT_ALARM_TIME[11:6] <= 6'b000000) // less than 0
												OUT_ALARM_TIME[11:6] = 6'b111011;
											else
												OUT_ALARM_TIME[11:6] = OUT_ALARM_TIME[11:6] - 6'b000001;
										end
									ALARM_CONTROL_SEC:
										begin
											if(OUT_ALARM_TIME[5:0] <= 6'b000000) // more than 0
												OUT_ALARM_TIME[5:0] = 6'b111011;
											else
												OUT_ALARM_TIME[5:0] = OUT_ALARM_TIME[5:0] - 6'b000001;
										end
									default:
										begin
											// Nothing Special...
										end
								endcase
								CNT = 0;
							end
						else
							CNT = CNT + 1;
					end
			endcase
		end
end

endmodule
