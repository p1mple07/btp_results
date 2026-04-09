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
    always_comb begin
        case (encoder_control_in)
            8'b00000000: encoder_data_out = {sync_word, encoded_data};
            8'b11111111: encoder_data_out = {8'h1E, encoded_data};
            8'b00011111: encoder_data_out = {encoded_data[39:40], 4'h0, 7'h00, 7'h00, 7'h00, 7'h00, 7'h00};
            8'b00000001: encoder_data_out = {encoded_data[63:8], encoder_data_in[7:0]};
            8'b11111110: encoder_data_out = {7'h00, 7'h00, 7'h00, 7'h00, 7'h00, 7'h00, 6'b000000, encoded_data[7:0]};
            8'b11111100: encoder_data_out = {7'h00, 7'h00, 7'h00, 7'h00, 7'h00, 5'b00000, encoded_data[15:0]};
            8'b11111000: encoder_data_out = {7'h00, 7'h00, 7'h00, 3'b000, encoded_data[31:0]};
            8'b11110000: encoder_data_out = {7'h00, 7'h00, 2'b00, encoded_data[39:32], 0};
            8'b11100000: encoder_data_out = {7'h00, 1'b0, encoded_data[47:0]};
            8'b11000000: encoder_data_out = encoded_data[55:0];
            default: encoder_data_out = {sync_word, encoded_data};
        endcase
    end

    // Simplified synchronization logic
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_word <= 2'b00;
            encoded_data <= 64'b0;
        end else begin
            sync_word <= encoder_control_in;
            encoded_data <= (encoder_control_in == 8'b00000001) ? encoded_data[63:8] : 64'b0;
        end
    end

    // Synchronized encoded_ctrl_words with simplified case structure
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            encoded_ctrl_words <= 56'b0;
        end else begin
            case (encoder_control_in)
                8'b11111111: begin
                    encoded_ctrl_words <= {7'h00, 7'h00, 7'h00, 7'h00, 7'h00, 7'h00, 7'h00, 7'h00};
                8'b00011111: begin
                    encoded_ctrl_words <= {encoded_data[39:40], 4'h0, 7'h00, 7'h00, 7'h00, 7'h00, 7'h00};
                8'b00000001: begin
                    encoded_ctrl_words <= encoded_data[63:8];
                end
                8'b11111110: begin
                    encoded_ctrl_words <= {7'h00, 7'h00, 7'h00, 7'h00, 7'h00, 7'h00, encoded_data[7:0]};
                8'b11111100: begin
                    encoded_ctrl_words <= {7'h00, 7'h00, 7'h00, 7'h00, 7'h00, 5'b00000, encoded_data[15:0]};
                8'b11111000: begin
                    encoded_ctrl_words <= {7'h00, 7'h00, 7'h00, 3'b000, encoded_data[31:0]};
                8'b11100000: begin
                    encoded_ctrl_words <= {7'h00, 7'h00, 2'b00, encoded_data[39:0]};
                8'b11000000: begin
                    encoded_ctrl_words <= 56'h0;
                end
                default: encoded_ctrl_words <= 56'b0;
            endcase
        end
    end

    // Synchronize sync_ctrl_word and type_field
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_ctrl_word <= 2'b00;
            type_field <= 8'b0;
        end else begin
            sync_ctrl_word <= encoder_control_in;
            type_field <= (encoder_control_in != 8'b00000000) ? get_output(encoder_data_in, encoder_control_in) : 8'b0;
        end
    end

endmodule
