






// WT_DECODER.v

module WT_DECODER(
	BCD,
	LCD_DATA
);

input [3:0] BCD;
output wire [7:0] LCD_DATA;

reg [7:0] BUFF;

always @(BCD)
begin
	case(BCD)
		4'b0000: BUFF = 8'b00110000;
		4'b0001: BUFF = 8'b00110001;
		4'b0010: BUFF = 8'b00110010;
		4'b0011: BUFF = 8'b00110011;
		4'b0100: BUFF = 8'b00110100;
		4'b0101: BUFF = 8'b00110101;
		4'b0110: BUFF = 8'b00110110;
		4'b0111: BUFF = 8'b00110111;
		4'b1000: BUFF = 8'b00111000;
		4'b1001: BUFF = 8'b00111001;
		default: BUFF = 8'b00110000;
	endcase
end

assign LCD_DATA = BUFF;

endmodule
