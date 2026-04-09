module pipelined_modified_booth_multiplier (
    input clk,
    input rst,
    input start,
    input signed [15:0] X,
    input signed [15:0] Y,
    output reg signed [31:0] result,
    output reg done
);

    // Define pipeline stages as states
    localparam IDLE     = 3'd0,
               ENCODE   = 3'd1,
               REDUCE   = 3'd2,
               FINAL_SUM= 3'd3,
               OUTPUT   = 3'd4;

    reg [2:0] state;

    // Registers for pipelining
    reg signed [15:0] X_reg, Y_reg;
    reg signed [31:0] partial_products [0:7];
    reg signed [31:0] s1, s2, s3, s4;

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= IDLE;
            X_reg      <= 16'd0;
            Y_reg      <= 16'd0;
            result     <= 32'd0;
            done       <= 1'b0;
            for (i = 0; i < 8; i = i + 1)
                partial_products[i] <= 32'd0;
            s1 <= 32'd0;
            s2 <= 32'd0;
            s3 <= 32'd0;
            s4 <= 32'd0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        X_reg <= X;
                        Y_reg <= Y;
                        state <= ENCODE;
                    end
                end
                ENCODE: begin
                    // Booth encoding and partial product generation
                    for (i = 0; i < 8; i = i + 1) begin
                        // For each group, the 3-bit pattern is formed as:
                        // {Y_reg[2*i+1], Y_reg[2*i], (i==0)? 1'b0 : Y_reg[2*i-1]}
                        case ({Y_reg[2*i+1], Y_reg[2*i], (i == 0) ? 1'b0 : Y_reg[2*i-1]})
                            3'b000, 3'b111: partial_products[i] <= 32'd0;
                            3'b001, 3'b010: partial_products[i] <= {{16{X_reg[15]}}, X_reg} << (2*i);
                            3'b011: partial_products[i] <= {{16{X_reg[15]}}, X_reg} << (2*i + 1);
                            3'b100: partial_products[i] <= -({{16{X_reg[15]}}, X_reg} << (2*i + 1));
                            3'b101, 3'b110: partial_products[i] <= -({{16{X_reg[15]}}, X_reg} << (2*i));
                            default: partial_products[i] <= 32'd0;
                        endcase
                    end
                    state <= REDUCE;
                end
                REDUCE: begin
                    // Partial product reduction: group the first six partial products
                    s1 <= partial_products[0] + partial_products[1] + partial_products[2];
                    s2 <= partial_products[3] + partial_products[4] + partial_products[5];
                    state <= FINAL_SUM;
                end
                FINAL_SUM: begin
                    // Combine the reduced sums with the remaining two partial products
                    s3 <= s1 + s2;
                    s4 <= partial_products[6] + partial_products[7];
                    state <= OUTPUT;
                end
                OUTPUT: begin
                    // Final result computation and assertion of done signal
                    result <= s3 + s4;
                    done   <= 1'b1;
                    state  <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule