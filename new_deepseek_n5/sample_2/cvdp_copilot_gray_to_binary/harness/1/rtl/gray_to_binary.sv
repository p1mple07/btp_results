module gray_to_binary #(
    parameter WIDTH      = 4,
    parameter DEBUG_MODE = 0
) (
    input  logic [WIDTH-1:0] gray_in,
    output logic [WIDTH-1:0] binary_out,
    output logic [WIDTH-1:0] debug_mask,
    output logic             parity,
    output logic             valid

    logic [WIDTH-1:0] intermediate_stage_1;
    logic [WIDTH-1:0] intermediate_stage_2;
    logic [WIDTH-1:0] masked_output;
    logic [WIDTH-1:0] final_binary;
    logic             valid_stage_1;
    logic             valid_stage_2;

    always @* begin
        intermediate_stage_1[WIDTH-1] = gray_in[WIDTH-1];
        for (int i = WIDTH - 2; i >= 0; i--) begin
            intermediate_stage_1[i] = intermediate_stage_1[i+1] ^ gray_in[i];
        end
        valid_stage_1 = 1'b1;

        // Debugging and masking
        masked_output = (DEBUG_MODE == 1) ? (~binary_out) : (0);

        // Final outputs
        final_binary = binary_out;
        binary_out = masked_output;
        parity = 0;
        for (int i = 0; i < WIDTH; i++) {
            parity ^= binary_out[i];
        }
        valid = 1'b1;
    end
endmodule