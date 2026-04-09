module manchester_encoder #(
    parameter N = 8  // Default width of input data
) (
    input  logic clk_in,          // Clock input
    input  logic rst_in,          // Active high reset input
    input  logic enc_valid_in,    // Input valid signal
    input  logic [N-1:0] enc_data_in, // N-bit input data
    output logic enc_valid_out,   // Output valid signal
    output logic [2*N-1:0] enc_data_out // 2N-bit output encoded data
);

    always_comb begin
        enc_valid_out = 1'b0;
        enc_data_out = '0;

        for (int i = 0; i < N; i++) begin
            if (enc_data_in[i] == 1'b1) begin
                enc_data_out[2*i]   = 1'b1;
                enc_data_out[2*i+1] = 1'b0;
            end else begin
                enc_data_out[2*i]   = 1'b0;
                enc_data_out[2*i+1] = 1'b1;
            end
            enc_valid_out = 1'b1;
        end
    end

endmodule