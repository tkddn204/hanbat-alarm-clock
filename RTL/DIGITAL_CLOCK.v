






// DIGITAL_CLOCK.v

module DIGITAL_CLOCK(
	RESETN, CLK,
	KEY,
   LCD_E, LCD_RS, LCD_RW,
	LCD_DATA
);

input RESETN, CLK;
input [7:0] KEY;
output wire LCD_E, LCD_RS, LCD_RW;
output wire [7:0] LCD_DATA;

wire [7:0] H10, H1, M10, M1, S10, S1, MERIDIAN;
wire [7:0] Y10, Y1, MT10, MT1, D10, D1, out_MERIDIAN;

wire [7:0] out_H10, out_H1, out_M10, out_M1, out_S10, out_S1;
wire [7:0] out_Y10, out_Y1, out_MT10, out_MT1, out_D10, out_D1;

wire [1:0] MODE;
wire TIME_FORMAT, RING_ALARM, SET_ALARM;
wire [2:0] FLAG;
wire [2:0] BLINK;

// Key Controller
key_cont(
	RESETN,
	KEY,
	TIME_FORMAT, MERIDIAN,
	MODE, FLAG, BLINK, UP, DOWN
);

// Time Calculator
Time_cal(
	RESETN, CLK,
	TIME_FORMAT, MERIDIAN, FLAG,
	H10, H1, M10, M1, S10, S1, out_MERIDIAN,
	Y10, Y1, MT10, MT1, D10, D1
);

// Time Controller
Time_cont(
	RESETN, CLK,
	TIME_FORMAT, MERIDIAN, FLAG, UP, DOWN,
	H10, H1, M10, M1, S10, S1, out_MERIDIAN,
	Y10, Y1, MT10, MT1, D10, D1
);

// LCD Controller
LCD_cont(
    RESETN, CLK,
	 out_H10, out_H1, out_M10, out_M1, out_S10, out_S1,
	 out_Y10, out_Y1, out_MT10, out_MT1, out_D10, out_D1,
	 TIME_FORMAT, MERIDIAN, MODE, BLINK,
	 RING_ALARM, SET_ALARM,
    LCD_E, LCD_RS, LCD_RW,
    LCD_DATA
);

endmodule
