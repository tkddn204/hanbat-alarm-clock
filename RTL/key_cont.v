
/* IN_TIME BIT LIST
`define   IN_MERIDIAN IN_TIME[17]
`define	 IN_HOUR     IN_TIME[16:12]
`define	 IN_MIN      IN_TIME[11:6]
`define   IN_SEC      IN_TIME[5:0]

/* IN_DATE BIT LIST
`define   IN_YEAR     IN_DATE[15:9]
`define	 IN_MONTH    IN_DATE[8:5]
`define	 IN_DAY      IN_DATE[4:0]
*/

/* IN_ALARM_TIME BIT LIST
`define	 IN_HOUR     IN_TIME[16:12]
`define	 IN_MIN      IN_TIME[11:6]
`define   IN_SEC      IN_TIME[5:0]
*/

// KEY_CONT.v

module KEY_CONT(
	RESETN, CLK,
	KEY, IN_TIME, IN_DATE, IN_ALARM_TIME,
	MODE, ALARM_ENABLE, SETTING,
	OUT_TIME, OUT_DATE, OUT_ALARM_TIME
);

input RESETN, CLK;
input [4:0] KEY;
input [16:0] IN_ALARM_TIME;
input [17:0] IN_TIME;
input [15:0] IN_DATE;
output wire [16:0] OUT_ALARM_TIME;
output wire [17:0] OUT_TIME;
output wire [15:0] OUT_DATE;
output reg [5:0] MODE;
output reg ALARM_ENABLE, SETTING;

reg [16:0] OUT_ALARM_TIME_BUFF;
reg [17:0] OUT_TIME_BUFF;
reg [15:0] OUT_DATE_BUFF;
reg [5:0] MODE_BUFF;
reg NO_MORE_WAIT;

/* KEY LIST */
parameter MENU = 8'b10000,
			 SET = 8'b01000,
			 CANCEL = 8'b00100,
			 UP = 8'b00010,
			 DOWN= 8'b00001;
			 
/* MODE
  100000    -> Current(0), Alarm(1) Control TIME Bit
  10000     -> No(0), Controlling(1) Time Bit
  1000 ~ 10 -> Control Bit
  1         -> Counting Continue(0), Stop(1) Bit
*/
parameter CURRENT_TIME = 6'b000000,
			 CURRENT_CONTROL_TIME = 6'b010000,
			 CURRENT_CONTROL_HOUR = 6'b010011,
			 CURRENT_CONTROL_MIN = 6'b010101,
			 CURRENT_CONTROL_SEC = 6'b010111,
			 CURRENT_CONTROL_MERIDIAN = 6'b011001,
			 CURRENT_CONTROL_YEAR = 6'b011011,
			 CURRENT_CONTROL_MONTH = 6'b011101,
			 CURRENT_CONTROL_DAY = 6'b011111,
			 ALARM_TIME = 6'b100001,
			 ALARM_CONTROL_TIME = 6'b110001,
			 ALARM_CONTROL_HOUR = 6'b110011,
			 ALARM_CONTROL_MIN = 6'b110101,
			 ALARM_CONTROL_SEC = 6'b110111;
			 
integer CNT, CNT_WAIT;

always @(posedge CLK)
begin
	if(!RESETN)
		CNT = 0;
	else if(KEY)
		begin
			if (CNT >= 99)
				CNT = 0;
			else
				CNT = CNT + 1;
		end
	else
		CNT = 0;
end

// wait button input for 10 sec...
always @(posedge CLK)
begin
	if(!RESETN || KEY)
		begin
			CNT_WAIT = 0;
			NO_MORE_WAIT = 0;
		end
	else
		begin
			if (CNT_WAIT >= 999)
				begin
					CNT_WAIT = 0;
					NO_MORE_WAIT = 1;
				end
			else
				CNT_WAIT = CNT_WAIT + 1;
		end
end

always @(posedge CLK)
begin
	if(!RESETN)
		begin
			MODE_BUFF = CURRENT_TIME;
		end
	else
		MODE = MODE_BUFF;
end

always @(posedge CLK)
begin
	if(~RESETN)
		begin
			OUT_ALARM_TIME_BUFF = 0;
			OUT_TIME_BUFF = 0;
			OUT_DATE_BUFF = 0;
			ALARM_ENABLE = 0;
			SETTING = 0;
		end
	else
		begin
			case(KEY)
				MENU:
					begin
						case(MODE)
							CURRENT_TIME:
								begin
									MODE_BUFF = CURRENT_CONTROL_TIME;
								end
							CURRENT_CONTROL_TIME:
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
									if(OUT_TIME_BUFF[17] == 0)
										MODE_BUFF = CURRENT_CONTROL_MERIDIAN;
									else
										MODE_BUFF = CURRENT_CONTROL_YEAR;
								end
							CURRENT_CONTROL_MERIDIAN:
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
									MODE_BUFF = ALARM_CONTROL_TIME;
								end
							ALARM_CONTROL_TIME:
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
						endcase
					end
				SET:
					begin
						case(MODE)
							CURRENT_TIME:
								begin
									// Show Alarm Time for 3 seconds...
									// Not operate
								end
							CURRENT_CONTROL_TIME:
								begin
									OUT_TIME_BUFF = IN_TIME;
									OUT_DATE_BUFF = IN_DATE;
									MODE_BUFF = CURRENT_CONTROL_HOUR;
								end
							CURRENT_CONTROL_HOUR:
								begin
									SETTING = 1;
									MODE_BUFF = CURRENT_CONTROL_TIME;
								end
							CURRENT_CONTROL_MIN:
								begin
									SETTING = 1;
									MODE_BUFF = CURRENT_CONTROL_TIME;
								end
							CURRENT_CONTROL_SEC:
								begin
									SETTING = 1;
									MODE_BUFF = CURRENT_CONTROL_TIME;
								end
							CURRENT_CONTROL_MERIDIAN:
								begin
									SETTING = 1;
									MODE_BUFF = CURRENT_CONTROL_TIME;
								end
							CURRENT_CONTROL_YEAR:
								begin
									SETTING = 1;
									MODE_BUFF = CURRENT_CONTROL_TIME;
								end
							CURRENT_CONTROL_MONTH:
								begin
									SETTING = 1;
									MODE_BUFF = CURRENT_CONTROL_TIME;
								end
							CURRENT_CONTROL_DAY:
								begin
									SETTING = 1;
									MODE_BUFF = CURRENT_CONTROL_TIME;
								end
							ALARM_TIME:
								begin
									// Show Current Time for 3 seconds...
									// Not operate
								end
							ALARM_CONTROL_TIME:
								begin
									OUT_ALARM_TIME_BUFF = IN_ALARM_TIME;
									MODE_BUFF = ALARM_CONTROL_HOUR;
								end
							ALARM_CONTROL_HOUR:
								begin
									SETTING = 1;
									MODE_BUFF = ALARM_CONTROL_TIME;
								end
							ALARM_CONTROL_MIN:
								begin
									SETTING = 1;
									MODE_BUFF = ALARM_CONTROL_TIME;
								end
							ALARM_CONTROL_SEC:
								begin
									SETTING = 1;
									MODE_BUFF = ALARM_CONTROL_TIME;
								end
						endcase
					end
				CANCEL:
					begin
						case(MODE)
							CURRENT_TIME:
								begin
									// MERIDIAN change...
									OUT_TIME_BUFF[17] = (OUT_TIME_BUFF[17] == 0) ? 1 : 0;
								end
							CURRENT_CONTROL_TIME:
								begin
									// MERIDIAN change...
									OUT_TIME_BUFF[17] = (OUT_TIME_BUFF[17] == 0) ? 1 : 0;
								end
							CURRENT_CONTROL_HOUR:
								begin
									SETTING = 0;
									OUT_TIME_BUFF = IN_TIME;
								end
							CURRENT_CONTROL_MIN:
								begin
									SETTING = 0;
									OUT_TIME_BUFF = IN_TIME;
								end
							CURRENT_CONTROL_SEC:
								begin
									SETTING = 0;
									OUT_TIME_BUFF = IN_TIME;
								end
							CURRENT_CONTROL_MERIDIAN:
								begin
									SETTING = 0;
									OUT_TIME_BUFF = IN_TIME;
								end
							CURRENT_CONTROL_YEAR:
								begin
									SETTING = 0;
									OUT_TIME_BUFF = IN_TIME;
								end
							CURRENT_CONTROL_MONTH:
								begin
									SETTING = 0;
									OUT_TIME_BUFF = IN_TIME;
								end
							CURRENT_CONTROL_DAY:
								begin
									SETTING = 0;
									OUT_TIME_BUFF = IN_TIME;
								end
							ALARM_TIME:
								begin
									// Alarm ON/OFF...
									if(ALARM_ENABLE == 1)
										ALARM_ENABLE = 0;
								end
							ALARM_CONTROL_TIME:
								begin
									// Alarm Cancel...
									ALARM_ENABLE = 0;
								end
							ALARM_CONTROL_HOUR:
								begin
									SETTING = 0;
									OUT_ALARM_TIME_BUFF = IN_ALARM_TIME;
								end
							ALARM_CONTROL_MIN:
								begin
									SETTING = 0;
									OUT_ALARM_TIME_BUFF = IN_ALARM_TIME;
								end
							ALARM_CONTROL_SEC:
								begin
									SETTING = 0;
									OUT_ALARM_TIME_BUFF = IN_ALARM_TIME;
								end
						endcase
					end
				UP:
					begin
						case(MODE)
							CURRENT_TIME:
								begin
									// Nothing Special...
								end
							CURRENT_CONTROL_TIME:
								begin
									// Nothing Special...
								end
							CURRENT_CONTROL_HOUR:
								begin
									if(OUT_TIME_BUFF[16:12] >= 5'b10111) // more than 23
										OUT_TIME_BUFF[16:12] = 5'b00000;
									else
										OUT_TIME_BUFF[16:12] = OUT_TIME_BUFF[16:12] + 5'b00001;
								end
							CURRENT_CONTROL_MIN:
								begin
									if(OUT_TIME_BUFF[11:6] >= 6'b111011) // more than 59
										OUT_TIME_BUFF[11:6] = 6'b000000;
									else
										OUT_TIME_BUFF[11:6] = OUT_TIME_BUFF[11:6] + 6'b000001;
								end
							CURRENT_CONTROL_SEC:
								begin
									if(OUT_TIME_BUFF[5:0] >= 6'b111011) // more than 59
										OUT_TIME_BUFF[5:0] = 6'b000000;
									else
										OUT_TIME_BUFF[5:0] = OUT_TIME_BUFF[5:0] + 6'b000001;
								end
							CURRENT_CONTROL_MERIDIAN:
								begin
									// Nothing Special...
								end
							CURRENT_CONTROL_YEAR:
								begin
									if(OUT_DATE_BUFF[15:9] >= 7'b1100011) // more than 99
										OUT_DATE_BUFF[15:9] = 7'b0000000;
									else
										OUT_DATE_BUFF[15:9] = OUT_DATE_BUFF[15:9] + 7'b0000001;
								end
							CURRENT_CONTROL_MONTH:
								begin
									if(OUT_DATE_BUFF[8:5] >= 4'b1100) // more than 12
										OUT_DATE_BUFF[8:5] = 4'b0001;
									else
										OUT_DATE_BUFF[8:5] = OUT_DATE_BUFF[8:5] + 4'b0001;
								end
							CURRENT_CONTROL_DAY:
								begin
									if(OUT_DATE_BUFF[4:0] >= 5'b11111) // more than 31
										OUT_DATE_BUFF[4:0] = 5'b00001;
									else
										OUT_DATE_BUFF[4:0] = OUT_DATE_BUFF[4:0] + 5'b00001;
								end
							ALARM_TIME:
								begin
									// Nothing Special...
									// PLAN : MORE ALARM DATA?
								end
							ALARM_CONTROL_TIME:
								begin
									// Nothing Special...
									// PLAN : MORE ALARM DATA?
								end
							ALARM_CONTROL_HOUR:
								begin
									if(OUT_ALARM_TIME_BUFF[16:12] >= 5'b10111) // more than 23
										OUT_ALARM_TIME_BUFF[16:12] = 5'b00000;
									else
										OUT_ALARM_TIME_BUFF[16:12] = OUT_ALARM_TIME_BUFF[16:12] + 5'b00001;
								end
							ALARM_CONTROL_MIN:
								begin
									if(OUT_ALARM_TIME_BUFF[11:6] >= 6'b111011) // more than 59
										OUT_ALARM_TIME_BUFF[11:6] = 6'b000000;
									else
										OUT_ALARM_TIME_BUFF[11:6] = OUT_ALARM_TIME_BUFF[11:6] + 6'b000001;
								end
							ALARM_CONTROL_SEC:
								begin
									if(OUT_ALARM_TIME_BUFF[5:0] >= 6'b111011) // more than 59
										OUT_ALARM_TIME_BUFF[5:0] = 6'b000000;
									else
										OUT_ALARM_TIME_BUFF[5:0] = OUT_ALARM_TIME_BUFF[5:0] + 6'b000001;
								end
						endcase
					end
				DOWN:
					begin
						case(MODE)
							CURRENT_TIME:
								begin
									// Nothing Special...
								end
							CURRENT_CONTROL_TIME:
								begin
									// Nothing Special...
								end
							CURRENT_CONTROL_HOUR:
								begin
									if(OUT_TIME_BUFF[16:12] <= 5'b00000) // less than 0
										OUT_TIME_BUFF[16:12] = 5'b10111;
									else
										OUT_TIME_BUFF[16:12] = OUT_TIME_BUFF[16:12] - 5'b00001;
								end
							CURRENT_CONTROL_MIN:
								begin
									if(OUT_TIME_BUFF[11:6] <= 6'b000000) // less than 0
										OUT_TIME_BUFF[11:6] = 6'b111011;
									else
										OUT_TIME_BUFF[11:6] = OUT_TIME_BUFF[11:6] - 6'b000001;
								end
							CURRENT_CONTROL_SEC:
								begin
									if(OUT_TIME_BUFF[5:0] <= 6'b000000) // less than 0
										OUT_TIME_BUFF[5:0] = 6'b111011;
									else
										OUT_TIME_BUFF[5:0] = OUT_TIME_BUFF[5:0] - 6'b000001;
								end
							CURRENT_CONTROL_MERIDIAN:
								begin
									// Nothing Special...
								end
							CURRENT_CONTROL_YEAR:
								begin
									if(OUT_DATE_BUFF[15:9] <= 7'b0000000) // less than 0
										OUT_DATE_BUFF[15:9] = 7'b1100011;
									else
										OUT_DATE_BUFF[15:9] = OUT_DATE_BUFF[15:9] - 7'b0000001;
								end
							CURRENT_CONTROL_MONTH:
								begin
									if(OUT_DATE_BUFF[8:5] <= 4'b0001) // less than 1
										OUT_DATE_BUFF[8:5] = 4'b1100;
									else
										OUT_DATE_BUFF[8:5] = OUT_DATE_BUFF[8:5] - 4'b0001;
								end
							CURRENT_CONTROL_DAY:
								begin
									if(OUT_DATE_BUFF[4:0] <= 5'b00001) // less than 1
										OUT_DATE_BUFF[4:0] = 5'b11111;
									else
										OUT_DATE_BUFF[4:0] = OUT_DATE_BUFF[4:0] - 5'b00001;
								end
							ALARM_TIME:
								begin
									// Nothing Special...
									// PLAN : MORE ALARM DATA?
								end
							ALARM_CONTROL_TIME:
								begin
									// Nothing Special...
									// PLAN : MORE ALARM DATA?
								end
							ALARM_CONTROL_HOUR:
								begin
									if(OUT_ALARM_TIME_BUFF[16:12] <= 5'b00000) // less than 0
										OUT_ALARM_TIME_BUFF[16:12] = 5'b10111;
									else
										OUT_ALARM_TIME_BUFF[16:12] = OUT_ALARM_TIME_BUFF[16:12] - 5'b00001;
								end
							ALARM_CONTROL_MIN:
								begin
									if(OUT_ALARM_TIME_BUFF[11:6] <= 6'b000000) // less than 0
										OUT_ALARM_TIME_BUFF[11:6] = 6'b111011;
									else
										OUT_ALARM_TIME_BUFF[11:6] = OUT_ALARM_TIME_BUFF[11:6] - 6'b000001;
								end
							ALARM_CONTROL_SEC:
								begin
									if(OUT_ALARM_TIME_BUFF[5:0] <= 6'b000000) // more than 0
										OUT_ALARM_TIME_BUFF[5:0] = 6'b111011;
									else
										OUT_ALARM_TIME_BUFF[5:0] = OUT_ALARM_TIME_BUFF[5:0] - 6'b000001;
								end
						endcase
					end
			endcase
		end
end

assign OUT_ALARM_TIME = OUT_ALARM_TIME_BUFF;
assign OUT_TIME = OUT_TIME_BUFF;
assign OUT_DATE = OUT_DATE_BUFF;

endmodule
