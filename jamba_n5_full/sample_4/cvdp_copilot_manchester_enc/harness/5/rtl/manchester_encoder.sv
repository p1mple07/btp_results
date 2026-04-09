// Manchester Encoder – synchronous version
module manchester_encoder #(
    parameter N = 8  // Width of the encoded data
) (
    input  logic clk_in,
    input  logic rst_in,
    input  logic enc_valid_in,
    input  logic [N-1:0] enc_data_in,
    output logic enc_valid_out,
    output logic [2*N-1:0] enc_data_out
);

    // Internal register to hold the encoded data
    logic [N-1:0] encoded_data;

    // Synchronous combinational logic
    always_ff @(posedge clk_in or negedge rst_in) begin
        if (rst_in) begin
            encoded_data <= '0;
        end else begin
            if (enc_valid_in) begin
                for (int i = 0; i < N; i++) begin
                    if (enc_data_in[i] == 1'b1) begin
                        encoded_data[2*i] = 1'b1;
                        encoded_data[2*i+1] = 1'b0;
                    end
                    else begin
                        encoded_data[2*i] = 1'b0;
                        encoded_data[2*i+1] = 1'b1;
                    end
                end
            end
            enc_valid_out = 1'b1;
        end
    end

endmodule
