module sobel_filter (
    input            rst_n,
    input            pixel_in,
    input          [7:0] edge_out,
    output reg       valid_out
);
    // Internal signals for gradients
    reg signed [10:0] Gx, Gy;  // To accommodate larger values after convolution
    reg [7:0] pixel_buffer [0:8]; // 3x3 pixel window
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
            // Shift new pixel into buffer
            pixel_buffer[8] <= pixel_in;
            // Shift other pixels to make space
            pixel_buffer[7] <= pixel_buffer[8];
            pixel_buffer[6] <= pixel_buffer[7];
            pixel_buffer[5] <= pixel_buffer[6];
            pixel_buffer[4] <= pixel_buffer[5];
            pixel_buffer[3] <= pixel_buffer[4];
            pixel_buffer[2] <= pixel_buffer[3];
            pixel_buffer[1] <= pixel_buffer[2];
            pixel_buffer[0] <= pixel_buffer[1];
            
            // Compute Gx and Gy using Sobel kernels
            Gx <= (
                -pixel_buffer[0] + pixel_buffer[2] 
                - pixel_buffer[3] + pixel_buffer[5] 
                - pixel_buffer[6] + pixel_buffer[8]
            );
            Gy <= (
                -pixel_buffer[0] - 2'<<pixel_buffer[3] - pixel_buffer[6] 
                + pixel_buffer[1] + 2'<<pixel_buffer[4] + pixel_buffer[7] 
                + pixel_buffer[2] + 2'<<pixel_buffer[5] + pixel_buffer[8]
            );
            
            // Compute gradient magnitude and compare to threshold
            edge_out <= (
                ( (Gx < 0 ? -Gx : Gx) + (Gy < 0 ? -Gy : Gy) ) > THRESHOLD
            ) ? 8'd255 : 8'd0;
        end
    end
endmodule