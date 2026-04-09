module decoder_64b66b (
    input  logic         clk_in,
    input  logic         rst_in,
    input  logic         decoder_data_valid_in,
    input  logic [65:0]  decoder_data_in,
    output logic [63:0]  decoder_data_out,
    output logic [7:0]   decoder_control_out,
    output logic         sync_error,
    output logic         decoder_error_out
);

    localparam sync_bits = 2'b01;
    localparam valid_types = {0x1E, 0x33, 0x78, 0x87, 0x99, 0xAA, 0xB4, 0xCC, 0xD2, 0xE1, 0xFF, 0x2D, 0x4B, 0x55, 0x66};

    assign sync_header = decoder_data_in[65:64];
    assign type_field = decoder_data_in[63:56];
    assign data_in = decoder_data_in[55:0];

    assign sync_error = (sync_header != 2'b01) && (sync_header != 2'b10);
    assign decoder_wrong_type = (type_field not in valid_types);

    assign decoder_control_out = 8'b0;
    assign decoder_data_out = 64'h00000000;

    if (!(sync_error && decoder_wrong_type)) begin
        if (type_field == 8'b01) begin
            decoder_control_out = 8'b11111111;
            decoder_data_out = 64'hFEFEFEFEFEFEFEFE;
        end else if (type_field == 8'b10) begin
            decoder_control_out = 8'b00011111;
            decoder_data_out = 64'h00000000;
        end else if (type_field == 8'b0x) begin
            // Add more case blocks for other type fields as needed
        end else begin
            // Default case: output zero data and normal control
        end
    end

endmodule
