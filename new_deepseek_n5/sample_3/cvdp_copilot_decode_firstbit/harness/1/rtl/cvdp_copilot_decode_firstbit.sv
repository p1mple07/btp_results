module rtl/cvdp_copilot_decode_firstbit (
    input Clk,
    input Rst,
    input In_Data,
    input In_Valid,
    output Out_FirstBit,
    output Out_Found,
    output Out_Valid
);

    // Pad the input to the nearest power of two
    local integer padded_width = $nextpow2(InWidth_g);
    local integer num_stages = PlRegs_g;
    local integer i;

    // Create the pipeline stages
    for (i = 0; i < num_stages; i++) {
        if (i == 0) begin
            // First stage: check the least significant bit
            if (In_Data & 1) begin
                Out_FirstBit = 0;
                Out_Found = 1;
                Out_Valid = 1;
            else begin
                Out_FirstBit = 0;
                Out_Found = 0;
                Out_Valid = 0;
            end
        else begin
            // Subsequent stages: check the next bit
            if (In_Data & (1 << i)) begin
                Out_FirstBit = i;
                Out_Found = 1;
                Out_Valid = 1;
            else begin
                Out_FirstBit = 0;
                Out_Found = 0;
                Out_Valid = 0;
            end
        end
    }

    // Finalize the output
    if (Out_Found) begin
        Out_Valid = 1;
    else begin
        Out_Valid = 0;
    end

    // Reset all registers on reset
    always begin
        if (Rst) begin
            Out_FirstBit = 0;
            Out_Found = 0;
            Out_Valid = 0;
        end
    end

endmodule