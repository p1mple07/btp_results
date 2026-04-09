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

// Constants
localparam IDLE     = 2'b00;
localparam LOAD     = 2'b01;
localparam COMPUTE  = 2'b10;
localparam COMPLETE = 2'b11;

// Registers for inputs and outputs
reg [23:0] pixel [(N-1):0];      // Individual pixels (24-bit each)
reg [7:0] alpha [(N-1):0];       // Individual alpha values (8-bit each)
reg [23:0] bg_pixel [(N-1):0]; // Individual background pixels (24-bit each)
reg [23:0] blended [(N-1):0];  // Individual blended results (24-bit each)

// Pixel count and padding logic
integer i;
integer pixel_count;
integer total_pixels;
integer padded_pixels;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        pixel_count <= 0;
        total_pixels <= H * W;
        padded_pixels <= (((H * W + N - 1) / N) * N) - (H * W);
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
always @(posedge clk or posedge reset) begin
    case (state)
        IDLE: next_state = (start)? LOAD : IDLE;
        LOAD: next_state = COMPUTE;
        COMPUTE: next_state = (pixel_count < total_pixels + padded_pixels)? LOAD : COMPLETE;
        COMPLETE: next_state = IDLE;
        STORE:  next_state = IDLE;
    endcase
end

// Alpha Blending Calculation
// Formula: blended = (alpha * pixel + (255 - alpha) * bg_pixel
always @(posedge clk) begin
    if (state == LOAD) begin
        // Unpack inputs into arrays
        for (i = 0; i < N; i = i +1) begin
            pixel[i] <= pixel_in[(pixel_count+i)*24 +: 24];
            alpha[i] <= alpha_in[(pixel_count+i)*8 +: 8];
            bg_pixel[i] <= bg_pixel_in[(pixel_count+i)*24 +: 24];
        end
    else if (state == COMPUTE) begin
        for (i = 0; i < N; i = i +1) begin
            blended[pixel_count+i][23:0] <= (alpha[i][23:0] * pixel[i][23:0] + (255-alpha[i][23:0] in parallel
begin
    blended[i] <= (alpha[i] * pixel[i].
end

end

code

#### Compute Algorithm

#### Compute Algorithm

##### 1.

This code for the Load Algorithm and the Compute Algorithm.

There are two files, respectively, for example, 1.

* `rtl/load.sv`: