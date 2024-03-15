module image_processor(
    input [1:0] mode,
    input [7:0] pixel_data,
    output reg [7:0] output_data
);

localparam TINT = 2'b00;
localparam INVERT = 2'b01;
localparam THRESHOLD = 2'b10;
localparam CONTRAST = 2'b11;

always@(pixel_data)begin
    case(mode)
        TINT: begin
            output_data = ((pixel_data - 64) > 0 ) ? pixel_data - 64 : 0;
        end
        INVERT: begin
            output_data = 255-pixel_data;
        end
        THRESHOLD: begin
            output_data = (pixel_data > 127) ? 255 : 0;
        end
        CONTRAST: begin
            if(pixel_data < 85) begin
                output_data = pixel_data/2;
            end else if (pixel_data < 171) begin
                output_data = 2*pixel_data - 127;
            end else begin
                output_data = (pixel_data/2) + 128;
            end
        end
    endcase
end

endmodule