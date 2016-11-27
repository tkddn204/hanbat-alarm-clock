
/* IN_TIME BIT LIST
`define   IN_MERIDIAN IN_TIME[16]
`define	 IN_HOUR     IN_TIME[15:12]
`define	 IN_MIN      IN_TIME[11:6]
`define   IN_SEC      IN_TIME[5:0]

/* ALARM_TIME BIT LIST
`define	 ALARM_HOUR  ALARM_TIME[15:12]
`define	 ALARM_MIN   ALARM_TIME[11:6]
`define	 ALARM_SEC   ALARM_TIME[5:0]
*/

// TIME_CAL.v

module TIME_CAL(
	RESETN, CLK,
	IN_TIME, IN_DATE, ALARM_TIME,
	IS_SAVED_TIME, FLAG,
	OUT_TIME, OUT_DATE
);

input RESETN, CLK;
input [16:0] IN_TIME;
input [16:0] IN_DATE;
input [16:0] ALARM_TIME;
input IS_SAVED_TIME;
input [2:0] FLAG;
output wire [16:0] OUT_TIME;
output wire [16:0] OUT_DATE;

// 1+4+6+6+7+5+5 = 17+17 = 34bit
reg MERIDIAN;
reg [3:0] HOUR;
reg [5:0] MIN, SEC;
reg [6:0] YEAR;
reg [4:0] MONTH, DAY;

/* FLAG */
parameter FLAG_NO = 3'b000,
			 FLAG_VIEW_ALARM = 3'b001;
			 
integer CNT;

// Temp Year, Month part
initial begin
	YEAR = 16;
	MONTH = 12;
	DAY = 02;
end

// Count part
always @(posedge CLK)
begin
	if(~RESETN)
		CNT = 0;
	else
		begin
			if(CNT >= 99)
				CNT = 0;
			else
				CNT = CNT + 1;
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
