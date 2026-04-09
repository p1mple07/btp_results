module encoder_64b66b (
    input  logic         clk_in,
    input  logic         rst_in,
    input  logic [63:0] encoder_data_in,
    input  logic [7:0]  encoder_control_in,
    output logic [65:0] encoder_data_out
);

    // --- State variables -------------------------------------------------
    logic [1:0] sync_word;
    logic [65:66] type;
    logic [63:56] encoded_data;

    // --- Reset handling ----------------------------------------------------
    always_comb begin
        if (rst_in) begin
            sync_word <= 2'b01;
        end else begin
            case (encoder_control_in)
                8'b00000000:  // Data‑only mode
                    sync_word <= 2'b01;
                    encoder_data_out = encoder_data_in;
                
                8'b11111111:  // Control‑only mode
                    sync_word <= 2'b10;
                    encoder_data_out = {sync_word, encode_control_only(encoder_control_in, encoder_data_in)};
                
                default:       // Mixed mode
                    sync_word <= 2'b10;
                    encoder_data_out = {sync_word, encode_mixed(encoder_control_in, encoder_data_in)};
            endcase
        end
    end

    // --- Helper functions -------------------------------------------------
    function logic encode_control_only (logic [7:0] control_in, logic [63:0] data_in);
        logic [65:66] out;
        integer i;
        for (i = 0; i < 8; i = i + 1) begin
            if (control_in[i * 8 + 7]) begin
                out = out & ~64'b1; // Clear the 7‑bit control byte
            end else begin
                out = out & 64'b1;
                out = out ^ data_in[i * 8 + 7];
            end
        end
        return out;
    endfunction

    function logic encode_mixed (logic [7:0] control_in, logic [63:0] data_in);
        logic [65:66] out;
        integer i;
        for (i = 0; i < 8; i = i + 1) begin
            if (control_in[i * 8 + 7]) begin
                out = out & ~64'b1; // Clear the 7‑bit control byte
                out = out ^ data_in[i * 8 + 7];
            end else begin
                out = out & 64'b1;
                out = out ^ (data_in[i * 8 + 7] + 32); // Convert data to control code
            end
        end
        return out;
    endfunction

    // --- Main encoding routine ---------------------------------------------
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_word <= 2'b01;
        end else begin
            case (encoder_control_in)
                8'b00000000:  // Data‑only
                    sync_word <= 2'b01;
                    encoder_data_out = encoder_data_in;
                
                8'b11111111:  // Control‑only
                    sync_word <= 2'b10;
                    encoder_data_out = {sync_word, encode_control_only(encoder_control_in, encoder_data_in)};
                
                default:       // Mixed
                    sync_word <= 2'b10;
                    encoder_data_out = {sync_word, encode_mixed(encoder_control_in, encoder_data_in)};
            endcase
        end
    end

endmodule
