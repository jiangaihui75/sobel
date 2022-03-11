
module sobel_ctrl(
	input	wire 			clk,
	input	wire 			rst_n,
	input	wire 			pi_flag,
	input	wire 	[7:0]	pi_data,
	output	reg				po_flag,
	output	reg		[7:0]	po_rgb
	);

reg				wr_en1,wr_en2;
reg		[7:0]	cnt_col,cnt_row;
reg				wr_en1_pre2,wr_en1_pre1;
reg				rd_en;
wire 	[7:0]	dout1,dout2;
reg		[7:0]	data_in1,data_in2;
reg 			add_flag;

wire 			full1,empty1,full2,empty2;
reg				flag_shift;
reg		[7:0]	dout1_t,dout1_tt;
reg		[7:0]	dout2_t,dout2_tt;
reg		[7:0]	rx_data_t,rx_data_tt;
reg				flag_d_pre;
reg				flag_d;
reg		[7:0]	dx,dy;
reg 			flag_abs;
reg		[7:0]	abs_dx,abs_dy;
reg		[7:0]	dxy;
reg				flag_dxy;
//reg		[7:0]	rgb;
reg				flag_rgb;

parameter 	CNT_COL_MAX =199;
parameter	CNT_ROW_MAX =199;
parameter	VALUE = 12;

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		wr_en1 <= 1'b0;
	end
	else if (cnt_row == 'd0) begin
		wr_en1 <= pi_flag;
	end
	else begin
		wr_en1 <= wr_en1_pre1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		// reset
		wr_en1_pre2 <= 1'b0;
	end
	else if (cnt_row >=2 && cnt_row <=CNT_ROW_MAX-1 && pi_flag == 1'b1) begin
		wr_en1_pre2 <= 1'b1;
	end
	else begin
		wr_en1_pre2 <= 1'b0;
	end
end

always @(posedge clk) begin
	wr_en1_pre1 <= wr_en1_pre2;
end


always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		// reset
		rd_en <= 1'b0;
	end
	else if (cnt_row >=2 && cnt_row <=CNT_ROW_MAX && pi_flag == 1'b1) begin
		rd_en <= 1'b1;
	end
	else begin
		rd_en <= 1'b0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		// reset
		data_in1 <= 'd0;
	end
	else if (cnt_row == 'd0) begin
		data_in1 <= pi_data;
	end
	else  begin//if (cnt_row >=2 && cnt_row <=84)
		data_in1 <= dout2;
	end
end

always @(posedge clk or negedge rst_n ) begin
	if (rst_n  == 1'b0) begin
		// reset
		wr_en2 <= 1'b0;
	end
	else if (cnt_row >=1 && cnt_row <=CNT_ROW_MAX-1 && pi_flag == 1'b1) begin
		wr_en2 <= 1'b1;
	end
	else begin
		wr_en2 <= 1'b0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		// reset
		data_in2 <= 'd0;
	end
	else if ( cnt_row >=1 && cnt_row <=CNT_ROW_MAX-1) begin
		data_in2 <= pi_data;
	end
end


always @(posedge clk ) begin
	po_flag <= flag_rgb;
end

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		// reset
		cnt_col <= 'd0;
	end
	else if (pi_flag == 1'b1 && cnt_col == CNT_COL_MAX) begin
		cnt_col <= 'd0;
	end
	else if (pi_flag == 1'b1 && cnt_col != CNT_COL_MAX) begin
		cnt_col <=cnt_col + 1'b1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		// reset
		cnt_row <= 'd0;
	end
	else if(pi_flag == 1'b1 && cnt_col == CNT_COL_MAX && cnt_row == CNT_ROW_MAX)begin
		cnt_row <= 'd0;
	end
	else if (pi_flag == 1'b1 && cnt_col == CNT_COL_MAX) begin
		cnt_row <= cnt_row + 1'b1;
	end
end


always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		// reset
		flag_shift <= 1'b0;
	end
	else begin
		flag_shift <= rd_en;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		// reset
		flag_d_pre <= 1'b0;
	end
	else if (cnt_col >=2&&cnt_row>=2 && pi_flag == 1'b1) begin
		flag_d_pre <= 1'b1;
	end
	else begin
		flag_d_pre <= 1'b0;
	end
end

always @(posedge clk)begin
	flag_d <= flag_d_pre;
end

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		// reset
		dx <='d0;
		dy <='d0;
	end
	else if (flag_d == 1'b1) begin
		dx <= (dout2_tt - dout1)+((dout2_tt - dout2)<<1)+(rx_data_tt- pi_data);
		dy <=(dout1 - pi_data)+((dout1_t - rx_data_t)<<1)+(dout1_tt - rx_data_tt);
	end
end

always@(posedge clk)begin
	if(flag_shift == 1'b1)begin
	{dout1_tt,dout1_t} <= {dout1_t,dout1};
	{dout2_tt,dout2_t} <= {dout2_t,dout2};
	{rx_data_tt,rx_data_t}<={rx_data_t,pi_data};
	end
end

always @(posedge clk)begin
	flag_abs <= flag_d;
end

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		abs_dx<='d0;
	end
	else if (flag_abs==1'b1 && dx[7] == 1'b1) begin
		abs_dx <= (~dx)+1;
	end
	else if(flag_abs==1'b1 && dx[7]==1'b0) begin
		abs_dx <= dx;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		abs_dy<='d0;
	end
	else if (flag_abs==1'b1 && dy[7] == 1'b1) begin
		abs_dy <= (~dy)+1;
	end
	else if(flag_abs==1'b1 && dy[7]==1'b0) begin
		abs_dy <= dy;
	end
end

always @(posedge clk)begin
	flag_dxy <= flag_abs;
end

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		// reset
		dxy <='d0;
	end
	else if (flag_dxy == 1'b1) begin
		dxy <= abs_dy + abs_dx;
	end
end

always @(posedge clk) begin
	flag_rgb <= flag_dxy;
end

always @(posedge clk or negedge rst_n) begin
	if (rst_n == 1'b0) begin
		// reset
		po_rgb <='d0;
	end
	else if (flag_rgb==1'b1 && dxy > VALUE) begin
		po_rgb <= 8'hff;
	end
	else if(flag_rgb == 1'b1 && dxy <=VALUE) begin
		po_rgb <= 8'h00;
	end
end

sfifo_wr256x8 fifo1 (
  .clk(clk), // input clk
  .din(data_in1), // input [7 : 0] din
  .wr_en(wr_en1), // input wr_en
  .rd_en(rd_en), // input rd_en
  .dout(dout1), // output [7 : 0] dout
  .full(full1), // output full
  .empty(empty1) // output empty
);


sfifo_wr256x8 fifo2 (
  .clk(clk), // input clk
  .din(data_in2), // input [7 : 0] din
  .wr_en(wr_en2), // input wr_en
  .rd_en(rd_en), // input rd_en
  .dout(dout2), // output [7 : 0] dout
  .full(full2), // output full
  .empty(empty2) // output empty
);

wire [35:0] CONTROL0;
wire [9:0] TRIG0;

assign TRIG0 = {
	flag_rgb,
	dxy
};

cs_icon icon_inst (
    .CONTROL0(CONTROL0) // INOUT BUS [35:0]
);

cs_ila ila_inst (
    .CONTROL(CONTROL0), // INOUT BUS [35:0]
    .CLK(clk), // IN
    .TRIG0(TRIG0) // IN BUS [9:0]
);
endmodule