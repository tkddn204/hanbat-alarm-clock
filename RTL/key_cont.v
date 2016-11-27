
/* IN_TIME BIT LIST
`define   IN_MERIDIAN IN_TIME[16]
`define	 IN_HOUR     IN_TIME[15:12]
`define	 IN_MIN      IN_TIME[11:6]
`define   IN_SEC      IN_TIME[5:0]

/* OUT_TIME BIT LIST
`define OUT_MERIDIAN  OUT_TIME_BUFF[16]
*/

// KEY_CONT.v

module KEY_CONT(
	RESETN, CLK,
	KEY, IN_TIME,
	MODE, FLAG, CONT, UP, DOWN,
	OUT_TIME, SET_ALARM
);

input RESETN, CLK;
input [4:0] KEY;
input [16:0] IN_TIME;
output wire [1:0] MODE;
output wire [2:0] FLAG, CONT;
output wire [2:0] UP, DOWN;
output wire [16:0] OUT_TIME;
output reg SET_ALARM;

reg [16:0] OUT_TIME_BUFF;
reg [1:0] MODE_BUFF;
reg [2:0] FLAG_BUFF, CONT_BUFF;
reg [2:0] UP_BUFF, DOWN_BUFF;

/* KEY LIST */
parameter MENU = 8'b10000,
			 SET = 8'b01000,
			 CANCEL = 8'b00100,
			 UP_KEY = 8'b00010,
			 DOWN_KEY = 8'b00001;
			 
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
			 FLAG_ALARM_CONTROL_STATE = 3'b101,
			 FLAG_CONTROL_CHANGE_DONE_STATE = 3'b110,
			 FLAG_CONTROL_CHANGE_CANCEL_STATE = 3'b111;

/* CONTROL SELECTER LIST */
parameter CONT_NO = 3'b000,
			 CONT_HOUR = 3'b001,
			 CONT_MIN = 3'b010,
			 CONT_SEC = 3'b011,
			 CONT_MERIDIAN = 3'b100,
			 CONT_YEAR = 3'b101,
			 CONT_MONTH = 3'b110,
			 CONT_DAY = 3'b111;
			 
initial begin
	CNT_ALARM = 0;
	OUT_TIME_BUFF = IN_TIME;
	MODE_BUFF = CURRENT_TIME;
	FLAG_BUFF = FLAG_NO;
	CONT_BUFF = CONT_NO;
	UP_BUFF = CONT_NO;
	DOWN_BUFF = CONT_NO;
end

integer CNT, CNT_ALARM;

always @(posedge CLK)
begin
	if(!RESETN)
		begin
			CNT = 0;
			CNT_ALARM = 0;
		end
	else
		begin
				if((FLAG == FLAG_CONTROL_STATE) || (FLAG == FLAG_ALARM_CONTROL_STATE))
					begin
						if(CNT >= 999)
							begin
								CNT = 0;
								FLAG_BUFF = FLAG_CONTROL_CHANGE_DONE_STATE;
							end
						else
							CNT = CNT + 1;
					end
			if((FLAG == FLAG_VIEW_ALARM) && (CNT_ALARM >= 299))
				begin
					CNT_ALARM = 0;
					FLAG_BUFF = FLAG_NO;
				end
			else
				CNT_ALARM = CNT_ALARM + 1;
		end
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
						case(FLAG_BUFF)
							FLAG_NO:
								MODE_BUFF = ALARM_TIME;
							FLAG_CONTROL_STATE:
								case(CONT_BUFF)
									CONT_HOUR:
										CONT_BUFF = CONT_MIN;
									CONT_MIN:
										CONT_BUFF = CONT_SEC;
									CONT_SEC:
										if(IN_TIME[16] == 0)
											CONT_BUFF = CONT_YEAR;
										else
											CONT_BUFF = CONT_MERIDIAN;
									CONT_MERIDIAN:
										CONT_BUFF = CONT_YEAR;
									CONT_YEAR:
										CONT_BUFF = CONT_MONTH;
									CONT_MONTH:
										CONT_BUFF = CONT_DAY;
									CONT_DAY:
										CONT_BUFF = CONT_HOUR;
									default:
										begin
											FLAG_BUFF = FLAG_NO;
											CONT_BUFF = CONT_NO;
										end
								endcase
							FLAG_CONTROL_CHANGE_DONE_STATE:
								begin
								// DONE -> FLAG CHANGE and reg TIME
									FLAG_BUFF = FLAG_NO;
									CONT_BUFF = CONT_NO;
								end
							FLAG_CONTROL_CHANGE_CANCEL_STATE:
								begin
								// CANCEL -> FLAG CHANGE and origin TIME
									FLAG_BUFF = FLAG_NO;
									CONT_BUFF = CONT_NO;
								end
							default:
								MODE_BUFF = ALARM_TIME;
						endcase
					ALARM_TIME: 			 
						MODE_BUFF = ALARM_CONTROL_TIME;
					ALARM_CONTROL_TIME:
						case(FLAG_BUFF)
							FLAG_NO:
								MODE_BUFF = ALARM_TIME;
							FLAG_ALARM_CONTROL_STATE:
								case(CONT_BUFF)
									CONT_HOUR:
										CONT_BUFF = CONT_MIN;
									CONT_MIN:
										CONT_BUFF = CONT_SEC;
									CONT_SEC:
										if(IN_TIME[16] == 0)
											CONT_BUFF = CONT_HOUR;
										else
											CONT_BUFF = CONT_MERIDIAN;
									CONT_MERIDIAN:
										CONT_BUFF = CONT_HOUR;
									default:
										begin
											FLAG_BUFF = FLAG_NO;
											CONT_BUFF = CONT_NO;
										end
								endcase
							FLAG_CONTROL_CHANGE_DONE_STATE:
								begin
								// DONE -> FLAG CHANGE and reg TIME
									FLAG_BUFF = FLAG_NO;
									CONT_BUFF = CONT_NO;
								end
							FLAG_CONTROL_CHANGE_CANCEL_STATE:
								begin
								// CANCEL -> FLAG CHANGE and origin TIME
									FLAG_BUFF = FLAG_NO;
									CONT_BUFF = CONT_NO;
								end
							default:
								MODE_BUFF = ALARM_TIME;
						endcase
					default:
						MODE_BUFF = CURRENT_TIME;
				endcase
			end
		SET:
			begin
				case(MODE_BUFF)
					CURRENT_TIME:
						// alarm time check
						FLAG_BUFF = FLAG_VIEW_ALARM;
					CURRENT_CONTROL_TIME:
						// control current time
						case (FLAG_BUFF)
							FLAG_CONTROL_STATE:
								FLAG_BUFF = FLAG_CONTROL_CHANGE_DONE_STATE;
						endcase
					ALARM_TIME:
						// alarm time check
						FLAG_BUFF = FLAG_VIEW_ALARM;
					ALARM_CONTROL_TIME:
						// control alarm time
						case (FLAG_BUFF)
							FLAG_ALARM_CONTROL_STATE:
								begin
									FLAG_BUFF = FLAG_CONTROL_CHANGE_DONE_STATE;
									SET_ALARM = 1;
								end
						endcase
					default:
						FLAG_BUFF = FLAG_NO;
				endcase
			end
		CANCEL:
			begin
				case(MODE_BUFF)
					CURRENT_TIME:
						// change meridian
						begin
							FLAG_BUFF = FLAG_NO;
							if(IN_TIME[16] == 0)
								OUT_TIME_BUFF[16] = 1;
							else					 
								OUT_TIME_BUFF[16] = 0;
						end
					CURRENT_CONTROL_TIME:
						// control current time
						case (FLAG_BUFF)
							FLAG_CONTROL_STATE:
								FLAG_BUFF = FLAG_CONTROL_CHANGE_CANCEL_STATE;
						endcase
					ALARM_TIME:
						// alarm cancel
						if(SET_ALARM == 1)
							SET_ALARM = 0;
					ALARM_CONTROL_TIME:
						// control alarm time
						case (FLAG_BUFF)
							FLAG_ALARM_CONTROL_STATE:
								begin
									FLAG_BUFF = FLAG_CONTROL_CHANGE_DONE_STATE;
									SET_ALARM = 1;
								end
						endcase
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
						// control current time - up to CONT site
						if(FLAG == FLAG_CONTROL_STATE)
							UP_BUFF = CONT_BUFF;
					ALARM_TIME:
						// nothing special
						FLAG_BUFF = FLAG_NO;
					ALARM_CONTROL_TIME:
						// control alarm time - up to CONT site
						if(FLAG == FLAG_ALARM_CONTROL_STATE)
							UP_BUFF = CONT_BUFF;
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
						// control current time - down to CONT site
						if(FLAG == FLAG_CONTROL_STATE)
							DOWN_BUFF = CONT_BUFF;
					ALARM_TIME:
						// nothing special
						FLAG_BUFF = FLAG_NO;
					ALARM_CONTROL_TIME:
						// control alarm time - down to CONT site
						if(FLAG == FLAG_ALARM_CONTROL_STATE)
							DOWN_BUFF = CONT_BUFF;
					default:
						FLAG_BUFF = FLAG_NO;
				endcase
			end
	endcase
end

assign OUT_TIME = OUT_TIME_BUFF;
assign MODE = MODE_BUFF;
assign FLAG = FLAG_BUFF;
assign CONT = CONT_BUFF;
assign UP = UP_BUFF;
assign DOWN = DOWN_BUFF;

endmodule
