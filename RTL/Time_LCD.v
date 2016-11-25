






// Time_LCD.v

module Time_LCD(
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

wire [1:0] MODE;
wire [2:0] FLAG;

// Time Calculator
Time_cal(
	RESETN, CLK,
	H10, H1, M10, M1, S10, S1
);

// Key Controller
key_cont(
	RESETN,
	KEY
	MERIDIAN, MODE, FLAG
);

// LCD Controller
LCD_cont(
    RESETN, CLK,
	 H10, H1, M10, M1, S10, S1, MERIDIAN,
    LCD_E, LCD_RS, LCD_RW,
    LCD_DATA
);

endmodule
