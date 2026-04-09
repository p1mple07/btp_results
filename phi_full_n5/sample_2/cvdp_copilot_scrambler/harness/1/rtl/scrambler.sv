always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        lfsr <= LFSR_INIT; // Initialize LFSR with a fixed value
    end else begin
        case (mode)
            4'b0000: lfsr = {lfsr[LFSR_WIDTH-2:0], feedback_mode0};
            4'b0001: lfsr = {lfsr[LFSR_WIDTH-2:0], feedback_mode1};
            4'b0010: lfsr = {lfsr[LFSR_WIDTH-2:0], feedback_mode2};
            4'b0011: lfsr = {lfsr[LFSR_WIDTH-2:0], feedback_mode3};
            4'b0100: lfsr = {lfsr[LFSR_WIDTH-2:0], feedback_mode4};
            4'b0101: lfsr = {lfsr[LFSR_WIDTH-2:0], feedback_mode5};
            4'b0110: lfsr = {lfsr[LFSR_WIDTH-2:0], feedback_mode6};
            4'b0111: lfsr = {lfsr[LFSR_WIDTH-2:0], feedback_mode7};
            default: lfsr = {lfsr[LFSR_WIDTH-2:0], feedback_default};
        endcase
        lfsr <= {lfsr[LFSR_WIDTH-2:0], feedback};
    end
end
