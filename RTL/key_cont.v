






// key_cont.v

module key_cont(
	RESETN,
	KEY, MERIDIAN,
	out_MERIDIAN, MODE, FLAG
);

input RESETN;
input [7:0] KEY;
input [7:0] MERIDIAN;
output wire [1:0] MODE;
output wire [2:0] FLAG;
output wire [7:0] out_MERIDIAN;

reg [1:0] MODE_BUFF = 2'b00;
reg [2:0] FLAG_BUFF = 3'b000;
reg [7:0] MERIDIAN_BUFF;

parameter MENU = 8'b10000000,
			 SET = 8'b01000000,
			 CANCEL = 8'b00100000,
			 UP = 8'b00010000,
			 DOWN = 8'b00001000,
			 
/* MODE BUFF */
// 10 -> State Bit
//  1 -> Control Bit
parameter CURRENT_TIME = 2'b00,
			 CURRENT_CONTROL_TIME = 2'b01,
			 ALARM_TIME = 2'b10,
			 ALARM_CONTROL_TIME = 2'b11;

/* FLAG BUFF */
parameter CHANGE_CONTROL_STATE = 3'b000,
			 CHANGE_ALARM_STATE = 3'b001,
			 CHANGE_AM = 3'b010,
			 CHANGE_PM = 3'b011,
			 VIEW_ALARM = 3'b100,
			 ALARM_OFF = 3'b101;
			 
always @(KEY)
begin
	case(KEY)
		MENU:
			begin
				case(MODE_BUFF) {
					CURRENT_TIME: 			 MODE_BUFF = CURRENT_CONTROL_TIME;
					CURRENT_CONTROL_TIME: MODE_BUFF = ALARM_TIME;
					ALARM_TIME: 			 MODE_BUFF = ALARM_CONTROL_TIME;
					ALARM_CONTROL_TIME:	 MODE_BUFF = CURRENT_TIME;
				}
			end
		SET:
			begin
				/*if(FLAG_BUFF == ALARM_ON) {
					FLAG_BUFF = VIEW_ALARM
				}*/
			end
		CANCEL:
			begin
				if(MODE_BUFF == 2'b00)
					if(MERIDIAN == 8'b01000001)
						MERIDIAN_BUFF = 8'b01000010
					else 
						MERIDIAN_BUFF = 8'b01000001
				else
					FLAG_BUFF = CHANGE_PM;
			end
		UP:
			begin
				//if(MODE_BUFF == 2'b01 && MODE_BUFF == 2'b11)
			end
		DOWN:
			begin
			
			end
	endcase
end

assign MODE = MODE_BUFF;
assign FLAG = FLAG_BUFF;
assign out_MERIDIAN = MERIDIAN_BUFF;

endmodule
