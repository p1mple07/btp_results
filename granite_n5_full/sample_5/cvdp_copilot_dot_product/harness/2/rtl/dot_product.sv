always @(posedge clk_in or posedge reset_in) begin
        if (reset_in == 1'b1) begin
            state <= IDLE;
            dot_product_out <= 32'h00000000;
            dot_product_valid_out <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (start_in == 1'b1) begin
                        state <= COMPUTE;
                    end
                end
                COMPUTE: begin
                    // Implement dot product computation here
                end
                OUTPUT: begin
                    // Assign dot product result and set valid signal
                    state <= IDLE;
                end
            endcase
        end
    end