module pipelined_modified_booth_multiplier (
    input clk,
    input rst,
    input start,
    input signed [15:0] X,
    input signed [15:0] Y,
    output reg signed [31:0] result,
    output reg done
);

    // Storage for the eight partial products.
    reg signed [31:0] partial_products [0:7];
    // Latched inputs.
    reg signed [15:0] X_reg, Y_reg;
    // Pipeline state register:
    //  0: Idle, 1: Booth encoding, 2: Partial Summation, 3: Sum of Sums, 4: Final Result.
    reg [2:0] state;
    integer i;

    // Registers for intermediate sums.
    reg signed [31:0] s1, s2, s3, s4;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            X_reg      <= 16'd0;
            Y_reg      <= 16'd0;
            state      <= 3'd0;
            done       <= 1'b0;
            for (i = 0; i < 8; i = i + 1)
                partial_products[i] <= 32'd0;
            s1 <= 32'd0; s2 <= 32'd0; s3 <= 32'd0; s4 <= 32'd0;
            result <= 32'd0;
        end else begin
            case (state)
                3'd0: begin
                    // Wait for the start signal.
                    if (start) begin
                        X_reg <= X;
                        Y_reg <= Y;
                        state <= 3'd1;
                    end
                end
                3'd1: begin
                    // Stage 1: Booth encoding and partial product generation.
                    // The multiplier Y_reg is divided into overlapping groups of 3 bits.
                    // For i=0, the group is {Y_reg[1], Y_reg[0], 1'b0}.
                    // For i>=1, the group is {Y_reg[2*i+1], Y_reg[2*i], Y_reg[2*i-1]}.
                    for (i = 0; i < 8; i = i + 1) begin
                        // Build the 3-bit group.
                        bit3 = (i == 0) ? 1'b0 : Y_reg[2*i-1];
                        case ({Y_reg[2*i+1], Y_reg[2*i], bit3})
                            // 000 and 111: No operation (0).
                            3'b000, 3'b111: partial_products[i] <= 32'd0;
                            // 001 or 010: Add the multiplicand (+X).
                            3'b001, 3'b010: partial_products[i] <= $signed({{16{X_reg[15]}}, X_reg}) << (2*i);
                            // 011: Add twice the multiplicand (+2X).
                            3'b011: partial_products[i] <= $signed({{16{X_reg[15]}}, X_reg}) << (2*i + 1);
                            // 100: Subtract twice the multiplicand (-2X).
                            3'b100: partial_products[i] <= -($signed({{16{X_reg[15]}}, X_reg}) << (2*i + 1));
                            // 101 or 110: Subtract the multiplicand (-X).
                            3'b101, 3'b110: partial_products[i] <= -($signed({{16{X_reg[15]}}, X_reg}) << (2*i));
                            default: partial_products[i] <= 32'd0;
                        endcase
                    end
                    state <= 3'd2;
                end
                3'd2: begin
                    // Stage 2: Partial Summation.
                    // Sum the first six partial products in two groups.
                    s1 <= partial_products[0] + partial_products[1] + partial_products[2];
                    s2 <= partial_products[3] + partial_products[4] + partial_products[5];
                    state <= 3'd3;
                end
                3'd3: begin
                    // Stage 3: Sum of Sums.
                    // Combine the two intermediate sums with the remaining partial products.
                    s3 <= s1 + s2;
                    s4 <= partial_products[6] + partial_products[7];
                    state <= 3'd4;
                end
                3'd4: begin
                    // Stage 4: Final Result.
                    // Add the two final partial sums to obtain the 32‐bit result.
                    result <= s3 + s4;
                    done  <= 1'b1;
                    state <= 3'd0;
                end
                default: state <= 3'd0;
            endcase
        end
    end

endmodule