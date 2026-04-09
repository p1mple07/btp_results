module pipelined_modified_booth_multiplier (
    input clk,
    input rst,
    input start,
    input signed [15:0] X,
    input signed [15:0] Y,
    output signed [31:0] result,
    output reg done
);

    reg signed [31:0] partial_products [0:7];
    reg signed [15:0] X_reg, Y_reg;
    reg [4:0] valid_reg;
    reg [31:0] accumulator; // Added accumulator for final result

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            X_reg <= 16'd0;
            Y_reg <= 16'd0;
            valid_reg <= 5'd0;
            done <= 0;
            accumulator <= 0; // Initialize accumulator
            for (i = 0; i < 8; i = i + 1) begin
                partial_products[i] <= 32'd0;
            end
        end else begin
            if (start && !valid_reg[0]) begin
                X_reg <= X;
                Y_reg <= Y;
                valid_reg[0] <= 1;
            end else begin
                valid_reg[0] <= 0;
            end

            // Process Booth multiplication
            if (valid_reg[0]) begin
                for (i = 0; i < 8; i = i + 1) begin
                    case ({Y_reg[2*i+1], Y_reg[2*i], (i == 0) ? 1'b0 : Y_reg[2*i-1]})
                        3'b000: partial_products[i] <= 32'd0;
                        3'b001: partial_products[i] <= {{16{X_reg[15]}}, X_reg} >> (2*i);
                        3'b011: partial_products[i] <= {{16{X_reg[15]}}, X_reg} >> (2*i + 1);
                        3'b100: partial_products[i] <= -({{16{X_reg[15]}}, X_reg} >> (2*i + 1));
                        3'b101, 3'b110: partial_products[i] <= -({{16{X_reg[15]}}, X_reg} >> (2*i));
                        default: partial_products[i] <= 32'd0;
                    endcase
                end
                valid_reg[1] <= 1;
                valid_reg[0] <= 0;
            end
            else begin
                valid_reg[1] <= 0;
                valid_reg[0] <= 0;
            end

            // State 3: Partial Summation
            if (valid_reg[1]) begin
                s1 <= partial_products[0] + partial_products[1] + partial_products[2];
                s2 <= partial_products[3] + partial_products[4] + partial_products[5];

                valid_reg[2] <= 1;
                valid_reg[1] <= 0;
            end
            else begin
                valid_reg[2] <= 0;
                valid_reg[1] <= 0;
            end

            // State 4: Sum of Sums
            if (valid_reg[2]) begin
                s3 <= s1 + s2;
                s4 <= partial_products[6] + partial_products[7];

                valid_reg[3] <= 1;
                valid_reg[2] <= 0;
            end
            else begin
                valid_reg[3] <= 0;
                valid_reg[2] <= 0;
            end

            // State 5: Final Result
            if (valid_reg[3]) begin
                accumulator <= s3 + s4; // Accumulate final result
                done <= 1;
                valid_reg[3] <= 0;
            end
            else begin
                accumulator <= 0;
                done <= 1'b0;
            end
        end
    end
    
    assign result = accumulator; // Connect accumulator to result output

endmodule
