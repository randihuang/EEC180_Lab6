module hist_compute(
    input enable, reset, clk,
    input [7:0] pixel,
    input [13:0] pix_address,
    output reg [5:0] hist_bin
);

always@(pixel) begin
    if(enable) begin
        hist_bin = pixel >> 5;
    end 
end

endmodule