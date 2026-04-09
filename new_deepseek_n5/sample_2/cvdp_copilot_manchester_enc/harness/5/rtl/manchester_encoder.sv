module
module manchester_encoder #(
    parameter N = 8  // Default width of input data
) (
    input  logic clk_in,          // Clock input
    input  logic rst_in,          // Active high reset input
    input  logic enc_valid_in,        // Input valid signal
    input  logic [N-1:0] enc_data_in, // N-bit input data
    output logic enc_valid_out,       // Output valid signal
    output logic [2*N-1:0] enc_data_out // 2N-bit output encoded data
);

    // Internal register to hold the encoded data
    logic [2*N-1:0] encoded_data;

    // Sequential logic to generate encoded data from input data
    always_comb begin
        if (rst_in) begin
            // Reset all outputs to zero
            enc_data_out <= (enc_data_in == 0) ? (2'b00 repeated N times) : (2'b01 repeated N times);
            enc_valid_out <= 0;
        else if (enc_valid_in) begin
            for (int i = 0; i < N; i++) begin
                if (enc_data_in[i] == 1'b1) begin
                    enc_data_out[2*i] = 1'b1;
                    enc_data_out[2*i + 1] = 1'b0;
                else begin
                    enc_data_out[2*i] = 1'b0;
                    enc_data_out[2*i + 1] = 1'b1;
                end
            end
            enc_valid_out <= 1'b1;
        else begin
            enc_valid_out <= 0;
        end
    end

endmodule