module top_64b66b_codec (
    input  logic         clk_in,              // Clock signal
    input  logic         rst_in,              // Asynchronous reset (active high)
    input  logic [63:0]  data_in,               // 64-bit data input
    input  logic [7:0]   control_in,            // 8-bit control input
    output logic [65:0] coded_out,            // 66-bit encoded output
    output logic [6:0]  ctrl_out,              // 7-bit control output
    output logic [7:0] sync_out,              // Sync header output
    output logic         dec_error_out,         // Combined error indicator
    output logic         decoder_error_out    // Type field error indicator
);

    logic [63:0] encoder_data_out;
    logic [63:0] encoder_control_out;
    logic [66:0] decoder_data_out;
    logic [7:0]  decoder_control_out;
    logic [7:0]  decoder_type_field;
    logic [1:0] sync_header;

    // Select between data and control encoder
    always @(posedge_clk_in or posedge_rst_in) begin
        if (rst_in) begin
            encoder_data_out <= 64'b0;
            encoder_control_out <= 8'b00000000;
            decoder_error_out <= 1'b0;
            decoder_type_field <= 7'b0000000;
            decoder_control_out <= 7'b0000000;
        end else begin
            if (control_in == 8'b00000000) begin
                // Use data encoder
                encoder_data_out <= encoder_data_64b66b(data_in, encoder_control_out);
                encoder_control_out <= encoder_control_64b66b(control_in);
                decoder_error_out <= encoder_data_64b66b.sync_error;
                decoder_type_field <= encoder_data_64b66b.type_field;
                decoder_control_out <= encoder_data_64b66b ctrl_out;
            else begin
                // Use control encoder
                encoder_data_out <= encoder_control_64b66b(data_in, encoder_control_out);
                encoder_control_out <= encoder_control_64b66b(control_in);
                decoder_error_out <= encoder_control_64b66b.decoder_error_out;
                decoder_type_field <= encoder_control_64b66b.type_field;
                decoder_control_out <= encoder_control_64b66b.ctrl_out;
            end
        end
    end

    // Decode the encoded data
    decoder_data_out <= decoder_data_control_66b66b(decoder_data_out, decoder_control_out);

    // Combine control signals
    sync_header <= decoder_data_control_66b66b.sync_header;
    decoder_error_out <= decoder_data_control_66b66b.decoder_error_out;
    decoder_type_field <= decoder_data_control_66b66b.type_field;

    // Output control signals
    assign ctrl_out[7:0] = decoder_data_control_66b66b ctrl_out;
    assign sync_out[6:0] = decoder_data_control_66b66b.sync_out;
    assign dec_error_out = decoder_data_control_66b66b.decoder_error_out;

    always_ff @(posedge_clk_in or posedge_rst_in) begin
        if (rst_in) begin
            decoder_data_control_66b66b.reset_encoder <= 1'b1;
        end else begin
            decoder_data_control_66b66b.reset_encoder <= 1'b0;
        end
    end
>>>>>>> REPLACE