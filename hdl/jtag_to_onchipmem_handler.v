module jtag_to_onchipmem_handler(
	//=======================================================
	//  May be used for Part I-III
	//	-	Can only support an 8-bit Part III (single lane)
	//=======================================================
	input
		clk,
		rst_n,
		writeEnable,
		start,
	input [15:0]
		addr,
	input [7:0]
		datain,
    output [7:0]
    	dataout,
	output
		ready,
	output [8:0]
		dim,

	//=======================================================
	//  Used for Part II - Other parts you may leave discon.
	//=======================================================
	output [1:0]
		mode,

	//=======================================================
	//  Used for Part III - Other parts you may leave discon.
	//=======================================================
	output [5:0]
		hist_bins, // Up to 64 bins are supported
	input [5:0]
		addr_hist,
	input
		writeEnable_hist,
	input [31:0]
		datain_hist,

	//=======================================================
	//  Not needed in any part - You may leave disconnected
	//=======================================================
	output [31:0]
		dataout_hist
);

reg 
	ready_out, ready_last;
wire [15:0] 
	avmm_pix_ram_address;
wire        
	avmm_pix_ram_chipselect;
wire        
	avmm_pix_ram_write;
wire [7:0]  
	avmm_pix_ram_readdata;
wire [7:0]  
	avmm_pix_ram_writedata;

wire [31:0] 
	dim_export,	
	ram_ready_export,
	mode_export,
	hist_bins_export;

reg [31:0]
	start_transfer_export;

assign mode = mode_export[1:0];
assign hist_bins = hist_bins_export[5:0];

// Assign address signal
assign avmm_pix_ram_address = addr;

// When RAM is loaded either read or write every cycle
assign avmm_pix_ram_chipselect = ready_out;
assign avmm_pix_ram_write = writeEnable;

// Assign data signals
assign dataout = avmm_pix_ram_readdata;
assign avmm_pix_ram_writedata = datain;

// Assign dimension status reg - maximum 512x512 image
assign dim = dim_export[8:0];

// Assign ready signal 
assign ready = ready_out;

// Simple FSM to allow 1-cycle start and safe ready input
always@(posedge clk) begin
	if(!rst_n) begin
		start_transfer_export <= 32'b0;
		ready_out <= 1'b0;
	// Ready goes low immediately following start = 1'b1 during operation
	end else if(ready_out == 1'b1 && start == 1'b1) begin
		start_transfer_export <= 32'b1;
		ready_out <= 1'b0;
	// Detect rising edge on ready from host
	end else if(ready_last == 1'b0 && ram_ready_export[0] == 1'b1) begin
		start_transfer_export <= 32'b0;
		ready_out <= 1'b1;
	end else if(ram_ready_export[0] == 1'b0) begin
		start_transfer_export <= 32'b0;
		ready_out <= 1'b0;
	end
	ready_last <= ram_ready_export[0];
end

jtag_to_onchipmem u0 (
	.avmm_pix_ram_address    (avmm_pix_ram_address),
	.avmm_pix_ram_chipselect (avmm_pix_ram_chipselect),
	.avmm_pix_ram_clken      (ready_out),
	.avmm_pix_ram_write      (avmm_pix_ram_write),
	.avmm_pix_ram_readdata   (avmm_pix_ram_readdata),
	.avmm_pix_ram_writedata  (avmm_pix_ram_writedata),
	.clk_clk                 (clk),
	.dim_export              (dim_export),
	.ram_ready_export        (ram_ready_export),
	.reset_reset_n           (rst_n),
	.start_transfer_export   (start_transfer_export),
	.mode_export             (mode_export),
	.hist_bins_export        (hist_bins_export),
	.hist_ram_address        (addr_hist),
	.hist_ram_chipselect     (ready),
	.hist_ram_clken          (ready_out),
	.hist_ram_write          (writeEnable_hist),
	.hist_ram_readdata       (dataout_hist),
	.hist_ram_writedata      (datain_hist),
	.hist_ram_byteenable     (4'b1111)
);

endmodule