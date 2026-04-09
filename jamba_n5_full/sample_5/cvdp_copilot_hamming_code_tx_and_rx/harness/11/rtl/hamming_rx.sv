module hamming_rx #(
    parameter int data_width = 4,
    parameter int parity_bits = 3
) (
    input [data_width-1:0] data_in,
    output [data_width-1:0] data_out
);

    // Internal signals
    reg [3:0] data_out_reg;
    reg [PARITY_BIT-1:0] parity;
    reg error;

    // Calculate parity
    initial begin
        parity = {};
        for (int i = 0; i < PARITY_BIT; i++) begin
            parity[i] = xor_combine(data_in[i]);
        end
    end

    // Error detection
    always_ff @(posedge clock) begin
        error = (~parity[PARITY_BIT-1]) ? 1'b1 : 1'b0;
    end

    // Correction
    always_comb begin
        data_out_reg = 0;
        if (error) begin
            data_out_reg = data_in;
        end else begin
            data_out_reg = data_in;
        end
    end

    assign data_out = {data_out_reg[7], data_out_reg[6], data_out_reg[5], data_out_reg[3]};

endmodule
