module encoder_64b66b (
    input  logic         clk_in,              // Clock signal
    input  logic         rst_in,              // Asynchronous reset (active high)
    input  logic [63:0]  encoder_data_in,     // 64-bit data input
    input  logic [7:0]   encoder_control_in,  // 8-bit control input
    output logic [65:0]  encoder_data_out     // 66-bit encoded output
);

    logic [1:0]  sync_word;
    logic [63:0] encoded_data;

    // Simplified output function
    always_comb begin
        case (encoder_control_in)
            8'b00000000: encoder_data_out = {sync_word, encoded_data};
            8'b11111111: begin
                if (encoder_data_in == 64'h0707070707070707 || encoder_data_in == 64'hFEFEFEFEFEFEFEFE)
                    encoder_data_out = {1'b1, 8'h1E, encoded_data};
                else if (encoder_data_in == 64'h07070707070707FD)
                    encoder_data_out = {1'b1, 8'h00, encoded_data};
                else
                    encoder_data_out = {1'b0, encoded_data};
            endcase
        end
    end

    // Simplified control synchronization
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_word <= 2'b00;
            encoded_data <= 64'b0;
        end else begin
            sync_word <= encoder_control_in;
            case (encoder_control_in)
                8'b00000000: encoded_data <= encoder_data_in;
                8'b11111111: encoded_data <= 64'b0;
                8'b00011111: encoded_data <= encoder_data_in[39:0] & 4'h0;
                8'b00000001: encoded_data <= encoder_data_in[63:8];
                8'b11111110: encoded_data <= 64'h0000000 & encoded_data[7:0];
                8'b11111100: encoded_data <= 64'h0000000 & encoded_data[15:0];
                8'b11111000: encoded_data <= 64'h0000000 & encoded_data[31:0];
                8'b11100000: encoded_data <= 64'h0000000 & encoded_data[23:0];
                8'b11000000: encoded_data <= encoder_data_in[47:0];
                8'b10000000: encoded_data <= encoder_data_in;
                default: encoded_data <= 64'b0;
            endcase
        end
    end

    // Simplified control synchronization
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_word <= 2'b00;
        end else begin
            sync_word <= encoder_control_in;
        end
    end

endmodule
