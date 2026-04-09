// Correct the map_idx initialization
always_comb begin
    genvar i;
    for (i = 0; i < N; i++) begin
        map_idx[i] = mapping_in[i*M + 1]; // Corrected line
    end
end

// Correct the error_flag logic
always_comb begin
    temp_error_flag = 1'b0;
    for (int i = 0; i < N; i++) begin
        if (map_idx[i] >= N) begin
            temp_error_flag = 1'b1;
            break; // Stop checking after the first error
        end
    end
end

// Correct the operation_reg logic for operation_mode 3'b011
always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        operation_reg <= '0;
    end else begin
        case (operation_mode)
            3'b000: operation_reg <= swizzle_reg;
            3'b001: operation_reg <= swizzle_reg;
            3'b010: for (int i = 0; i < N; i++) operation_reg[i] <= swizzle_reg[N-1-i];
            3'b011: operation_reg <= {swizzle_reg[N-2:0], swizzle_reg[N-1]}; // Corrected line
            3'b100: operation_reg <= ~swizzle_reg;
            3'b101: operation_reg <= {swizzle_reg[N-1], swizzle_reg[N]};
            3'b110: operation_reg <= {swizzle_reg[0], swizzle_reg[N-1:1]};
            default: operation_reg <= swizzle_reg;
        endcase
    end
end
