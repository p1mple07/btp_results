module restoring_division #(
    type WIDTH = 6
)(
    input clk,
    input rst,
    input start,
    input [WIDTH-1:0] dividend,
    input [WIDTH-1:0] divisor,
    output reg [WIDTH-1:0] quotient,
    output reg [WIDTH-1:0] remainder,
    output reg valid
);

    // Internal registers
    reg [WIDTH-1:0] internal_remainder;
    reg [WIDTH-1:0] temp_divisor;
    reg [WIDTH-1:0] temp_quotient;

    initial begin
        internal_remainder = 0;
        temp_divisor = divisor;
        temp_quotient = 0;
    end

    always @(posedge clk or posedge rst) begin
        if (~rst) begin
            internal_remainder <= 0;
            temp_divisor <= divisor;
            temp_quotient <= 0;
        end else if (start) begin
            internal_remainder <= 0;
            temp_divisor <= divisor;
            temp_quotient <= 0;
        end
    end

    always @(posedge clk) begin
        if (valid && ~rst) begin
            // Check if we are still processing
            if (internal_remainder == 0) begin
                valid <= 0;
            end else begin
                valid <= 1;
            end
        end
    end

    always @(posedge clk) begin
        if (valid && start) begin
            // Process the division
            internal_remainder = internal_remainder << 1;
            internal_remainder[WIDTH-1] = 1; // shift left and append MSB

            temp_divisor_new = temp_divisor;
            temp_quotient = 0;

            // Subtract
            temp_quotient = (internal_remainder[WIDTH-1] == 1) ? 0 : 1;
            if (temp_quotient == 1) begin
                internal_remainder = internal_remainder ^ temp_divisor;
            end else begin
                internal_remainder = internal_remainder ^ (temp_divisor << 1);
            end

            // Continue
            repeat((WIDTH-1) - current_shift_position) {
                // Wait, this part might be complex.
            }
        end
    end

endmodule
