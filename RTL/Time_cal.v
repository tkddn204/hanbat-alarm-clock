
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

// TIME_CAL.v

module TIME_CAL(
	RESETN, CLK,
	IN_TIME, IN_DATE, IN_ALARM_TIME,
	MODE, MODE_STATE, SETTING,
	OUT_TIME, OUT_DATE, OUT_ALARM_TIME
);

input RESETN, CLK;
input [16:0] IN_ALARM_TIME;
input [17:0] IN_TIME;
input [15:0] IN_DATE;
input MODE, MODE_STATE, SETTING;
output reg [16:0] OUT_ALARM_TIME;
output reg [17:0] OUT_TIME;
output reg [15:0] OUT_DATE;

// TEMP TIME
reg MERIDIAN;
reg [4:0] HOUR;
reg [5:0] MIN, SEC;

// TEMP DATE
reg [6:0] YEAR;
reg [3:0] MONTH;
reg [4:0] DAY;

integer CNT;

always @(posedge CLK)
begin
	if(!RESETN)
		begin
			CNT = 0;
			MERIDIAN = 0; HOUR = 0; MIN = 0; SEC = 0;
			YEAR = 0; MONTH = 0; DAY = 0;
		end
	else if(SETTING)
		CNT = 0;
	else
		if(CNT >= 99)
			CNT = 0;
		else
			CNT = CNT + 1;
end

// Count part
always @(posedge CLK)
begin
	if(!MODE) // MODE 0 -> continue stream
		begin
			if(!MODE_STATE) // MODE_STATE 0 -> current time
				begin
					OUT_TIME = { MERIDIAN, HOUR, MIN, SEC };
					OUT_DATE = { YEAR, MONTH, DAY };
				end
			else				 // MODE_STATE 1 -> alarm time
				begin
					OUT_ALARM_TIME = { HOUR, MIN, SEC, YEAR };
				end
		end
	else		 // MODE 1 -> stop stream
		begin
			if(!MODE_STATE) // MODE_STATE 0 -> current time
				begin
					MERIDIAN = IN_TIME[17]; HOUR = IN_TIME[16:12];
					MIN = IN_TIME[11:6]; SEC = IN_TIME[5:0];
					YEAR = IN_DATE[15:9]; MONTH = IN_DATE[8:5];
					DAY = IN_DATE[4:0];
				end
			else				 // MODE_STATE 1 -> alarm time
				begin
					HOUR = IN_ALARM_TIME[16:12]; MIN = IN_ALARM_TIME[11:6];
					SEC = IN_ALARM_TIME[5:0];
				end
		end
end

// Hour part
always @(posedge CLK)
begin
	if(~RESETN)
		HOUR = 0;
	else
		begin
			if((CNT == 99) && (SEC == 59) && (MIN == 59))
				begin
					if(HOUR >= 23)
						HOUR = 0;
					else
						if(FLAG == FLAG_NO)
							HOUR = HOUR + 1;
				end
			else if(FLAG == FLAG_VIEW_ALARM)
				HOUR = ALARM_TIME[15:12];
			else if(IS_SAVED_TIME)
				HOUR = IN_TIME[15:12];
		end
end

// Minute part
always @(posedge CLK)
begin
	if(~RESETN)
		MIN = 0;
	else
		begin
			if((CNT == 99) && (SEC == 59))
				begin
					if(MIN >= 59)
						MIN = 0;
					else
						if(FLAG == FLAG_NO)
							MIN = MIN + 1;
				end
			else if(FLAG == FLAG_VIEW_ALARM)
				MIN = ALARM_TIME[11:6];
			else if(IS_SAVED_TIME)
				MIN = IN_TIME[11:6];
		end
end

// Second part
always @(posedge CLK)
begin
		if(~RESETN)
			SEC = 0;
		else
			begin
				if(CNT == 99)
					begin
						if(SEC >= 59)
							SEC = 0;
						else
							if(FLAG == FLAG_NO)
								SEC = SEC + 1;
					end
				else if(FLAG == FLAG_VIEW_ALARM)
					SEC = ALARM_TIME[5:0];
				else if(IS_SAVED_TIME)
					SEC = IN_TIME[5:0];
			end
end

assign OUT_TIME = { MERIDIAN, HOUR, MIN, SEC };
assign OUT_DATE = { YEAR, MONTH, DAY };

endmodule
