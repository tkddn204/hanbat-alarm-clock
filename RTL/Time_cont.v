
/* IN_TIME BIT LIST
`define   IN_MERIDIAN IN_TIME[16]
`define	 IN_HOUR     IN_TIME[15:12]
`define	 IN_MIN      IN_TIME[11:6]
`define   IN_SEC      IN_TIME[5:0]

/* IN_DATE BIT LIST
`define   IN_YEAR     IN_DATE[16:10]
`define	 IN_MONTH    IN_DATE[9:5]
`define	 IN_DAY      IN_DATE[4:0]
*/

module TIME_CONT(
	RESETN, CLK,
	IN_TIME, IN_DATE,
	FLAG, UP, DOWN,
	OUT_TIME, OUT_DATE
);

input RESETN, CLK;
input [16:0] IN_TIME, IN_DATE;
input [2:0] FLAG;
input [2:0] UP, DOWN;
output wire [16:0] OUT_TIME, OUT_DATE;

/* FLAG BUFF */
parameter FLAG_CONTROL_STATE = 3'b100;
			 
/* CONTROL SELECTER LIST */
parameter CONT_NO = 3'b000,
			 CONT_HOUR = 3'b001,
			 CONT_MIN = 3'b010,
			 CONT_SEC = 3'b011,
			 CONT_MERIDIAN = 3'b100,
			 CONT_YEAR = 3'b101,
			 CONT_MONTH = 3'b110,
			 CONT_DAY = 3'b111;
			 
/* MERIDIAN LIST */
parameter AM = 8'b01000001,
			 PM = 8'b01000010;
			 
reg MERIDIAN;
reg [3:0] HOUR;
reg [5:0] MIN, SEC;
reg [6:0] YEAR;
reg [4:0] MONTH, DAY;

always @(posedge CLK or negedge RESETN)
begin
		if(~RESETN)
			begin
				HOUR = IN_TIME[15:12]; MIN = IN_TIME[11:6]; SEC = IN_TIME[5:0]
; MERIDIAN = AM;
				YEAR = IN_DATE[16:10]; MONTH = IN_DATE[9:5]; DAY = IN_DATE[4:0];
			end
		else
			begin
				if(FLAG == FLAG_CONTROL_STATE)
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
						CONT_YEAR:
							begin
								if(YEAR >= 99)
									YEAR = 0;
								else
									YEAR = YEAR + 1;
							end
						CONT_MONTH:
							begin
							if(MONTH >= 12)
								MONTH = 1;
							else
								MONTH = MONTH + 1;
							end
						CONT_DAY:
							begin
								if(DAY >= 31)
									DAY = 1;
								else
									DAY = DAY + 1;
							end
						default:
							begin
				HOUR = IN_TIME[15:12]; MIN = IN_TIME[11:6]; SEC = IN_TIME[5:0]
; MERIDIAN = AM;
				YEAR = IN_DATE[16:10]; MONTH = IN_DATE[9:5]; DAY = IN_DATE[4:0];
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
						CONT_YEAR:
							begin
								if(YEAR <= 0)
									YEAR = 99;
								else
									YEAR = YEAR - 1;
							end
						CONT_MONTH:
							begin
								if(MONTH <= 1)
									MONTH = 12;
								else
									MONTH = MONTH - 1;
							end
						CONT_DAY:
							begin
								if(DAY <= 1)
									DAY = 31;
								else
									DAY = DAY - 1;
							end
						default:
							begin
				HOUR = IN_TIME[15:12]; MIN = IN_TIME[11:6]; SEC = IN_TIME[5:0]
; MERIDIAN = AM;
				YEAR = IN_DATE[16:10]; MONTH = IN_DATE[9:5]; DAY = IN_DATE[4:0];
							end
					endcase
				end
end

assign OUT_TIME = { MERIDIAN, HOUR, MIN, SEC };
assign OUT_DATE = { YEAR, MONTH, DAY };

endmodule
