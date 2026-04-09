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

    logic [1:0] sync_header;
    logic [7:0] type_field;
    logic [63:0] data_in;
    logic type_field_valid;
    logic decoder_wrong_ctrl_received;
    logic decoder_wrong_type_field;

    assign sync_header = decoder_data_in[65:64];
    assign type_field = decoder_data_in[63:56];
    assign data_in = decoder_data_in[55:0];

    // Decoding logic
    always_ff @(posedge clk_in or negedge rst_in) begin
        if (!rst_in) begin
            decoder_data_out <= 64'h00000000;
            decoder_control_out <= 8'h0;
            sync_error <= 1'b0;
            decoder_error_out <= 1'b0;
        end else begin
            if (sync_header == 2'b01) begin
                type_field_valid = 1'b1;
                case (type_field)
                    8'h1E: begin
                        decoder_data_out <= 64'hFEFEFEFEFEFEFEFE;
                        decoder_control_out <= 8'h11111111;
                        sync_error <= 1'b0;
                        decoder_error_out <= 1'b0;
                    end
                    // Add cases for other valid type fields here...
                    default: begin
                        decoder_wrong_type_field = 1'b1;
                        decoder_error_out <= 1'b1;
                    end
                endcase
            else if (sync_header == 2'b10) begin
                type_field_valid = 1'b1;
                case (type_field)
                    // Add cases for valid control-only/mixed mode type fields here...
                    default: begin
                        decoder_wrong_ctrl_received = 1'b1;
                        decoder_error_out <= 1'b1;
                    end
                endcase
            else begin
                decoder_wrong_ctrl_received = 1'b1;
                decoder_error_out <= 1'b1;
            end
        end
    end

    // Error detection logic
    assign sync_error = (sync_header != 2'b01) | (sync_header != 2'b10);
    assign decoder_error_out = (decoder_wrong_ctrl_received) | (decoder_wrong_type_field);

endmodule
