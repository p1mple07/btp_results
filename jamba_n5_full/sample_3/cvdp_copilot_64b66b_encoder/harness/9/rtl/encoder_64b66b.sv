module encoder_64b66b (
    input  logic         clk_in,
    input  logic         rst_in,
    input  logic [63:0] encoder_data_in,
    input  logic [7:0]   encoder_control_in,
    output logic [65:0]  encoder_data_out
);

    logic [1:0]  sync_word;
    logic        [1:0]  type;
    logic [63:0] encoded_data;

    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_word <= 2'b01;
            encoded_data <= 64'b0;
        end else begin
            if (encoder_control_in == 8'b00000000) begin
                // Data-only mode
                sync_word <= 2'b01;
                encoded_data <= encoder_data_in;
            end else begin
                // Mixed or control‑only mode
                type <= encoder_control_in != 8'b00000000;
                // Copy data bytes unchanged for data‑only bits
                for (int i = 0; i < 64; i++) begin
                    if (encoder_control_in[i] == 1'b0) begin
                        encoded_data[63 - 7*i + (i < 8)] = encoder_data_in[63 - 7*i];
                    end else begin
                        // Encode control byte according to the 7‑bit control code
                        encoded_data[63 - 7*i + (i < 8)] = control_to_bits[encoder_control_in[i]];
                    end
                end
            end
        end
    end

    assign encoder_data_out = {sync_word, type, encoded_data};

endmodule

// Helper function to convert 8‑bit control word to 7‑bit control code
localparam [1:0] control_to_bits = {    [0:0] 0 => 0,
    [0:0] 1 => 7'b0000,
    [0:0] 2 => 7'b0001,
    [0:0] 3 => 7'b0010,
    [0:0] 4 => 7'b0011,
    [0:0] 5 => 7'b0100,
    [0:0] 6 => 7'b0101,
    [0:0] 7 => 7'b0110,
    [0:0] 8 => 7'b1000,
    [0:0] 9 => 7'b1001,
    [0:0]10 => 7'b1010,
    [0:0]11 => 7'b1011,
    [0:0]12 => 7'b1100,
    [0:0]13 => 7'b1101,
    [0:0]14 => 7'b1110,
    [0:0]15 => 7'b1111
};
