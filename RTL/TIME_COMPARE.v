module TIME_COMPARE(
	RESETN, CLK,
	ALARM_ENABLE, CURRENT_TIME, ALARM_TIME,
	ALARM_DOING
);

input RESETN, CLK;
input ALARM_ENABLE;
input [16:0] CURRENT_TIME, ALARM_TIME;
output wire ALARM_DOING;
reg DOING;

always @(posedge CLK)
begin
	if(!RESETN)
		DOING = 1'b0;
	else
		if((ALARM_ENABLE == 1'b1) && (CURRENT_TIME == ALARM_TIME))
			DOING = 1'b1;
		else
			DOING = 1'b0;
end

assign ALARM_DOING = DOING;

endmodule
