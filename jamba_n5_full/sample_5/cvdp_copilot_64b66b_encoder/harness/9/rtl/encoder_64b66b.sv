module encoder_64b66b (
    input  logic         clk_in,
    input  logic         rst_in,
    input  logic [63:0]  encoder_data_in,
    input  logic [7:0]   encoder_control_in,
    output logic [65:0]  encoder_data_out
);

    localparam logic [7:0] CONTROL_BITS = 8'b11111111;
    localparam logic [7:0] DATA_ONLY_MODE = 8'b00000000;
    localparam logic [7:0] CONTROL_ONLY_MODE = 8'b11111111;
    localparam logic [7:0] MIXED_MODE = 8'b11111110;

    // Mapping of control bits to 7‑bit control codes
    localparam contr_map [8][7:0] = [
        {7'b0000000, 7'b0000},   // 0000000 => 0x1E
        {7'b0000001, 7'b0000},   // 0000001 => 0x1E
        {7'b0000010, 7'b0001},   // 0000010 => 0x33
        {7'b0000011, 7'b0001},   // 0000011 => 0x33
        {7'b0000100, 7'b0011},   // 0000100 => 0x78
        {7'b0000101, 7'b0011},   // 0000101 => 0x78
        {7'b0000110, 7'b0000},   // 0000110 => 0x78
        {7'b0000111, 7'b0000},   // 0000111 => 0x78
        {7'b0001000, 7'b0111},   // 0001000 => 0x4B
        {7'b0001001, 7'b0111},   // 0001001 => 0x4B
        {7'b0001010, 7'b0111},   // 0001010 => 0x4B
        {7'b0001011, 7'b0111},   // 0001011 => 0x4B
        {7'b0001100, 7'b0000},   // 0001100 => 0x66
        {7'b0001101, 7'b0000},   // 0001101 => 0x66
        {7'b0001110, 7'b0000},   // 0001110 => 0x66
        {7'b0001111, 7'b0000}    // 0001111 => 0x66
    ];

    // Sync word decisions
    logic [1:0] sync_word;
    logic [63:0] encoded_data;

    @(posedge clk_in) begin
        if (rst_in) begin
            sync_word <= 2'b00;
            encoder_data_out <= 64'b0;
        end else
        begin
            if (encoder_control_in == 8'b00000000) begin
                // Data‑only mode
                sync_word <= 2'b01;
                encoder_data_out <= encoder_data_in;
            end else if (encoder_control_in == 8'b11111111) begin
                // Control‑only mode
                sync_word <= 2'b10;
                // Build the 56‑bit encoded data
                for (int i = 0; i < 8; i++) begin
                    encoder_data_out[64 + 7*i] = CONTR_MAP[encoder_control_in[i]][7:0];
                end
            end else begin
                // Mixed mode
                sync_word <= 2'b10;
                // Combine data and control bytes
                for (int i = 0; i < 8; i++) begin
                    if (encoder_control_in[i]) begin
                        encoder_data_out[64 + 7*i] = CONTR_MAP[encoder_control_in[i]][7:0];
                    end else
                        encoder_data_out[64 + 7*i] = encoder_data_in[63 - 7*i];
                    // The data part is taken from the original encoder_data_in
                end
            end
        end
    end

endmodule
