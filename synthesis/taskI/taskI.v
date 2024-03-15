
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module taskI(

	//////////// CLOCK //////////
	input 		          		ADC_CLK_10,
	input 		          		MAX10_CLK1_50,
	input 		          		MAX10_CLK2_50,

	//////////// SEG7 //////////
	output		     [7:0]		HEX0,
	output		     [7:0]		HEX1,
	output		     [7:0]		HEX2,
	output		     [7:0]		HEX3,
	output		     [7:0]		HEX4,
	output		     [7:0]		HEX5,

	//////////// KEY //////////
	input 		     [1:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input 		     [9:0]		SW
);



//=======================================================
//  REG/WIRE declarations
//=======================================================
wire
	writeEnable,
	start,
	ready;
wire [15:0]
	addr;
wire [7:0]
	datain,
    dataout;
wire [8:0]
	dim;



//=======================================================
//  Structural coding
//=======================================================

// Part I instance should go here!
fsm_controller FSM(
	.clk(MAX10_CLK1_50),
	.rst(KEY[0]),
	.ready(ready),
	.writeEnable(writeEnable),
	.start(start),
	.pixel_data(dataout),
	.data_to_write(datain),
	.address(addr),
	.dim(dim)
);

// Do not touch
jtag_to_onchipmem_handler uHandler(
	.clk(MAX10_CLK1_50),
	.rst_n(KEY[0]),
	.writeEnable(writeEnable),
	.start(start),
	.addr(addr),
	.datain(datain),
    .dataout(dataout),
	.ready(ready),
	.dim(dim)
);

endmodule
