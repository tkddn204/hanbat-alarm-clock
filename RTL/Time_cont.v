

module Time_cont(
	RESETN, CLK,
	TIME_FORMAT, MERIDIAN, FLAG, UP, DOWN,
	H10, H1, M10, M1, S10, S1, out_MERIDIAN,
	Y10, Y1, MT10, MT1, D10, D1,
);

input RESETN, CLK;
input TIME_FORMAT;
input [2:0] FLAG;
input [2:0] UP, DOWN;
input [7:0] MERIDIAN;
output wire [7:0] H10, H1, M10, M1, S10, S1;
output wire [7:0] Y10, Y1, MT10, MT1, D10, D1;
output wire [7:0] out_MERIDIAN;

integer CNT;
			 
/* FLAG */
parameter FLAG_NO = 3'b000,
			 FLAG_VIEW_ALARM = 3'b001,
			 FLAG_CONTROL_STATE = 3'b100,
			 FLAG_CONTROL_CHANGE_CANCEL_STATE = 3'b101;

/* CURRENT BLINK LIST */
parameter BLINK_NO = 3'b000,
			 BLINK_HOUR = 3'b001,
			 BLINK_MIN = 3'b010,
			 BLINK_SEC = 3'b011,
			 BLINK_MERIDIAN = 3'b100,
			 BLINK_YEAR = 3'b101,
			 BLINK_MONTH = 3'b110,
			 BLINK_DAY = 3'b111;
			 
parameter UP_NO = 3'b000,
			 DOWN_NO = 3'b000;
			 
reg [6:0] HOUR, MIN, SEC;
reg [6:0] YEAR, MONTH, DAY;
reg MERIDIAN_BUFF;

parameter AM = 8'b01000001,
			 PM = 8'b01000010;

/* TIME FORMAT LIST */
parameter FORMAT_24 = 0,
			 FORMAT_12 = 1;

initial begin
MERIDIAN_BUFF = 0;

end

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

// TODO change one always and case

// Hour part
always @(posedge CLK or negedge RESETN)
begin
		if(~RESETN)
			HOUR = 0;
		else
			begin
				if(UP == BLINK_MIN)
					begin
						if(TIME_FORMAT == FORMAT_12)
							if(HOUR >= 11)
								begin
									HOUR = 0;
									if(MERIDIAN == AM)
										MERIDIAN_BUFF = PM;
									else
										MERIDIAN_BUFF = AM;
								end
							else
								HOUR = HOUR + 1;
						else
							if(HOUR >= 23)
								HOUR = 0;
							else
								HOUR = HOUR + 1;
					end
				else if(DOWN == BLINK_MIN)
					begin
						if(TIME_FORMAT == FORMAT_12)
							if(HOUR <= 0)
								begin
									HOUR = 12;
									if(MERIDIAN == AM)
										MERIDIAN_BUFF = PM;
									else
										MERIDIAN_BUFF = AM;
								end
							else
								HOUR = HOUR - 1;
						else
							if(HOUR <= 0)
								HOUR = 23;
							else
								HOUR = HOUR - 1;
					end
			end
end

// Min part
always @(posedge CLK or negedge RESETN)
begin
		if(~RESETN)
			MIN = 0;
		else
			begin
				if(UP == BLINK_MIN)
					begin
						if(MIN >= 59)
							MIN = 0;
						else
							MIN = MIN + 1;
					end
				else if(DOWN == BLINK_MIN)
					begin
						if(MIN <= 0)
							MIN = 59;
						else
							MIN = MIN - 1;
					end
			end
end

// Second part
always @(posedge CLK or negedge RESETN)
begin
		if(~RESETN)
			SEC = 0;
		else
			begin
				if(UP == BLINK_MIN)
					begin
						if(SEC >= 59)
							SEC = 0;
						else
							SEC = SEC + 1;
					end
				else if(DOWN == BLINK_MIN)
					begin
						if(SEC <= 0)
							SEC = 59;
						else
							SEC = SEC - 1;
					end
			end
end

// Meridian part
always @(posedge CLK or negedge RESETN)
begin
		if(~RESETN)
			MERIDIAN_BUFF = 0;
		else
			begin
				if(UP == BLINK_MERIDIAN)
					begin
						if(MERIDIAN_BUFF == 0)
							MERIDIAN_BUFF = 1;
						else
							MERIDIAN_BUFF = 0;
					end
				else if(DOWN == BLINK_MERIDIAN)
					begin
						if(MERIDIAN_BUFF == 0)
							MERIDIAN_BUFF = 1;
						else
							MERIDIAN_BUFF = 0;
					end
			end
end

// Year part
always @(posedge CLK or negedge RESETN)
begin
		if(~RESETN)
			YEAR = 0;
		else
			begin
				if(UP == BLINK_MIN)
					begin
						if(YEAR >= 99)
							YEAR = 0;
						else
							YEAR = YEAR + 1;
					end
				else if(DOWN == BLINK_MIN)
					begin
						if(YEAR <= 0)
							YEAR = 99;
						else
							YEAR = YEAR - 1;
					end
			end
end

// Month part
always @(posedge CLK or negedge RESETN)
begin
		if(~RESETN)
			MONTH = 1;
		else
			begin
				if(UP == BLINK_MIN)
					begin
					if(MONTH >= 12)
						MONTH = 1;
					else
						MONTH = MONTH + 1;
					end
				else if(DOWN == BLINK_MIN)
					begin
						if(MONTH <= 1)
							MONTH = 12;
						else
							MONTH = MONTH - 1;
					end
			end
end

// Day part
always @(posedge CLK or negedge RESETN)
begin
		if(~RESETN)
			DAY = 0;
		else
			begin
				if(UP == BLINK_MIN)
					begin
						if(DAY >= 31)
							DAY = 1;
						else
							DAY = DAY + 1;
					end
				else if(DOWN == BLINK_MIN)
					begin
						if(DAY <= 1)
							DAY = 31;
						else
							DAY = DAY - 1;
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

// TODO MERIDIAN_BUFF 0, 1 변환해줘야함
assign out_MERIDIAN = MERIDIAN_BUFF;

endmodule
