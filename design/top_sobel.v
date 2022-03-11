
module top_sobel(
	input	wire 			clk,
	input	wire 			rst_n,
	input	wire 			rx,
	output	wire 			hsync,
	output	wire 			vsync,
	output	wire 	[7:0]	rgb
	);
wire		s_clk , vga_clk;
wire 		po_flag_u;
wire [7:0]	po_data_u;
wire 		po_flag_s;
wire [7:0]	po_rgb_s;

  gen_clk gen_clk_inst
   (// Clock in ports
    .CLK_IN1(clk),      // IN
    // Clock out ports
    .s_clk(s_clk),     // OUT
    .vga_clk(vga_clk));    // OUT

	uart_rx inst_uart_rx (
			.sclk    (s_clk),
			.rst_n   (rst_n),
			.rx      (rx),
			.po_data (po_data_u),
			.po_flag (po_flag_u)
		);
	sobel_ctrl inst_sobel_ctrl (
			.clk     (s_clk),
			.rst_n   (rst_n),
			.pi_flag (po_flag_u),
			.pi_data (po_data_u),
			.po_flag (po_flag_s),
			.po_rgb  (po_rgb_s)
		);

	vga_shfit_ctrl inst_vga_shfit_ctrl
		(
			.clk     (vga_clk),
			.s_clk   (s_clk),
			.rst_n   (rst_n),
			.hsync   (hsync),
			.vsync   (vsync),
			.rgb     (rgb),
			.pi_flag (po_flag_s),
			.pi_rgb  (po_rgb_s)
		);

endmodule 