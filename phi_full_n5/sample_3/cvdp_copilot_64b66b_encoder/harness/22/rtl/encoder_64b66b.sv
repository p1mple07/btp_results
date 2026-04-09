module encoder_64b66b (
    input  logic         clk_in,              // Clock signal
    input  logic         rst_in,              // Asynchronous reset (active high)
    input  logic [63:0]  encoder_data_in,     // 64-bit data input
    input  logic [7:0]   encoder_control_in,  // 8-bit control input
    output logic [65:0]  encoder_data_out     // 66-bit encoded output
);

    logic sync_word, sync_ctrl_word;
    logic type_field;
    logic [55:0] encoded_ctrl_words;

    // Simplified get_output function
    function [7:0] get_output(input [63:0] data_in, input [7:0] control_input);
        case (control_input)
            8'b00000000: get_output = encoder_data_in == 64'h0707070707070707 ? 8'h1E : 8'h0;
            8'b11111111: get_output = encoder_data_in == 64'hFEFEFEFEFEFEFEFE ? 8'h1E : 8'h0;
            8'b00000000: get_output = encoder_data_in == 64'h07070707070707FD ? 8'h87 : 8'h0;
            8'b00011111: get_output = (encoder_data_in[39:0] == 40'hFB07070707) ? 8'h33 : 8'h0;
            8'b00011111: get_output = (encoder_data_in[39:0] == 40'h9C07070707) ? 8'h2d : 8'h0;
            8'b00000001: get_output = (encoder_data_in[7:0] == 8'hFB) ? 8'h78 : 8'h0;
            8'b11111110: get_output = (encoder_data_in[63:8] == 56'h070707070707FD) ? 8'h99 : 8'h0;
            8'b11111100: get_output = (encoder_data_in[63:16] == 48'h0707070707FD) ? 8'haa : 8'h0;
            8'b11111000: get_output = (encoder_data_in[63:24] == 40'h07070707FD) ? 8'hb4 : 8'h0;
            8'b11110000: get_output = (encoder_data_in[63:32] == 32'h070707FD) ? 8'hcc : 8'h0;
            8'b11110001: get_output = ({encoder_data_in[63:32], encoder_data_in[7:0]} == 40'h070707079C) ? 8'h4b : 8'h0;
            8'b00010001: get_output = ({encoder_data_in[39:32], encoder_data_in[7:0]} == 16'h9C9C) ? 8'h55 : 8'h0;
            default: get_output = 8'b0;
        endcase
    endfunction

    // Optimized sequential logic for synchronization
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_word <= 2'b00;
            type_field <= 8'b0;
            encoded_ctrl_words <= 56'b0;
        end else begin
            sync_ctrl_word <= 2'b10;
            type_field <= get_output(encoder_data_in, encoder_control_in);
        end
    end

    // Optimized combinational logic for encoding output
    always_comb begin
        encoder_data_out = (encoder_control_in != 8'b00000000) ? {sync_ctrl_word, get_output(encoder_data_in, encoder_control_in), encoded_ctrl_words} : {sync_word, type_field, encoded_ctrl_words};
    end

endmodule
