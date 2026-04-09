module rtl/cvdp_copilot_decode_firstbit (
    input Clk, Rst,
    input In_Data, In_Valid,
    output Out_FirstBit, Out_Found, Out_Valid
);

    // Calculate next power of two for padding
    integer padded_width;
    padded_width = 1;
    while (padded_width < InWidth_g) {
        padded_width = padded_width << 1;
    }

    // Variables for the decoding logic
    integer first_bit;
    integer bit;
    integer i;
    bit valid;
    bit found;
    bit valid_out;
    bit found_out;
    bit first_bit_out;

    // Pipeline registers
    register [padded_width - 1:0] pipeline_reg;
    register [padded_width - 1:0] pipeline_reg_next;

    // Control signals for pipeline stages
    output reg [0:PlRegs_g-1] stage_valid;
    output reg [0:PlRegs_g-1] stage_found;

    // Initialize pipeline registers
    pipeline_reg = (In_Data & In_Valid) ? (In_Data >> (padded_width - 1)) : 0;
    pipeline_reg_next = pipeline_reg;

    // Loop to find the first set bit
    for (i = 0; i < padded_width; i++) {
        bit valid = (In_Data & (1 << i)) & In_Valid;
        bit found = !found;

        if (valid) {
            first_bit = i;
            found = 1;
        }

        // Propagate through pipeline stages
        for (bit = 0; bit < PlRegs_g; bit++) {
            stage_valid[bit] = valid;
            stage_found[bit] = found;
            // Shift the value to the next stage
            if (bit < PlRegs_g - 1) {
                pipeline_reg_next = pipeline_reg;
                pipeline_reg = pipeline_reg_next;
            }
        }

        // Update outputs
        Out_FirstBit = first_bit;
        Out_Found = found;
        Out_Valid = valid;

        // Reset for next iteration
        pipeline_reg = (In_Data & (1 << i)) & In_Valid;
        pipeline_reg_next = pipeline_reg;
    }

    // Reset the pipeline
    if (Rst) {
        pipeline_reg = 0;
        pipeline_reg_next = 0;
        Out_FirstBit = 0;
        Out_Found = 0;
        Out_Valid = 0;
    }

endmodule