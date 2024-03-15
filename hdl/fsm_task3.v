module fsm_controller(
    input clk, rst, ready,
    input [31:0] pixel_data,
    input [8:0] dim,
    input [5:0] hist_bins,
    output reg writeEnable_hist, start,
    output reg [5:0] addr_hist,
    output reg [31:0] datain_hist,
    output reg [13:0] pixel_address
);

localparam IDLE = 2'b00;
localparam COMPUTE = 2'b01;
localparam WRITE = 2'b10;
localparam CLEAR = 2'b11;

integer ct;

reg enable_compute;
reg [1:0] state, next_state;
reg [8:0] col, next_col, row, next_row;
reg [13:0] next_pixel_address;
reg [5:0] hist_adress_next;
reg [13:0] hist_data [63:0];
wire [5:0] compute_outputs [3:0];
reg [5:0] counter_bins, next_counter_bins;

/// Ghetto janky and I hate this
reg [5:0] compute_1, compute_2, compute_3, compute_4;
wire [5:0] compute_1_next, compute_2_next, compute_3_next, compute_4_next;

integer j;

initial begin
    for (ct = 0; ct < 897; ct = ct + 1) begin
        hist_data[ct] <= 14'b0; 
    end
end

always @(posedge clk) begin
    if(!rst) begin 
        state <= IDLE;
        row <= 0;
        col <= 0;
        for(j = 0; j < 64; j = j + 1) begin
            hist_data[j] = 14'b0;
        end
    end else begin 
        addr_hist <= hist_adress_next;
        state <= next_state;
        row <= next_row;
        col <= next_col;
        next_pixel_address <= pixel_address;
        counter_bins <= next_counter_bins;
        compute_1 <= compute_1_next;
        compute_2 <= compute_2_next;
        compute_3 <= compute_3_next;
        compute_4 <= compute_4_next;
    end
end

always @(*) begin
    case (state)
        IDLE: begin
            writeEnable_hist = 0;
            start = 0;
            addr_hist = 0;
            next_col = 0;
            next_row = 0;
            datain_hist = 0;
            pixel_address = 0;
            next_counter_bins = 0;
            hist_adress_next = 0;
            enable_compute = 0;
            if(ready) begin
                next_state = COMPUTE;
                enable_compute = 1;
            end else begin
                next_state = IDLE;
            end
        end
        COMPUTE: begin
            // collect computer  
            
            hist_data[compute_1] = hist_data[compute_1] + 1;
            hist_data[compute_2] = hist_data[compute_2] + 1;
            hist_data[compute_3] = hist_data[compute_3] + 1;
            hist_data[compute_4] = hist_data[compute_4] + 1;
            // put counter
            pixel_address = next_pixel_address + 1;
            if(row == (dim >> 2)-1) begin
                next_row = 0;
                if(col == dim) begin
                    next_col = 0;
                    next_state = WRITE;
                    writeEnable_hist = 1;
                end else begin
                    next_state = COMPUTE;
                    next_col = col + 1;
                end
            end else begin
                    next_state = COMPUTE;
                    // start = 1'b0;
                    next_col = col;
                    next_row = row + 1;
            end
        end
        WRITE: begin
            enable_compute = 0;
            datain_hist = hist_data[counter_bins];
            if(counter_bins < hist_bins) begin
                hist_adress_next = addr_hist + 1;
                hist_data[counter_bins] = 0;
            end else begin
                start = 1;
                next_state = IDLE;
            end
            next_counter_bins = counter_bins + 1;
        end


    endcase 
end

hist_compute goku1(
            .enable(enable_compute),
            .reset(rst),
            .clk(clk),
            .pixel(pixel_data[7:0]),
            .pix_address(pixel_address),
            .hist_bin(compute_1_next)
);
hist_compute goku2(
            .enable(enable_compute),
            .reset(rst),
            .clk(clk),
            .pixel(pixel_data[15:8]),
            .pix_address(pixel_address),
            .hist_bin(compute_2_next)
);
hist_compute goku3(
            .enable(enable_compute),
            .reset(rst),
            .clk(clk),
            .pixel(pixel_data[23:16]),
            .pix_address(pixel_address),
            .hist_bin(compute_3_next)
); 
hist_compute goku4(
            .enable(enable_compute),
            .reset(rst),
            .clk(clk),
            .pixel(pixel_data[31:24]),
            .pix_address(pixel_address),
            .hist_bin(compute_4_next)
);

endmodule;