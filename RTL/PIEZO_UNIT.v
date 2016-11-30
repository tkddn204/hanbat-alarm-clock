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
			if(CNT == 12499)
				begin
					CNT = 0;
					ORDER = ORDER + 1;
					case(ORDER)  // airplain
						0: begin LIMIT = 0; end
						1: begin LIMIT = MI; end
						2: begin LIMIT = RAE; end
						3: begin LIMIT = RAE; end
						4: begin LIMIT = DO; end
						5: begin LIMIT = DO; end
						6: begin LIMIT = RAE; end
						7: begin LIMIT = RAE; end
						8: begin LIMIT = MI; end
						9: begin LIMIT = 0; end
						10: begin LIMIT = MI; end
						11: begin LIMIT = 0; end
						12: begin LIMIT = MI; end
						13: begin LIMIT = 0; end
						14: begin LIMIT = 0; end
						15: begin LIMIT = 0; end
						16: begin LIMIT = RAE; end
						17: begin LIMIT = 0; end
						18: begin LIMIT = RAE; end
						19: begin LIMIT = 0; end
						20: begin LIMIT = RAE; end
						21: begin LIMIT = 0; end
						22: begin LIMIT = 0; end
						23: begin LIMIT = 0; end
						24: begin LIMIT = MI; end
						25: begin LIMIT = 0; end
						26: begin LIMIT = SOL; end
						27: begin LIMIT = 0; end
						28: begin LIMIT = SOL; end
						29: begin LIMIT = 0; end
						30: begin LIMIT = 0; end
						31: begin LIMIT = 0; end
						32: begin LIMIT = MI; end
						33: begin LIMIT = MI; end
						34: begin LIMIT = RAE; end
						35: begin LIMIT = RAE; end
						36: begin LIMIT = DO; end
						37: begin LIMIT = DO; end
						38: begin LIMIT = RAE; end
						39: begin LIMIT = RAE; end
						40: begin LIMIT = MI; end
						41: begin LIMIT = 0; end
						42: begin LIMIT = MI; end
						43: begin LIMIT = 0; end
						44: begin LIMIT = MI; end
						45: begin LIMIT = 0; end
						46: begin LIMIT = 0; end
						47: begin LIMIT = 0; end
						48: begin LIMIT = RAE; end
						49: begin LIMIT = 0; end
						50: begin LIMIT = RAE; end
						51: begin LIMIT = 0; end
						52: begin LIMIT = MI; end
						53: begin LIMIT = MI; end
						54: begin LIMIT = RAE; end
						55: begin LIMIT = RAE; end
						56: begin LIMIT = DO; end
						57: begin LIMIT = DO; end
						58: begin LIMIT = DO; end
						59: begin LIMIT = DO; end
						60: begin LIMIT = 0; end
						61: begin LIMIT = 0; end
						62: begin LIMIT = 0; end
						63: begin LIMIT = 0; end
						64: begin LIMIT = 0; end
						65: begin LIMIT = 0; end
						66: begin LIMIT = 0; end
						67: begin LIMIT = 0; ORDER = 0; end
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
