// PIEZO
module PIEZO_UNIT(
	RESETN, CLK,
	ALARM_ENABLE, ALARM_DOING,
	PIEZO
);

input RESETN, CLK;
input ALARM_ENABLE, ALARM_DOING;
output wire PIEZO;

reg BUFF;
integer CNT, ORDER;
integer CNT_SOUND;
integer LIMIT;

parameter DO = 190,
			 RAE = 169,
			 MI = 151,
			 FA = 142,
			 SOL = 127,
			 RA = 113,
			 SI = 100,
			 HDO = 95;

always @(posedge CLK)
begin
	if(~RESETN)
		begin
			CNT = 0;
			ORDER = 0;
			LIMIT = 0;
		end
	else
		begin
			if(CNT == 499)
				begin
					CNT = 0;
					ORDER = ORDER + 1;
					case(ORDER)  // airplain
						0: LIMIT = 0;
						1: LIMIT = MI;
						2: LIMIT = RAE;
						3: LIMIT = RAE;
						4: LIMIT = DO;
						5: LIMIT = DO;
						6: LIMIT = RAE;
						7: LIMIT = RAE;
						8: LIMIT = MI;
						9: LIMIT = 0;
						10: LIMIT = MI;
						11: LIMIT = 0;
						12: LIMIT = MI;
						13: LIMIT = 0;
						14: LIMIT = 0;
						15: LIMIT = 0;
						16: LIMIT = RAE;
						17: LIMIT = 0;
						18: LIMIT = RAE;
						19: LIMIT = 0;
						20: LIMIT = RAE;
						21: LIMIT = 0;
						22: LIMIT = 0;
						23: LIMIT = 0;
						24: LIMIT = MI;
						25: LIMIT = 0;
						26: LIMIT = SOL;
						27: LIMIT = 0;
						28: LIMIT = SOL;
						29: LIMIT = 0;
						30: LIMIT = 0;
						31: LIMIT = 0;
						32: LIMIT = MI;
						33: LIMIT = MI;
						34: LIMIT = RAE;
						35: LIMIT = RAE;
						36: LIMIT = DO;
						37: LIMIT = DO;
						38: LIMIT = RAE;
						39: LIMIT = RAE;
						40: LIMIT = MI;
						41: LIMIT = 0;
						42: LIMIT = MI;
						43: LIMIT = 0;
						44: LIMIT = MI;
						45: LIMIT = 0;
						46: LIMIT = 0;
						47: LIMIT = 0;
						48: LIMIT = RAE;
						49: LIMIT = 0;
						50: LIMIT = RAE;
						51: LIMIT = 0;
						52: LIMIT = MI;
						53: LIMIT = MI;
						54: LIMIT = RAE;
						55: LIMIT = RAE;
						56: LIMIT = DO;
						57: LIMIT = DO;
						58: LIMIT = DO;
						59: LIMIT = DO;
						60: LIMIT = 0;
						61: LIMIT = 0;
						62: LIMIT = 0;
						63: LIMIT = 0;
						64: LIMIT = 0;
						65: LIMIT = 0;
						66: LIMIT = 0;
						67: LIMIT = 0;
						default: LIMIT = 0;
					endcase
				end
			else
				CNT = CNT + 1;
		end
end

always @(posedge CLK)
begin
	if(~RESETN)
		begin
			BUFF = 1'b0;
			CNT_SOUND = 0;
		end
	else
		begin
			if((ALARM_ENABLE == 1'b1) && (CNT_SOUND >= LIMIT))
				begin
					CNT_SOUND = 0;
					if(ALARM_DOING == 1'b1)
						BUFF = ~BUFF;
				end
			else
				CNT_SOUND = CNT_SOUND + 1;
		end
end

assign PIEZO = BUFF;

endmodule
