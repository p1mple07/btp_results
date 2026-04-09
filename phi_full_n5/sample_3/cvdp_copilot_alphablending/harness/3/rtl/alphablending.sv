
// ...

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
        // Update pixel_count and total_pixels
        pixel_count <= pixel_count + N;
        total_pixels <= total_pixels + N;

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

        // Synchronously set done
        done <= 1;
    end
end

// Output Logic
always @(posedge clk) begin
    if (reset) begin
        blended_out <= '0;
        done <= 0;
    end
    else if (state == COMPLETE) begin
        done <= 1;
    end
end

// ...
