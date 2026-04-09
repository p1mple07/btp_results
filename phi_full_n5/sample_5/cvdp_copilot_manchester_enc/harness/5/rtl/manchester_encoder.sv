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
        // When enc_valid_in is high, assign encoded_data
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
            // Ensure enc_valid_out is always asserted
            enc_valid_out = 1'b1;
        end else begin
            // When enc_valid_in is low, enc_valid_out should be de-asserted
            // To prevent latch inference, we explicitly reset encoded_data to '0'
            encoded_data = '0;
            // Also, we should clear the valid signal to indicate no valid data
            enc_valid_out = 1'b0;
        end
    end
endmodule
