module TIME_COMPARE(
	RESETN, CLK,
	ALARM_ENABLE, CURRENT_TIME, ALARM_TIME,
	ALARM_DOING
);

input RESETN, CLK;
input ALARM_ENABLE;
input [16:0] CURRENT_TIME, ALARM_TIME;
output wire ALARM_DOING;

reg DOING, STOP;

integer CNT;

always @(posedge CLK)
begin
	if(!RESETN)
		begin
			CNT = 0;
			STOP = 1'b0;
		end
	else
		if(DOING == 1'b1)
			begin
				if(CNT == 99999 * 60)
					begin
						STOP = 1'b1;
						CNT = 0;
					end
				else
					CNT = CNT + 1;
			end
		else
			STOP = 1'b0;
end

always @(posedge CLK)
begin
	if(!RESETN)
		DOING = 1'b0;
	else
		if((ALARM_ENABLE == 1'b1) && (CURRENT_TIME == ALARM_TIME))
			begin
				DOING = 1'b1;
			end
		else if(STOP == 1'b1)
			begin
				DOING = 1'b0;
			end
end

assign ALARM_DOING = DOING;

endmodule
