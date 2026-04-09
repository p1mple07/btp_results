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

        // Compute binary output
        final_binary = intermediate_stage_1;
        valid_stage_2 = 1'b1;

        // Compute parity
        logic parity_bit = 0;
        for (int i = 0; i < WIDTH; i++) begin
            parity_bit = parity_bit ^ final_binary[i];
        end
        parity = parity_bit;

        // Compute debug mask if needed
        if (DEBUG_MODE == 1) begin
            debug_mask = ~final_binary;
        else begin
            debug_mask = final_binary;
        end
    end
endmodule