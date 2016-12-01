
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
	MODE, MODE_STATE, SETTING, ALARM_SETTING, SETTING_OK,
	OUT_TIME, OUT_DATE, OUT_ALARM_TIME
);

input RESETN, CLK;
input [16:0] IN_ALARM_TIME;
input [16:0] IN_TIME;
input [15:0] IN_DATE;
input MODE, MODE_STATE, SETTING, ALARM_SETTING;
output reg [16:0] OUT_ALARM_TIME;
output reg [16:0] OUT_TIME;
output reg [15:0] OUT_DATE;
output reg SETTING_OK;

reg [16:0] SETTING_TIME;
reg [15:0] SETTING_DATE;

// TEMP TIME
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
	else if((SETTING == 1'b1) || (ALARM_SETTING == 1'b1))
		begin
			CNT = 0;
			SETTING_OK = 1;
		end
	else
		begin
			if(CNT >= 99999)
				CNT = 0;
			else
				CNT = CNT + 1;
			SETTING_OK = 0;
		end
end

always @(posedge CLK)
begin
	if(!RESETN)
		begin
			SETTING_TIME = 16'b0000000000000001; // 16'b0000/000000/000001;
			SETTING_DATE = 16'b0010000000100001; // 16'b0010000/0001/00001;
		end
	else
		begin
			if((SETTING == 0) && (ALARM_SETTING == 0))
				begin
					SETTING_TIME = IN_TIME;
					SETTING_DATE = IN_DATE;
				end
		end
end

// Count part
always @(posedge CLK)
begin
	if(!MODE)
		// MODE 0 -> continue stream(time is going)
		begin
			if(!MODE_STATE) 
				// MODE_STATE 0 -> current time
				begin
					OUT_TIME = { HOUR, MIN, SEC };
					OUT_DATE = { YEAR, MONTH, DAY };
				end
			else
				begin
				// MODE_STATE 1 -> alarm time & alarm control time
					OUT_TIME = { HOUR, MIN, SEC };
					OUT_DATE = { YEAR, MONTH, DAY };
					OUT_ALARM_TIME = { IN_ALARM_TIME[16:12], IN_ALARM_TIME[11:6], IN_ALARM_TIME[5:0] };
				end
		end
	else
		// MODE 1 -> stop stream(time is not going)
		begin
			if(!MODE_STATE)
				// MODE_STATE 0 -> current control time
				begin
					OUT_TIME = { SETTING_TIME[16:12], SETTING_TIME[11:6], SETTING_TIME[5:0] };
					OUT_DATE = { SETTING_DATE[15:9], SETTING_DATE[8:5], SETTING_DATE[4:0] };
				end
		end
end

// Second part
always @(posedge CLK)
begin
	if(!RESETN)
		SEC = 0;
		
	else if(SETTING == 1)
		SEC = SETTING_TIME[5:0];
	else
		if(CNT == 99999)
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
	else if(SETTING == 1)
		MIN = SETTING_TIME[11:6];
	else
		if((CNT == 99999) && (SEC == 59))
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
	else if(SETTING == 1)
		HOUR = SETTING_TIME[16:12];
	else
		if((CNT == 99999) && (SEC == 59) && (MIN == 59))
			begin
				if(HOUR >= 23)
					HOUR = 0;
				else
					begin
						HOUR = HOUR + 1;
					end
			end
end

// Day part
always @(posedge CLK)
begin
	if(!RESETN)
		DAY = 1;
	else if(SETTING == 1'b1)
		DAY = SETTING_DATE[4:0];
	else
		if((CNT == 99999) && (HOUR == 23) && (SEC == 59) && (MIN == 59))
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
		MONTH = SETTING_DATE[8:5];
	else
		if((CNT == 99999) && (DAY == 31) && (HOUR == 23) && (SEC == 59) && (MIN == 59))
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
		YEAR = SETTING_DATE[15:9]; 
	else
		if((CNT == 99999) && (MONTH == 12) && (DAY == 31) && (HOUR == 23) && (SEC == 59) && (MIN == 59))
			begin
				if(YEAR >= 99)
					YEAR = 0;
				else
					YEAR = YEAR + 1;
			end
end

endmodule
