module pix_passthrough(
	input
		clk,
		rst_n,
		ready,
	input [8:0]
		dim,
	input [7:0]
    	dataout_ram,
	output reg
		writeEnable,
		start,
	output reg [15:0]
		addr,
	output reg [7:0]
		datain_ram
);

localparam STATE_IDLE = 2'b00;
localparam STATE_RD   = 2'b01;
localparam STATE_W    = 2'b11;

reg [1:0]
	state_c, state_r;

reg [8:0]
	col_cnt_c, col_cnt_r,
	row_cnt_c, row_cnt_r;

reg [15:0]
	addr_r;

always@(*) begin
	if(!rst_n) begin
		addr        = 16'b0;
		writeEnable = 1'b0;
		start       = 1'b0;
		col_cnt_c   = 9'b0;
		row_cnt_c   = 9'b0;
		datain_ram  = 8'b0;
		state_c     = STATE_IDLE;
	end else begin
		case(state_r)
			STATE_IDLE: begin
				addr        = 16'b0;
				writeEnable = 1'b0;
				col_cnt_c   = dim - 9'b1;
				row_cnt_c   = dim - 9'b1;
				start   = 1'b0;
				// To conserve power, consider
				//	datain_ram = datain_ram_r
				datain_ram  = 8'b0;
				if(ready) begin
					state_c = STATE_W;
				end else begin
					state_c = STATE_IDLE;
				end
			end	
			STATE_RD : begin
				addr        = addr_r + 16'b1;
				writeEnable = 1'b0;
				start       = 1'b0;
				// To conserve power, consider
				//	datain_ram = datain_ram_r
				datain_ram  = 8'b0;
				row_cnt_c = row_cnt_r;
				col_cnt_c = col_cnt_r;
				state_c = STATE_W;
			end
			STATE_W : begin
				addr        = addr_r;
				// Passthrough function
				writeEnable = 1'b1;
				datain_ram  = dataout_ram;
				if(row_cnt_r == 9'b0) begin
					row_cnt_c = dim - 9'b1;
					if(col_cnt_r == 9'b0) begin
						col_cnt_c = dim - 9'b1;
						state_c   = STATE_IDLE;
						start     = 1'b1;
					end else begin
						state_c   = STATE_RD;
						col_cnt_c = col_cnt_r - 9'b1;
						start     = 1'b0;
					end
				end else begin
					col_cnt_c = col_cnt_r;
					row_cnt_c = row_cnt_r - 9'b1;
					state_c   = STATE_RD;
					start     = 1'b0;
				end
			end
			default : begin
				state_c     = STATE_IDLE;
				addr        = 16'b0;
				writeEnable = 1'b0;
				start       = 1'b0;
				col_cnt_c   = 9'b0;
				row_cnt_c   = 9'b0;
				datain_ram  = 8'b0;
			end
		endcase
	end
end

always@(posedge clk) begin
	col_cnt_r <= col_cnt_c;
	row_cnt_r <= row_cnt_c;
	addr_r    <= addr;
	state_r   <= state_c;
end

endmodule