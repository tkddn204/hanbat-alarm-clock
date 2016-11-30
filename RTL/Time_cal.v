
/* IN_TIME BIT LIST
`define   IN_MERIDIAN IN_TIME[17]
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

// TIME_CAL.v

module TIME_CAL(
	RESETN, CLK,
	IN_TIME, IN_DATE, IN_ALARM_TIME,
	MODE, MODE_STATE, SETTING, SETTING_OK,
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
output reg SETTING_OK;

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
			SETTING_OK = 0;
		end
	else if(SETTING == 1'b1)
		begin
			CNT = 0;
			SETTING_OK = 1;
		end
	else
		begin
			if(CNT >= 999)
				CNT = 0;
			else
				CNT = CNT + 1;
			SETTING_OK = 0;
		end
end

// Count part
always @(posedge CLK)
begin
	if(!MODE)
		// MODE 0 -> continue stream
		begin
			if(!MODE_STATE) 
				// MODE_STATE 0 -> current time
				begin
					OUT_TIME = { MERIDIAN, HOUR, MIN, SEC };
					OUT_DATE = { YEAR, MONTH, DAY };
				end
		end
	else
		// MODE 1 -> stop stream
		begin
			if(!MODE_STATE) 
				// MODE_STATE 0 -> current time
				begin
					OUT_TIME = { IN_TIME[17], IN_TIME[16:12], IN_TIME[11:6], IN_TIME[5:0] };
					OUT_DATE = { IN_DATE[15:9], IN_DATE[8:5], IN_DATE[4:0] };
				end
			else
				// MODE_STATE 1 -> alarm time
				begin
					OUT_ALARM_TIME = { IN_ALARM_TIME[16:12], IN_ALARM_TIME[11:6], IN_ALARM_TIME[5:0] };
				end
		end
end

// Second part
always @(posedge CLK)
begin
	if(!RESETN)
		SEC = 0;
	else if(SETTING == 1'b1)
		SEC = IN_TIME[5:0];
	else
		if(CNT == 999)
			begin
				if(SEC >= 59)
					SEC = 0;
				else
					SEC = SEC + 1;
			end
end

// Minute part
always @(posedge CLK)
begin
	if(!RESETN)
		MIN = 0;
	else if(SETTING == 1'b1)
		MIN = IN_TIME[11:6];
	else
		if((CNT == 999) && (SEC == 59))
			begin
				if(MIN >= 59)
					MIN = 0;
				else
					MIN = MIN + 1;
			end
end

// Hour part
always @(posedge CLK)
begin
	if(!RESETN)
		HOUR = 0;
	else if(SETTING == 1'b1)
		HOUR = IN_TIME[16:12];
	else
		if((CNT == 999) && (SEC == 59) && (MIN == 59))
			begin
				if(HOUR >= 23)
					HOUR = 0;
				else
					begin
						HOUR = HOUR + 1;
					end
			end
end

// Meridian part
always @(posedge CLK)
begin
	if(!RESETN)
		MERIDIAN = 0;
	else if(SETTING == 1'b1)
		MERIDIAN = IN_TIME[17];
end


// Day part
always @(posedge CLK)
begin
	if(!RESETN)
		DAY = 1;
	else if(SETTING == 1'b1)
		DAY = IN_DATE[4:0];
	else
		if((CNT == 999) && (HOUR == 23) && (SEC == 59) && (MIN == 59))
			begin
				if(DAY >= 31)
					DAY = 1;
				else
					DAY = DAY + 1;
			end
end

// Month part
always @(posedge CLK)
begin
	if(!RESETN)
		MONTH = 1;
	else if(SETTING == 1'b1)
		MONTH = IN_DATE[8:5];
	else
		if((CNT == 999) && (DAY == 31) && (HOUR == 23) && (SEC == 59) && (MIN == 59))
			begin
				if(MONTH >= 31)
					MONTH = 1;
				else
					MONTH = MONTH + 1;
			end
end

// Year part
always @(posedge CLK)
begin
	if(!RESETN)
		YEAR = 16;
	else if(SETTING == 1'b1)
		YEAR = IN_DATE[15:9]; 
	else
		if((CNT == 999) && (MONTH == 12) && (DAY == 31) && (HOUR == 23) && (SEC == 59) && (MIN == 59))
			begin
				if(YEAR >= 99)
					YEAR = 0;
				else
					YEAR = YEAR + 1;
			end
end

endmodule
