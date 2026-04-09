// Manchester encoder module
module manchester_encoder #(
    parameter N = 8  // Default width of input data
) (
    input  logic clk_in,          // Clock input
    input  logic rst_in,          // Active high reset input
    input  logic enc_valid_in,        // Input valid signal
    input  logic [N-1:0] enc_data_in, // N-bit input data
    output logic enc_valid_out,       // Output valid signal
    output logic [2*N-1:0] enc_data_out // 2*N-bit output encoded data
);

    // Internal register to hold the encoded data
    logic [2*N-1:0] encoded_data;

    // Combinational logic to generate Manchester encoded data
    always_comb begin
        // Only update encoded_data when enc_valid_in is high
        if (enc_valid_in) begin
            for (int i = 0; i < N; i++) begin
                if (enc_data_in[i] == 1'b1) begin
                    encoded_data[2*i] = 1'b1;
                    encoded_data[2*i + 1] = 1'b0;
                end else begin
                    encoded_data[2*i] = 1'b0;
                    encoded_data[2*i + 1] = 1'b1;
                end
            end
            // Ensure enc_valid_out is asserted when valid input is present
            enc_valid_out = 1'b1;
        end else begin
            // Clear enc_valid_out when no valid input is present
            enc_valid_out = 1'b0;
            // Initialize encoded_data to '0' when resetting
            encoded_data = '0;
        end
    end

    // Properly assign enc_data_out when enc_valid_in is asserted
    assign enc_data_out = encoded_data;

endmodule
