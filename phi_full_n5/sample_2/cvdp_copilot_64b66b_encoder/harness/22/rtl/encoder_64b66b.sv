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
            8'b00000000:
                encoded_data = encoder_data_in;
            8'b11111111:
                encoded_data = 64'b0;
            8'b00011111:
                encoded_data = encoder_data_in[39:0] ? encoder_data_in[63:40] : 64'b0;
            8'b00100000:
                encoded_data = 64'b0;
            8'b00100001:
                encoded_data = 8'h00;
            8'b00100010:
                encoded_data = 8'h00;
            8'b00100100:
                encoded_data = 8'h00;
            8'b00101000:
                encoded_data = 8'h00;
            8'b00101001:
                encoded_data = 8'h00;
            8'b00101100:
                encoded_data = 8'h00;
            8'b00110000:
                encoded_data = 8'h00;
            8'b00110001:
                encoded_data = 8'h00;
            8'b00110100:
                encoded_data = 8'h00;
            8'b00111000:
                encoded_data = 8'h00;
            8'b00111001:
                encoded_data = 8'h00;
            8'b00111100:
                encoded_data = 8'h00;
            8'b00111101:
                encoded_data = 8'h00;
            8'b10000000:
                encoded_data = encoder_data_in[63:56];
            8'b10000001:
                encoded_data = encoder_data_in[55:0];
            8'b10000100:
                encoded_data = 8'h00;
            8'b10001000:
                encoded_data = 8'h00;
            8'b10010000:
                encoded_data = 8'h00;
            8'b10010001:
                encoded_data = 8'h00;
            8'b10010100:
                encoded_data = 8'h00;
            8'b10010101:
                encoded_data = 8'h00;
            8'b10011000:
                encoded_data = 8'h00;
            8'b10011001:
                encoded_data = 8'h00;
            8'b10100000:
                encoded_data = 8'h00;
            8'b10100001:
                encoded_data = 8'h00;
            8'b10100100:
                encoded_data = 8'h00;
            8'b10101000:
                encoded_data = 8'h00;
            8'b10101001:
                encoded_data = 8'h00;
            8'b10110000:
                encoded_data = 8'h00;
            8'b10110001:
                encoded_data = 8'h00;
            8'b10110100:
                encoded_data = 8'h00;
            8'b10111000:
                encoded_data = 8'h00;
            8'b10111001:
                encoded_data = 8'h00;
            8'b11000000:
                encoded_data = encoder_data_in[63:48];
            8'b11000001:
                encoded_data = encoder_data_in[55:0];
            8'b11000100:
                encoded_data = 8'h00;
            8'b11001000:
                encoded_data = 8'h00;
            8'b11010000:
                encoded_data = 8'h00;
            8'b11010001:
                encoded_data = 8'h00;
            8'b11011000:
                encoded_data = 8'h00;
            8'b11100000:
                encoded_data = encoder_data_in[63:32];
            8'b11100001:
                encoded_data = 3'b000, encoder_data_in[31:8];
            8'b11100100:
                encoded_data = 7'h00, encoder_data_in[15:0];
            8'b11101000:
                encoded_data = 5'b00000, encoder_data_in[23:0];
            8'b11110000:
                encoded_data = 2'b00, encoder_data_in[31:0];
            8'b11110001:
                encoded_data = {7'h00, 7'h00, 7'h00, 7'h00, encoder_data_in[31:8], 4'b1111};
                default:
                encoded_data = 64'b0;
        endcase
    end

    // Simplified sequential logic
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_word <= 2'b00;
        end else begin
            sync_word <= encoder_control_in == 8'b00000000 ? 2'b00 : 2'b10;
        end
    end

    always_comb begin
        if (encoder_control_in == 8'b00000000) begin
            sync_ctrl_word <= 2'b00;
            type_field <= 8'h0;
        end else begin
            sync_ctrl_word <= 2'b10;
            type_field <= encoder_data_in;
        end
    end

    assign encoder_data_out = {sync_word, type_field, encoded_data};

endmodule
