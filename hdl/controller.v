module controller(
    input clk, rst, ready,
    input [7:0] pixel_data,
    input [8:0] dim,
    output reg writeEnable, start,
    output reg [15:0] address,
    output reg [7:0] data_to_write
);

localparam IDLE = 2'b00;
localparam READ = 2'b01;
localparam WRITE = 2'b10;

reg [1:0] state, next_state;
reg [8:0] col, col_next, row, row_next;
reg [15:0] address_next;

always @(*) begin
    case(state)
        IDLE: begin
            address = 0;
            writeEnable = 0;
            start = 0;
            row_next = dim-1;
            col_next = dim-1;
            data_to_write = 0;
            if(ready) begin
                next_state = WRITE;
            end else begin
                next_state = IDLE;
            end
        end
        WRITE: begin
            address = address_next;
            writeEnable = 1;
            data_to_write = pixel_data + 1;
			if(row == 0) begin
				row_next = dim-1;
				if(col == dim) begin
					col_next = dim - 1;
					next_state = IDLE;
					start     = 1'b1;
				end else begin
					next_state= READ;
					col_next = col - 1;
					start     = 1'b0;
				end
			end else begin
                col_next = col;
                row_next = row - 1;
				next_state= READ;
				start     = 1'b0;
			end
        end

        READ: begin
            writeEnable = 0;
            row_next = row ;
            col_next = col;
            next_state = WRITE;
            address = address_next + 1;
            data_to_write = 0;
            start = 0;
        end
    endcase
end

always @(posedge clk) begin
    if(!rst) begin
        state <= IDLE;
        row <= 0;
        col <= 0;
        start <= 0;
        writeEnable <= 0;
    end else begin
        state <= next_state;
        col <= col_next;
        row <= row_next;
        address_next <= address;
    end
end 

endmodule