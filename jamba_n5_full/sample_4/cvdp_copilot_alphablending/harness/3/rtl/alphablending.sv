module alphablending #(
    parameter H = 5,
    parameter N = 3,
    parameter W = 8
) (
    input clk,
    input reset,
    input start,
    input [(24*H*W)-1:0] pixel_in,    // N pixels, each 24-bit RGB
    input [(8*H*W)-1:0] alpha_in,     // N alpha values, each 8-bit
    input [(24*H*W)-1:0] bg_pixel_in, // N background pixels, each 24-bit RGB
    output reg [(24*H*W)-1:0] blended_out, // N blended output pixels
    output reg done
);

// State Encoding
localparam IDLE     = 2'b00;
localparam LOAD     = 2'b01;
localparam COMPUTE  = 2'b10;
localparam COMPLETE = 2'b11;
localparam STORE    = 2'b11;

reg [1:0] state, next_state;

// Registers for inputs and outputs
reg [23:0] pixel [0:H*W-1];       // Individual pixels (24-bit each)
reg [7:0] alpha [0:H*W-1];        // Individual alpha values (8-bit each)
reg [23:0] bg_pixel [0:H*W-1];    // Individual background pixels (24-bit each)
reg [23:0] blended [0:H*W-1];     // Individual blended results (24-bit each)

// Pixel count and padding logic
integer i;
integer pixel_count;
integer total_pixels;
integer padded_pixels;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        pixel_count <= 0;
        total_pixels <= 0;
        padded_pixels <= 0;
    end else if (state == IDLE && start) begin
        pixel_count <= 0;
        total_pixels <= H * W;
        padded_pixels <= (((H * W + N - 1) / N) * N) - (H * W);
    end else if (state == COMPUTE && pixel_count < total_pixels + padded_pixels) begin
        pixel_count <= pixel_count + N;
    end
end

// State Transition Logic
always @(posedge clk or posedge reset) begin
    if (reset) 
        state <= IDLE;
    else 
        state <= next_state;
end

// Next State Logic
always @(state or start) begin
    case (state)
        IDLE: next_state = (start) ? LOAD : IDLE;
        LOAD: next_state = COMPUTE;
        COMPUTE: next_state = (pixel_count < total_pixels + padded_pixels) ? LOAD : COMPLETE;
        COMPLETE: next_state = IDLE;
        STORE:  next_state = IDLE;
    endcase
end

// Alpha Blending Calculation
// Formula: blended = (alpha * pixel + (255 - alpha) * bg_pixel) / 255
always @(posedge clk) begin
    if (state == LOAD) begin
        // Unpack inputs into arrays
        for (i = 0; i < N; i = i + 1) begin
            if (pixel_count + i < total_pixels) begin
                pixel[i] <= pixel_in[(pixel_count + i)*24 +: 24];
                alpha[i] <= alpha_in[(pixel_count + i)*8 +: 8];
                bg_pixel[i] <= bg_pixel_in[(pixel_count + i)*24 +: 24];
            end 
            else begin
                pixel[i] <= 24'd0; // Pad with 0 if out of bounds
                alpha[i] <= 8'd0;
                bg_pixel[i] <= 24'd0;
            end
        end
    end
    else if (state == COMPUTE) begin
        for (i = 0; i < N; i = i + 1) begin
            blended[pixel_count + i][23:16] <= (alpha[i] * pixel[i][23:16] + (255 - alpha[i]) * bg_pixel[i][23:16]) / 255;
            blended[pixel_count + i][15:8]  <= (alpha[i] * pixel[i][15:8]  + (255 - alpha[i]) * bg_pixel[i][15:8])  / 255;
            blended[pixel_count + i][7:0]   <= (alpha[i] * pixel[i][7:0]   + (255 - alpha[i]) * bg_pixel[i][7:0])   / 255;
        end
    end
    else if (state == COMPLETE) begin
        // Pack blended results into output
        for (i = 0; i < H*W; i = i + 1) begin
            blended_out[i*24 +: 24] <= blended[i][23:0];
        end
    end
end

// Output Logic
always @(posedge clk) begin
    if (reset) begin
        done <= 0;
        blended_out <= 0;
    end
    else if (state == COMPLETE) begin
        done <= 1;
    end
    else begin
        done <= 0;
    end
end

endmodule
