module encoder_64b66b (
    input  logic         clk_in,              // Clock signal
    input  logic         rst_in,              // Asynchronous reset (active high)
    input  logic [63:0]  encoder_data_in,     // 64‑bit data input
    input  logic [7:0]   encoder_control_in,  // 8‑bit control input
    output logic [65:0]  encoder_data_out     // 66‑bit encoded output
);

    logic [1:0]  sync_word;
    logic [63:0] encoded_data;
    logic [7:0]  encoded_ctrl_words;

    // ---- Sync word generation (single case)
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            sync_word <= 2'b00;
        end else begin
            case (encoder_control_in)
                8'b00000000: sync_word <= 2'b01;   // SyncA
                8'b11111111: sync_word <= 2'b10;   // SyncB
                default: sync_word <= 2'b00;      // Fallback
            endcase
        end
    end

    // ---- Encoded data generation (simplified)
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            encoded_data <= 64'b0;
        end else begin
            if (encoder_control_in == 8'b11111111) begin
                encoded_data <= encoder_data_in;
            end else begin
                encoded_data <= 64'b0;
            end
        end
    end

    // ---- Control‑based output (single case)
    function [7:0] get_output(input [63:0] data_in, input [7:0] control_in);
        case (control_in)
            8'b00000000: return 8'h1e;   // SyncA
            8'b11111111: return 8'h1e;   // SyncB
            8'b00000001: return 8'h78;   // FB+1
            8'b11111100: return 8'hcc;   // 070707FD
            default: return 8'h0;
        endcase
    endfunction

    // ---- Main combinational logic
    always_comb begin
        encoder_data_out = {sync_ctrl_word, type_field, encoded_ctrl_words};
    end

endmodule
