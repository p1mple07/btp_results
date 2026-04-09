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
    reg [7:0] pixel_buffer[0:8]; // 3x3 pixel window
    integer i;

    // Parameters for thresholding
    parameter THRESHOLD = 11'd128;

    // Sliding window logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 9; i = i + 1) begin
                pixel_buffer[i] <= 8'd0;
            end    
        end else if (valid_in) begin
            // Shift buffer for new pixel
            pixel_buffer[8] <= pixel_buffer[7];
            pixel_buffer[7] <= pixel_buffer[6];
            pixel_buffer[6] <= pixel_buffer[5];
            pixel_buffer[5] <= pixel_buffer[4];
            pixel_buffer[4] <= pixel_buffer[3];
            pixel_buffer[3] <= pixel_buffer[2];
            pixel_buffer[2] <= pixel_buffer[1];
            pixel_buffer[1] <= pixel_in;

            // Compute gradients using Sobel kernels
            Gx <= (pixel_buffer[6] * -1) + (pixel_buffer[7] * -2) + (pixel_buffer[8] * -1) +
                   (pixel_buffer[0] *  0) + (pixel_buffer[1] *  2) + (pixel_buffer[2] *  1);
            Gy <= (pixel_buffer[6] * -1) + (pixel_buffer[7] * -1) + (pixel_buffer[8] * -1) +
                   (pixel_buffer[0] * -1) + (pixel_buffer[1] *  0) + (pixel_buffer[2] *  1);

            // Compute gradient magnitude and check against threshold
            edge_out <= ((abs(Gx) + abs(Gy)) > THRESHOLD) ? 8'd255 : 8'd0;

            // Set valid output
            valid_out <= 1'b1; // Assert valid_out only once after buffer is full
        end else begin
            valid_out <= 1'b0;
        end
    end
endmodule
