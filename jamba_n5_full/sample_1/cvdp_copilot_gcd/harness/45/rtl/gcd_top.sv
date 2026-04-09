module gcd_top (#(...)) (
    input clk,
    input rst,
    input A,
    input B,
    input go,
    output OUT,
    output done
);

    logic eq;
    logic [1:0] control_state;
    logic [WIDTH-1:0] a_ff, b_ff, out_ff;
    logic [WIDTH-1:0] next_a_ff, next_b_ff, next_out;
    logic [WIDTH-1:0] next_k_ff;

    always_ff @(posedge clk) begin
        if (rst) begin
            A <= 1'b0;
            B <= 1'b0;
            eq <= 1'b0;
            OUT <= 1'b0;
            done <= 1'b0;
        end else begin
            if (A == B) begin
                done <= 1'b1;
            end else begin
                // handle other cases
            end
        end
    end

endmodule
