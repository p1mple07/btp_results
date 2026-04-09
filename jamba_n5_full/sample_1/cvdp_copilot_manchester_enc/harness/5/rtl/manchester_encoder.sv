
module manchester_encoder #(
    parameter N = 8  // Default width of input data
) (
    input  logic clk_in,          // Clock input
    input  logic rst_in,          // Active high reset input
    input  logic enc_valid_in,        // Input valid signal
    input  logic [N-1:0] enc_data_in, // N-bit input data
    output logic enc_valid_out,       // Output valid signal
    output logic [2*N-1:0] enc_data_out  // 2*N-bit encoder output data
);

    // Internal register to hold the decoded data
    logic [N-1:0] decoded_data;

    // Sequential logic to generate decoded data from Manchester encoded data
    always_ff @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            dec_data_out <= '0; // Reset the output to zero
            dec_valid_out <= 1'b0; // Reset the valid signal
        end else if (dec_valid_in) begin
            dec_data_out <= '0; // Initialize to zero
            for (int i = 0; i < N; i++) begin
                if (dec_data_in[2*i] == 1'b1 && dec_data_in[2*i + 1] == 1'b0) begin
                    dec_data_out[i] <= 1'b1;
                end else if (dec_data_in[2*i] == 1'b0 && dec_data_in[2*i + 1] == 1'b1) begin
                    dec_data_out[i] <= 1'b0;
                end else begin
                    dec_data_out[i] <= 1'b0; // Default to 0 if invalid Manchester code
                end
            end
            dec_valid_out <= 1'b1; // Set the valid signal
        end else begin
            dec_valid_out <= 1'b0; // Clear the valid signal if no valid input
        end
    end

endmodule
