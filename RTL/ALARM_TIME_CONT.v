
/* IN_TIME BIT LIST
`define   IN_MERIDIAN IN_TIME[16]
`define	 IN_HOUR     IN_TIME[15:12]
`define	 IN_MIN      IN_TIME[11:6]
`define   IN_SEC      IN_TIME[5:0]
*/
module ALARM_TIME_CONT(
	RESETN, CLK,
	IN_TIME,
	FLAG, UP, DOWN,
	OUT_TIME
);

input RESETN, CLK;
input [16:0] IN_TIME;
input [2:0] FLAG;
input [2:0] UP, DOWN;
output wire [16:0] OUT_TIME;

/* FLAG */
parameter FLAG_ALARM_CONTROL_STATE = 3'b101;
			 
/* CONTROL SELECTER LIST */
parameter CONT_NO = 3'b000,
			 CONT_HOUR = 3'b001,
			 CONT_MIN = 3'b010,
			 CONT_SEC = 3'b011,
			 CONT_MERIDIAN = 3'b100;
			 
reg MERIDIAN;
reg [3:0] HOUR;
reg [5:0] MIN, SEC;

parameter AM = 8'b01000001,
			 PM = 8'b01000010;

/* TIME FORMAT LIST */
parameter FORMAT_24 = 0,
			 FORMAT_12 = 1;

always @(posedge CLK or negedge RESETN)
begin
		if(~RESETN)
			begin
				HOUR = IN_TIME[15:12]; MIN = IN_TIME[11:6];
				SEC = IN_TIME[5:0]; MERIDIAN = AM;
			end
		else
			begin
				if(FLAG == FLAG_ALARM_CONTROL_STATE)
					// Up part
					case(UP)
						CONT_HOUR:
							begin
								if(HOUR >= 23)
									HOUR = 0;
								else
									HOUR = HOUR + 1;
							end
						CONT_MIN:
							begin
								if(MIN >= 59)
									MIN = 0;
								else
									MIN = MIN + 1;
							end
						CONT_SEC:
							begin
								if(SEC >= 59)
									SEC = 0;
								else
									SEC = SEC + 1;
							end
						CONT_MERIDIAN:
							begin
								if(MERIDIAN == AM)
									MERIDIAN = PM;
								else
									MERIDIAN = AM;
							end
						default:
							begin
								HOUR = IN_TIME[15:12]; MIN = IN_TIME[11:6];
								SEC = IN_TIME[5:0]; MERIDIAN = AM;
							end
					endcase
					
					// DOWN part
					case(DOWN)
						CONT_HOUR:
							begin
								if(HOUR <= 0)
									HOUR = 23;
								else
									HOUR = HOUR - 1;
							end
						CONT_MIN:
							begin
								if(MIN <= 0)
									MIN = 59;
								else
									MIN = MIN - 1;
							end
						CONT_SEC:
							begin
								if(SEC <= 0)
									SEC = 59;
								else
									SEC = SEC - 1;
							end
						CONT_MERIDIAN:
							begin
								if(MERIDIAN == AM)
									MERIDIAN = PM;
								else
									MERIDIAN = AM;
							end
						default:
							begin
								HOUR = IN_TIME[15:12]; MIN = IN_TIME[11:6];
								SEC = IN_TIME[5:0]; MERIDIAN = AM;
							end
					endcase
				end
end

assign OUT_TIME = { MERIDIAN, HOUR, MIN, SEC };

endmodule
