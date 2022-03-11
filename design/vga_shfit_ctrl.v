
module vga_shfit_ctrl(
	input	wire 			clk,//vga_clk
	input	wire			s_clk,//soble clk 50Mhz
	input	wire 			rst_n,
	output	reg 			hsync,
	output	reg 			vsync,
	output	reg 	[7:0]	rgb,
	input	wire			pi_flag, //s_clk
	input	wire 	[7:0]	pi_rgb //s_clk
	);

reg [9:0]	cnt_h;//0~799
reg [9:0]	cnt_v;//0~524	
reg [8:0]	x;
reg 		flag_x;
reg [8:0]	y;
reg 		flag_y;
reg	[15:0]	addrb,addra;
wire [7:0]	doutb;

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		cnt_h <= 'd0;
	end
	else if(cnt_h != 'd799) begin
		cnt_h <= cnt_h + 1'b1;
	end
	else if (cnt_h == 'd799) begin
		cnt_h <= 'd0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		cnt_v <='d0;
	end
	else if (cnt_v == 'd524 && cnt_h == 'd799) begin
		cnt_v <= 'd0;
	end
	else if(cnt_h == 'd799) begin
		cnt_v <= cnt_v + 1'b1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		hsync <= 1'b1;
	end
	else if (cnt_h == 799) begin
		hsync <= 1'b1;
	end
	else if (cnt_h == 'd95) begin
		hsync <= 1'b0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		vsync <= 1'b1;
	end
	else if (cnt_v == 'd524 && cnt_h == 'd799) begin
		vsync <= 1'b1;
	end 
	else if (cnt_v == 'd1 && cnt_h == 'd799) begin
		vsync <=  1'b0;
	end
end


always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		x <='d0;
	end
	else if (flag_x == 1'b0 && cnt_v == 'd524 && cnt_h == 'd799) begin
		x<= x+ 1'b1;
	end
	else if(flag_x == 1'b1 && cnt_v == 'd524 && cnt_h == 'd799) begin
		x <= x -1'b1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		flag_x <= 1'b0;
	end
	else if (flag_x == 1'b0 && cnt_v =='d524 && cnt_h == 'd799 && x=='d441) begin
		flag_x <= 1'b1;
	end
	else if (flag_x == 1'b1 && cnt_v =='d524 && cnt_h == 'd799 && x=='d1) begin
		flag_x <= 1'b0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		y <= 'd0;
	end
	else if (flag_y == 1'b0 && cnt_v =='d524 && cnt_h == 'd799) begin
		y <= y + 1'b1;
	end
	else if (flag_y == 1'b1 && cnt_v =='d524 && cnt_h == 'd799) begin
		y <= y - 1'b1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		flag_y <= 1'b0;
	end
	else if (flag_y == 1'b0 && cnt_v =='d524 && cnt_h == 'd799 && y=='d281 ) begin
		flag_y <= 1'b1;
	end
	else if (flag_y == 1'b1 && cnt_v =='d524 && cnt_h == 'd799 && y=='d1 ) begin
		flag_y <= 1'b0;
	end
end

//rgb

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		rgb <='d0;
	end
	else if(cnt_h >=144+x && cnt_h <=341+x && cnt_v >=35+y && cnt_v <=232+y)begin
		rgb <=doutb;//8'b111_111_11;
	end
	else if (cnt_h >=144 && cnt_h <=783 && cnt_v >=35 && cnt_v <=194) begin
		rgb <=8'b111_000_00;//red
	end
	else if (cnt_h >=144 && cnt_h <=783 && cnt_v >=195 && cnt_v <=354) begin
		rgb <=8'b000_111_00;
	end
	else if (cnt_h >=144 && cnt_h <=783 && cnt_v >=355 && cnt_v <=514) begin
		rgb <= 8'b000_000_11;
	end
	else begin
		rgb <= 'd0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		// reset
		addrb <= 'd0;
	end
	else if(cnt_h >=143+x && cnt_h <=340+x && cnt_v >=35+y && cnt_v <=232+y && addrb=='d39203)begin
		addrb <= 'd0;
	end
	else if (cnt_h >=143+x && cnt_h <=340+x && cnt_v >=35+y && cnt_v <=232+y) begin
		addrb <= addrb + 1'b1;
	end
end

always @(posedge s_clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		// reset
		addra <= 'd0;
	end
	else if (pi_flag == 1'b1 && addra == 'd39203) begin
		addra <= 'd0;
	end
	else if (pi_flag == 1'b1) begin
		addra <= addra + 1'b1;
	end
end

bram_40000x8swsr bram4000_inst (
  .clka(s_clk), // input clka
  .wea(pi_flag), // input [0 : 0] wea
  .addra(addra), // input [15 : 0] addra
  .dina(pi_rgb), // input [7 : 0] dina
  .clkb(clk), // input clkb
  .addrb(addrb), // input [15 : 0] addrb
  .doutb(doutb) // output [7 : 0] doutb
);

endmodule 
