module encoder_64b66b (
    input  logic         clk_in,              // Clock signal
    input  logic         rst_in,              // Asynchronous reset (active high)
    input  logic [63:0]  encoder_data_in,     // 64-bit data input
    input  logic [7:0]   encoder_control_in,  // 8-bit control input
    output logic [65:0]  encoder_data_out     // 66-bit encoded output
);

    logic [1:0]  sync_word;
    logic [63:0] encoded_data;

    // Simplified get_output function
    function [7:0] get_output(input [63:0] data_in, input [7:0] control_input);
        case (control_input)
            8'b00000000: get_output = encoder_data_in;
            8'b11111111: get_output = 8'h1e;
            8'b00000001: get_output = {encoder_data_in[63:8], 8'hFB};
            8'b00011111: get_output = {encoder_data_in[39:40], 4'h0, 7'h00, 7'h00, 7'h00, 7'h00, 7'h00};
            8'b11111100: get_output = {encoder_data_in[63:16], 7'h00, 7'h00, 7'h00, 7'h00, 5'b00000, encoder_data_in[15:0]};
            8'b11111000: get_output = {encoder_data_in[63:24], 7'h00, 7'h00, 3'b000, encoder_data_in[31:0]};
            8'b11110000: get_output = {encoder_data_in[63:32], 7'h00, 2'b00, encoder_data_in[31:0]};
            8'b11111110: get_output = {7'h00, 7'h00, 7'h00, 7'h00, 7'h00, 6'b00000, encoder_data_in[7:0]};
            8'b11111101: get_output = {4'h0, 7'h00, 7'h00, 7'h00, 7'h00, 4'b1111, encoder_data_in[31:8]};
            8'b00010001: get_output = {encoder_data_in[63:40], 8'hFF, encoder_data_in[31:8]};
            default: get_output = 8'b0;
        endcase
    endfunction

    // Optimized synchronization and encoding logic
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_word <= 2'b00;
            encoded_data <= 64'b0;
        end else begin
            case (encoder_control_in)
                8'b00000000: begin
                    sync_word <= 2'b00;
                    encoded_data <= encoder_data_in;
                end
                8'b11111111: begin
                    sync_word <= 2'b01;
                    encoded_data <= encoder_data_in;
                end
                8'b00011111: begin
                    sync_word <= 2'b10;
                    encoded_data <= 64'b0;
                end
                8'b11111100: begin
                    sync_word <= 2'b10;
                    encoded_data <= 64'b0;
                end
                8'b11111000: begin
                    sync_word <= 2'b10;
                    encoded_data <= 64'b0;
                end
                8'b11110000: begin
                    sync_word <= 2'b10;
                    encoded_data <= 64'b0;
                end
                8'b11110001: begin
                    sync_word <= 2'b10;
                    encoded_data <= get_output(encoder_data_in, encoder_control_in);
                end
                default: begin
                    sync_word <= 2'b00;
                    encoded_data <= 64'b0;
                end
            endcase
        end
    end

    always_comb begin
        if (|encoder_control_in)
            encoder_data_out = {sync_word, encoded_data};
        else
            encoder_data_out = {sync_word, encoded_data};
    end

endmodule
