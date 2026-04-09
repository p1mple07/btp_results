module manchester_encoder #(
    parameter N = 8  // Default width of input data
) (
    input  logic clk_in,
    input  logic rst_in,
    input  logic enc_valid_in,
    input  logic [N-1:0] enc_data_in,
    output logic enc_valid_out,
    output logic [2*N-1:0] enc_data_out
);

    logic [N-1:0] encoded_data;

    always_comb begin
        if (enc_valid_in) begin
            for (int i = 0; i < N; i++) begin
                if (enc_data_in[i] == 1'b1) begin
                    enc_data_out[2*i] = 1'b1;
                    enc_data_out[2*i + 1] = 1'b0;
                end else begin
                    enc_data_out[2*i] = 1'b0;
                    enc_data_out[2*i + 1] = 1'b1;
                end
            end
            enc_valid_out = 1'b1;
        end else begin
            enc_valid_out = 1'b0;
        end
    end

endmodule
