






// Time_cal.v

module Time_cal(
	RESETN, CLK,
	out_H10, out_H1, out_M10, out_M1, out_S10, out_S1
);

input RESETN, CLK;
output wire [7:0] out_H10, out_H1, out_M10, out_M1, out_S10, out_S1;

integer CNT;

wire [3:0] H10, H1, M10, M1, S10, S1;

reg [6:0] HOUR, MIN, SEC;

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
					if(HOUR >= 23)
						HOUR = 0;
					else
						HOUR = HOUR + 1;
				end
		end
end

// x, y, z => input x, output y, z
WT_SEP S_SEP(SEC, S10, S1);
WT_SEP M_SEP(MIN, M10, M1);
WT_SEP H_SEP(HOUR, H10, H1);

// decode x to y
WT_DECODER H10_DECODE(H10, out_H10);
WT_DECODER H1_DECODE(H1, out_H1);
WT_DECODER M10_DECODE(M10, out_M10);
WT_DECODER M1_DECODE(M1, out_M1);
WT_DECODER S10_DECODE(S10, out_S10);
WT_DECODER S1_DECODE(S1, out_S1);

endmodule
