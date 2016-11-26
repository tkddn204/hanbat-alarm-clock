






// Time_cal.v

module Time_cal(
	RESETN, CLK,
	TIME_FORMAT, MERIDIAN, FLAG,
	out_H10, out_H1, out_M10, out_M1, out_S10, out_S1, out_MERIDIAN,
	out_Y10, out_Y1, out_MT10, out_MT1, out_D10, out_D1,
);

input RESETN, CLK;
input TIME_FORMAT;
input [7:0] MERIDIAN;
input [2:0] FLAG;
output wire [7:0] out_H10, out_H1, out_M10, out_M1, out_S10, out_S1;
output wire [7:0] out_Y10, out_Y1, out_MT10, out_MT1, out_D10, out_D1;
output reg [7:0] out_MERIDIAN;

/* FLAG */
parameter FLAG_NO = 3'b000,
			 FLAG_VIEW_ALARM = 3'b001,
			 FLAG_CONTROL_STATE = 3'b100,
			 FLAG_CONTROL_CHANGE_CANCEL_STATE = 3'b101;

wire [3:0] H10, H1, M10, M1, S10, S1;
wire [3:0] Y10, Y1, MT10, MT1, D10, D1;

reg [6:0] HOUR, MIN, SEC;
reg [6:0] YEAR, MONTH, DAY;

/* MERIDIAN LIST(A, B) */
parameter AM = 8'b01000001,
			 PM = 8'b01000010;

integer CNT;

// Temp Year, Month part
initial begin
	YEAR = 16;
	MONTH = 11;
	out_MERIDIAN = AM;
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
							if((FLAG == FLAG_NO) || (FLAG == FLAG_VIEW_ALARM))
								SEC = SEC + 1;
					end
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
						if((FLAG == FLAG_NO) || (FLAG == FLAG_VIEW_ALARM))
							MIN = MIN + 1;
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
					if(TIME_FORMAT == 0)
						begin
							if(HOUR >= 23)
								HOUR = 0;
							else
								if((FLAG == FLAG_NO) || (FLAG == FLAG_VIEW_ALARM))
									HOUR = HOUR + 1;
						end
					else
						begin
							if(HOUR >= 11)
								begin
									HOUR = 0;
									if(MERIDIAN == AM)
										out_MERIDIAN = PM;
									else
										out_MERIDIAN = AM;
								end
							else
								if((FLAG == FLAG_NO) || (FLAG == FLAG_VIEW_ALARM))
									HOUR = HOUR + 1;
						end
				end
		end
end


// Day part
always @(posedge CLK)
begin
	if(~RESETN)
		DAY = 0;
	else
		begin
			if(TIME_FORMAT == 0)
				begin
					if((CNT == 99) &&(HOUR == 23) && (SEC == 59) && (MIN == 59))
						begin
							if(DAY >= 30)
								DAY = 0;
							else
								if((FLAG == FLAG_NO) || (FLAG == FLAG_VIEW_ALARM))
									DAY = DAY + 1;
						end
				end
			else
				begin
					if((CNT == 99) && (HOUR == 11) && (SEC == 59) && (MIN == 59))
						if(MERIDIAN == PM)
							begin
								if(DAY >= 30)
									DAY = 0;
								else
									if((FLAG == FLAG_NO) || (FLAG == FLAG_VIEW_ALARM))
										DAY = DAY + 1;
							end
				end
		end	
end

// x, y, z => input x, output y, z
WT_SEP SECOND_SEP(SEC, S10, S1);
WT_SEP MIN_SEP(MIN, M10, M1);
WT_SEP HOUR_SEP(HOUR, H10, H1);

WT_SEP YEAR_SEP(YEAR, Y10, Y1);
WT_SEP MONTH_SEP(MONTH, MT10, MT1);
WT_SEP DAY_SEP(DAY, D10, D1);


// decode x to y
WT_DECODER H10_DECODE(H10, out_H10);
WT_DECODER H1_DECODE(H1, out_H1);
WT_DECODER M10_DECODE(M10, out_M10);
WT_DECODER M1_DECODE(M1, out_M1);
WT_DECODER S10_DECODE(S10, out_S10);
WT_DECODER S1_DECODE(S1, out_S1);

WT_DECODER Y10_DECODE(Y10, out_Y10);
WT_DECODER Y1_DECODE(Y1, out_Y1);
WT_DECODER MT10_DECODE(D10, out_MT10);
WT_DECODER MT1_DECODE(D1, out_MT1);
WT_DECODER D10_DECODE(D10, out_D10);
WT_DECODER D1_DECODE(D1, out_D1);

endmodule
