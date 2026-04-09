module sobel_filter (
    input            clk,
    input            rst_n,
    input      [7:0] pixel_in,
    input            valid_in,
    output reg [7:0] edge_out
);
    // Internal signals for gradients
    reg signed [16:0] Gx, Gy;
    reg [7:0] pixel_buffer[0:8];

    // Parameters for thresholding
    parameter THRESHOLD = 11'd128;

    // Sliding window logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < 9; i = i + 1) begin
                pixel_buffer[i] <= 8'd0;
            end    
        end else if (valid_in) begin
            // Compute Gx and Gy correctly
            Gx = (-pixel_buffer[6]) 
                + pixel_buffer[8] 
                - (pixel_buffer[3] << 1) 
                + (pixel_buffer[5] << 1) 
                - pixel_buffer[0] 
                + pixel_buffer[2];
            
            Gy = (-pixel_buffer[6]) 
                - (pixel_buffer[7] << 1) 
                - pixel_buffer[8] 
                + (pixel_buffer[0] << 1) 
                + (pixel_buffer[1] << 1) 
                + pixel_buffer[2];
            
            // Compute absolute values
            Gx = (Gx < 0) ? (-Gx) : Gx;
            Gy = (Gy < 0) ? (-Gy) : Gy;
            
            // Sum the absolute values
            edge_out <= (Gx + Gy) > THRESHOLD ? 8'd255 : 8'd0;
        end else begin
            valid_out <= 1'b0;
        end
    end

    // Assert valid_out after 9 clock cycles
    valid_out <= 1'b1;
    // Wait for 9 clock cycles
    for (i = 0; i < 9; i = i + 1) begin
        valid_out <= 1'b1;
    end    
    valid_out <= 1'b0;
endmodule