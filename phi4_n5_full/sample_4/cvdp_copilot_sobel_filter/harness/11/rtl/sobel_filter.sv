module sobel_filter (
    input            clk,
    input            rst_n,
    input      [7:0] pixel_in,
    input            valid_in,
    output reg [7:0] edge_out,
    output reg       valid_out
);
    // Internal signals for gradients
    reg signed [10:0] Gx, Gy;  // To accommodate larger values after convolution
    // 3x3 pixel window buffer (row-major order: pixel_buffer[0]=top-left, ... pixel_buffer[8]=bottom-right)
    reg [7:0] pixel_buffer[0:8];
    integer i;

    // New registers for window filling and valid output hold
    reg [3:0] count;      // Counts number of pixels received in the current window
    reg [3:0] hold_count; // Holds the valid_out signal for 9 cycles after processing

    // Parameters for thresholding
    parameter THRESHOLD = 11'd128;

    // ----------------------------------------------------------------
    // Sliding window logic with counter: Only update the buffer when
    // the current window is not yet full (count < 9). When count==9,
    // the window is full and processing will occur in the next block.
    // After processing, count and the buffer are cleared.
    // ----------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
            for (i = 0; i < 9; i = i + 1)
                pixel_buffer[i] <= 8'd0;
        end else if (valid_in) begin
            if (count < 9) begin
                if (count < 8) begin
                    // Shift the window: oldest pixel is dropped
                    pixel_buffer[8] <= pixel_buffer[7];
                    pixel_buffer[7] <= pixel_buffer[6];
                    pixel_buffer[6] <= pixel_buffer[5];
                    pixel_buffer[5] <= pixel_buffer[4];
                    pixel_buffer[4] <= pixel_buffer[3];
                    pixel_buffer[3] <= pixel_buffer[2];
                    pixel_buffer[2] <= pixel_buffer[1];
                    pixel_buffer[1] <= pixel_buffer[0];
                    pixel_buffer[0] <= pixel_in;
                    count <= count + 1;
                end else if (count == 8) begin
                    // This is the 9th pixel; load it directly.
                    pixel_buffer[0] <= pixel_in;
                    count <= count + 1;
                end
            end
            // When count==9, do nothing until processing occurs.
        end
    end

    //