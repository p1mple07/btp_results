module sobel_filter (
    input            clk,
    input            rst_n,
    input      [7:0] pixel_in,
    output reg [7:0] edge_out
);

    // Internal signals for gradients
    reg unsigned [15:0] Gx, Gy;
    integer buffer_index;
    reg [7:0] pixel_buffer[0:8];

    // Parameters for thresholding
    parameter THRESHOLD = 128;

    // Calculate Gx and Gy using Sobel kernels
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 9; i = i + 1) begin
                pixel_buffer[i] <= 8'd0;
            end    
        end else if (valid_in) begin
            // Compute Gx
            Gx = (-pixel_buffer[0]) + pixel_buffer[2] 
                - 2 * pixel_buffer[3] 
                + 2 * pixel_buffer[5] 
                - pixel_buffer[6] 
                + pixel_buffer[8];
            // Compute Gy
            Gy = (-pixel_buffer[0]) 
                - 2 * pixel_buffer[1] 
                - pixel_buffer[2] 
                + pixel_buffer[6] 
                + 2 * pixel_buffer[7] 
                + pixel_buffer[8];
            // Compute edge magnitude
            edge_out = Gx + Gy;
            if (edge_out > 128) edge_out <= 8'd255;
            valid_out <= 1'b1;
        end else begin
            valid_out <= 1'b0;
        end
    end

    // Reset the buffer when rst_n is asserted
    always @* valid_in begin
        if (rst_n) begin
            for (i = 0; i < 9; i = i + 1) begin
                pixel_buffer[i] <= 8'd0;
            end    
        end
    end
endmodule