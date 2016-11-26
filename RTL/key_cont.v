






// key_cont.v

module key_cont(
	RESETN,
	KEY,
	TIME_FORMAT, MERIDIAN,
	MODE, FLAG, BLINK, UP, DOWN
);

input RESETN;
input [7:0] KEY;

output reg TIME_FORMAT;
output reg [7:0] MERIDIAN;
output wire [1:0] MODE;
output wire [2:0] FLAG, BLINK;
output wire [2:0] UP, DOWN;

reg [1:0] MODE_BUFF;
reg [2:0] FLAG_BUFF;
reg [2:0] BLINK_BUFF;
reg [2:0] UP_BUFF, DOWN_BUFF;

/* MERIDIAN LIST(A, B) */
parameter AM = 8'b01000001,
			 PM = 8'b01000010;

/* KEY LIST */
parameter MENU = 8'b10000000,
			 SET = 8'b01000000,
			 CANCEL = 8'b00100000,
			 UP_KEY = 8'b00010000,
			 DOWN_KEY = 8'b00001000;
			 
/* MODE BUFF */
// 10 -> State Bit
//  1 -> Control Bit
parameter CURRENT_TIME = 2'b00,
			 CURRENT_CONTROL_TIME = 2'b01,
			 ALARM_TIME = 2'b10,
			 ALARM_CONTROL_TIME = 2'b11;

/* FLAG BUFF */
parameter FLAG_NO = 3'b000,
			 FLAG_VIEW_ALARM = 3'b001,
			 FLAG_CONTROL_STATE = 3'b100,
			 FLAG_CONTROL_CHANGE_CANCEL_STATE = 3'b101;

/* TIME FORMAT LIST */
parameter FORMAT_24 = 0,
			 FORMAT_12 = 1;

/* CURRENT BLINK LIST */
parameter BLINK_NO = 3'b000,
			 BLINK_HOUR = 3'b001,
			 BLINK_MIN = 3'b010,
			 BLINK_SEC = 3'b011,
			 BLINK_MERIDIAN = 3'b100,
			 BLINK_YEAR = 3'b101,
			 BLINK_MONTH = 3'b110,
			 BLINK_DAY = 3'b111;
			 
/* UP LIST */
parameter UP_NO = 3'b000,
			 UP_HOUR = 3'b001,
			 UP_MIN = 3'b010,
			 UP_SEC = 3'b011,
			 UP_MERIDIAN = 3'b100,
			 UP_YEAR = 3'b101,
			 UP_MONTH = 3'b110,
			 UP_DAY = 3'b111;

/* DOWN LIST */		 
parameter DOWN_NO = 3'b000,
			 DOWN_HOUR = 3'b001,
			 DOWN_MIN = 3'b010,
			 DOWN_SEC = 3'b011,
			 DOWN_MERIDIAN = 3'b100,
			 DOWN_YEAR = 3'b101,
			 DOWN_MONTH = 3'b110,
			 DOWN_DAY = 3'b111;
						 
initial
begin
	TIME_FORMAT = FORMAT_24;
	MERIDIAN = AM;
	MODE_BUFF = CURRENT_TIME;
	FLAG_BUFF = FLAG_NO;
	BLINK_BUFF = BLINK_NO;
	UP_BUFF = UP_NO;
	DOWN_BUFF = DOWN_NO;
end
			 
always @(KEY)
begin
	case(KEY)
		MENU:
			begin
				case(MODE_BUFF)
					CURRENT_TIME: 			 
						MODE_BUFF = CURRENT_CONTROL_TIME;
					CURRENT_CONTROL_TIME:
						if(FLAG == FLAG_CONTROL_STATE)
							case(BLINK_BUFF)
								BLINK_HOUR:
									BLINK_BUFF = BLINK_MIN;
								BLINK_MIN:
									BLINK_BUFF = BLINK_SEC;
								BLINK_SEC:
									if(TIME_FORMAT == FORMAT_24)
										BLINK_BUFF = BLINK_YEAR;
									else
										BLINK_BUFF = BLINK_MERIDIAN;
								BLINK_MERIDIAN:
									BLINK_BUFF = BLINK_YEAR;
								BLINK_YEAR:
									BLINK_BUFF = BLINK_MONTH;
								BLINK_MONTH:
									BLINK_BUFF = BLINK_DAY;
								BLINK_DAY:
									BLINK_BUFF = BLINK_HOUR;
								default:
									BLINK_BUFF = BLINK_HOUR;
							endcase
						else
							MODE_BUFF = ALARM_TIME;
					ALARM_TIME: 			 
						MODE_BUFF = ALARM_CONTROL_TIME;
					ALARM_CONTROL_TIME:
						if(FLAG == FLAG_CONTROL_STATE)
							case(BLINK_BUFF)
								BLINK_HOUR:
									BLINK_BUFF = BLINK_MIN;
								BLINK_MIN:
									BLINK_BUFF = BLINK_SEC;
								BLINK_SEC:
									if(TIME_FORMAT == FORMAT_24)
										BLINK_BUFF = BLINK_YEAR;
									else
										BLINK_BUFF = BLINK_MERIDIAN;
								BLINK_MERIDIAN:
									BLINK_BUFF = BLINK_YEAR;
								BLINK_YEAR:
									BLINK_BUFF = BLINK_MONTH;
								BLINK_MONTH:
									BLINK_BUFF = BLINK_DAY;
								BLINK_DAY:
									BLINK_BUFF = BLINK_HOUR;
								default:
									BLINK_BUFF = BLINK_HOUR;
							endcase
						else
							MODE_BUFF = CURRENT_TIME;
					default:
						MODE_BUFF = CURRENT_TIME;
				endcase
			end
		SET:
			begin
				case(MODE_BUFF)
					CURRENT_TIME:
						// alarm time check
						// TODO add 3 seconds!!
						if(FLAG_BUFF == FLAG_NO)
							FLAG_BUFF = FLAG_VIEW_ALARM;
					CURRENT_CONTROL_TIME: 
						// control current time
						if(BLINK_BUFF != BLINK_NO)
							BLINK_BUFF = BLINK_NO;
						else
							FLAG_BUFF = FLAG_CONTROL_STATE;
					ALARM_TIME:
						// nothing special
						FLAG_BUFF = FLAG_NO;
					ALARM_CONTROL_TIME:
						// control alarm time
						if(BLINK_BUFF != BLINK_NO)
							BLINK_BUFF = BLINK_NO;
						else
							FLAG_BUFF = FLAG_CONTROL_STATE;
					default:
						FLAG_BUFF = FLAG_NO;
				endcase
			end
		CANCEL:
			begin
				case(MODE_BUFF)
					CURRENT_TIME:
						begin
							FLAG_BUFF = FLAG_NO;
						// TODO maybe operated change problem..
							if((TIME_FORMAT == FORMAT_12) && (MERIDIAN == AM))
									MERIDIAN = PM;
							else					 
									MERIDIAN = AM;
						end
					CURRENT_CONTROL_TIME:
						// control current time
						if(BLINK_BUFF != BLINK_NO)
							begin
								BLINK_BUFF = BLINK_NO;
								FLAG_BUFF = FLAG_CONTROL_CHANGE_CANCEL_STATE;
							end
						else
							FLAG_BUFF = FLAG_CONTROL_STATE;
					ALARM_TIME:
						// nothing special
						FLAG_BUFF = FLAG_NO;
					ALARM_CONTROL_TIME:
						// control alarm time
						if(BLINK_BUFF != BLINK_NO)
							begin
								BLINK_BUFF = BLINK_NO;
								FLAG_BUFF = FLAG_CONTROL_CHANGE_CANCEL_STATE;
							end
						else
							FLAG_BUFF = FLAG_CONTROL_STATE;
					default:
						FLAG_BUFF = FLAG_NO;
				endcase
			end
		UP_KEY:
			begin
				case(MODE_BUFF)
					CURRENT_TIME:
						// nothing special
						FLAG_BUFF = FLAG_NO;
					CURRENT_CONTROL_TIME: 
						// control current time - up to blink site
						if(FLAG == FLAG_CONTROL_STATE)
							UP_BUFF = BLINK_BUFF;
					ALARM_TIME:
						// nothing special
						FLAG_BUFF = FLAG_NO;
					ALARM_CONTROL_TIME:
						// control alarm time - up to blink site
						if(FLAG == FLAG_CONTROL_STATE)
							UP_BUFF = BLINK_BUFF;
					default:
						FLAG_BUFF = FLAG_NO;
				endcase
			end
		DOWN_KEY:
			begin
				case(MODE_BUFF)
					CURRENT_TIME:
						// nothing special
						FLAG_BUFF = FLAG_NO;
					CURRENT_CONTROL_TIME: 
						// control current time - down to blink site
						if(FLAG == FLAG_CONTROL_STATE)
							DOWN_BUFF = BLINK_BUFF;
					ALARM_TIME:
						// nothing special
						FLAG_BUFF = FLAG_NO;
					ALARM_CONTROL_TIME:
						// control alarm time - down to blink site
						if(FLAG == FLAG_CONTROL_STATE)
							DOWN_BUFF = BLINK_BUFF;
					default:
						FLAG_BUFF = FLAG_NO;
				endcase
			end
	endcase
end

assign MODE = MODE_BUFF;
assign FLAG = FLAG_BUFF;
assign UP = UP_BUFF;
assign DOWN = DOWN_BUFF;

endmodule
