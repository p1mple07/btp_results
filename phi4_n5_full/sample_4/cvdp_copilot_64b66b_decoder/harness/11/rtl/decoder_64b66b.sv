rtl/decoder_64b66b.sv
--------------------------------------------------
module decoder_64b66b (
    input  logic         clk_in,              // Clock signal
    input  logic         rst_in,              // Asynchronous reset (active high)
    input  logic         decoder_data_valid_in, // Input data valid signal
    input  logic [65:0]  decoder_data_in,     // 66-bit encoded input
    output logic [63:0]  decoder_data_out,    // Decoded 64-bit data output
    output logic [7:0]   decoder_control_out, // Decoded 8-bit control output
    output logic         sync_error,          // Sync error flag
    output logic         decoder_error_out    // Type field error flag
);

    // Internal signals
    logic [1:0]   sync_header;
    logic [7:0]   type_field;
    logic [63:0]  data_in;
    logic         type_field_valid;
    logic         decoder_wrong_ctrl_received;
    logic         decoder_wrong_type_field;

    // Extract fields from input
    assign sync_header = decoder_data_in[65:64];
    assign type_field  = decoder_data_in[63:56];
    assign data_in     = decoder_data_in[55:0];

    // Default assignments
    // Note: When errors occur or input not valid, outputs are forced to 0.
    // The error flags are set accordingly.
    //
    // Control characters definitions:
    //   /I/ (Idle)          = 8'h07
    //   /S/ (Start of Frame)= 8'hFB
    //   /T/ (End of Frame)  = 8'hFD
    //   /E/ (Error)         = 8'hFE
    //   /Q/ (Ordered Set)   = 8'h9C

    always_comb begin
        // Default values: outputs zero, errors off.
        decoder_data_out      = 64'h0000000000000000;
        decoder_control_out   = 8'h00000000;
        sync_error            = 1'b0;
        decoder_error_out     = 1'b0;
        decoder_wrong_ctrl_received = 1'b0;
        type_field_valid      = 1'b0;

        // If input is not valid, do nothing.
        if (!decoder_data_valid_in) begin
            return;
        end

        // Check sync header: valid only if 2'b01 (Data-only) or 2'b10 (Control/Mixed mode)
        if (sync_header != 2'b01 && sync_header != 2'b10) begin
            sync_error = 1'b1;
            return;
        end

        // Check if type field is one of the valid fields.
        case (type_field)
            8'h1E, 8'h33, 8'h78, 8'h87, 8'h99, 8'hAA, 8'hB4, 8'hCC,
            8'hD2, 8'hE1, 8'hFF, 8'h2D, 8'h4B, 8'h55, 8'h66: 
                type_field_valid = 1'b1;
            default: 
                type_field_valid = 1'b0;
        endcase

        // If type field is invalid, set decoder error.
        if (!type_field_valid) begin
            decoder_error_out = 1'b1;
            return;
        end

        // Decode based on the type field.
        // Note: The data_in (64 bits) is assumed to be organized as:
        //   d6 = data_in[55:48]
        //   d5 = data_in[47:40]
        //   d4 = data_in[39:32]
        //   d3 = data_in[31:24]
        //   d2 = data_in[23:16]
        //   d1 = data_in[15:8]
        //   d0 = data_in[7:0]
        unique case (type_field)
            8'h1E: begin
                decoder_control_out = 8'hFF; // 11111111
                // All bytes are error control (/E/ = 0xFE)
                decoder_data_out = {8'hFE, 8'hFE, 8'hFE, 8'hFE,
                                    8'hFE, 8'hFE, 8'hFE, 8'hFE};
            end
            8'h33: begin
                decoder_control_out = 8'h1F; // 00011111
                // {D6, D5, D4, S4, I3, I2, I1, I0}
                decoder_data_out = {data_in[55:48], data_in[47:40], data_in[39:32],
                                    8'hFB, 8'h07, 8'h07, 8'h07, 8'h07};
            end
            8'h78: begin
                decoder_control_out = 8'h01; // 00000001
                // {D6, D5, D4, D3, D2, D1, D0, S0}
                decoder_data_out = {data_in[55:48], data_in[47:40], data_in[39:32],
                                    data_in[31:24], data_in[23:16], data_in[15:8],
                                    data_in[7:0], 8'hFB};
            end
            8'h87: begin
                decoder_control_out = 8'hFE; // 11111110
                // {I7, I6, I5, I4, I3, I2, I1, T0}
                decoder_data_out = {8'h07, 8'h07, 8'h07, 8'h07,
                                    8'h07, 8'h07, 8'h07, 8'hFD};
            end
            8'h99: begin
                decoder_control_out = 8'hFE; // 11111110
                // {I7, I6, I5, I4, I3, I2, T1, D0}
                decoder_data_out = {8'h07, 8'h07, 8'h07, 8'h07,
                                    8'h07, 8'h07, 8'hFD, data_in[7:0]};
            end
            8'hAA: begin
                decoder_control_out = 8'hFC; // 11111100
                // {I7, I6, I5, I4, I3, T2, D1, D0}
                decoder_data_out = {8'h07, 8'h07, 8'h07, 8'h07,
                                    8'h07, 8'hFD, data_in[15:8], data_in[7:0]};
            end
            8'hB4: begin
                decoder_control_out = 8'hF8; // 11111000
                // {I7, I6, I5, I4, T3, D2, D1, D0}
                decoder_data_out = {8'h07, 8'h07, 8'h07, 8'h07,
                                    8'hFD, data_in[23:16], data_in[15:8], data_in[7:0]};
            end
            8'hCC: begin
                decoder_control_out = 8'hF0; // 11110000
                // {I7, I6, I5, T4, D3, D2, D1, D0}
                decoder_data_out = {8'h07, 8'h07, 8'h07,
                                    8'hFD, data_in[31:24], data_in[23:16], data_in[15:8], data_in[7:0]};
            end
            8'hD2: begin
                decoder