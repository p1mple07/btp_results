module pipelined_modified_booth_multiplier (
    input clk,
    input rst,
    input start,
    input signed [15:0] X,
    input signed [15:0] Y,
    output reg signed [31:0] result,
    output reg done
);

    // Array to hold the eight partial products
    reg signed [31:0] partial_products [0:7];
    // Register to hold the latched inputs
    reg signed [15:0] X_reg, Y_reg;
    // 4-bit pipeline valid register:
    // Bit3: Stage 1 (Booth encoding)
    // Bit2: Stage 2 (Partial summation)
    // Bit1: Stage 3 (Sum of sums)
    // Bit0: Stage 4 (Final result)
    reg [3:0] valid;

    integer i;

    // Intermediate registers for pipelined addition stages
    reg signed [31:0] s1, s2, s3, s4;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            X_reg        <= 16'd0;
            Y_reg        <= 16'd0;
            valid        <= 4'b0000;
            done         <= 1'b0;
            result       <= 32'd0;
            s1           <= 32'd0;
            s2           <= 32'd0;
            s3           <= 32'd0;
            s4           <= 32'd0;
            for (i = 0; i < 8; i = i + 1)
                partial_products[i] <= 32'd0;
        end else begin
            if (start) begin
                // Latch inputs and initialize pipeline Stage 1
                X_reg <= X;
                Y_reg <= Y;
                valid <= 4'b1000;  // Set Stage 1 active
            end else begin
                // Shift the valid signal to the right for pipelining
                valid <= valid << 1;

                // Stage 1: Booth encoding and partial product generation
                if (valid[3]) begin
                    for (i = 0; i < 8; i = i + 1) begin
                        // Correct grouping: for i==0, group = {0, Y_reg[0], Y_reg[1]};
                        // for i>=1, group = {Y_reg[2*i-1], Y_reg[2*i], Y_reg[2*i+1]}
                        case ({ (i==0 ? 1'b0 : Y_reg[2*i-1]),
                                Y_reg[2*i],
                                Y_reg[2*i+1] })
                            3'b000, 3'b111: partial_products[i] <= 32'd0;
                            3'b001, 3'b010: partial_products[i] <= {{16{X_reg[15]}}, X_reg} << (2*i);
                            3'b011:         partial_products[i] <= {{16{X_reg[15]}}, X_reg} << (2*i + 1);
                            3'b100:         partial_products[i] <= -({{16{X_reg[15]}}, X_reg} << (2*i + 1));
                            3'b101, 3'b110: partial_products[i] <= -({{16{X_reg[15]}}, X_reg} << (2*i));
                            default:        partial_products[i] <= 32'd0;
                        endcase
                    end
                end

                // Stage 2: Partial Summation
                if (valid[2]) begin
                    s1 <= partial_products[0] + partial_products[1] + partial_products[2];
                    s2 <= partial_products[3] + partial_products[4] + partial_products[5];
                end

                // Stage 3: Sum of Sums
                if (valid[1]) begin
                    s3 <= s1 + s2;
                    s4 <= partial_products[6] + partial_products[7];
                end

                // Stage 4: Final Result
                if (valid[0]) begin
                    result <= s3 + s4;
                    done   <= 1'b1;
                end else begin
                    done <= 1'b0;
                end
            end
        end
    end

endmodule