module top_64b66b_codec (
    input  logic        _clk_in,
    input  logic         rst_in,
    input  logic [63:0] data_in,
    input  logic [7:0] control_in,
    output logic [65:0] encoded_data_out,
    output logic [7:0] encoded_control_out,
    output logic [6:0] sync_out,
    output logic [1:0] error_out
) {

    // Encode data path
    wire [65:0] encoded_data_out = encoder_data_64b66b.encoder_data_out;
    
    // Encode control path
    wire [7:0] encoded_control_out = encoder_control_64b66b.encoder_control_in;
    
    // Decode path
    wire [65:0] encoded_data_in = decoder_data_control_64b66b.decoder_data_control_in;
    wire [7:0] encoded_control_in = decoder_data_control_64b66b.decoder_control_out;
    
    // Coordinate throughputs
    // Note: Adjust phase enable signals to match encoder/decoder clocks
    
    assign sync_out = decoder_data_control_64b66b.sync_error;
    assign error_out = decoder_data_control_64b66b.decoder_error_out;
}

// Lower level integration assumes proper timing and synchronization
// Between encoder and decoder modules