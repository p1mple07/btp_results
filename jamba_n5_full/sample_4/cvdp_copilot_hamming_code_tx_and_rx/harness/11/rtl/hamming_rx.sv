module hamming_rx #(
    parameter DATA_WIDTH = 4,
    parameter PARITY_BIT = 3
) (
    input [DATA_WIDTH-1:0] data_in,
    output [DATA_WIDTH-1:0] data_out
);

    wire [PARITY_BIT-1:0] parity;

    initial begin
        parity = 0;
        for (int i = 0; i < PARITY_BIT; i++) begin
            parity[i] = 1'b0;
        end
        for (int i = 0; i < DATA_WIDTH; i++) begin
            for (int n = 0; n < PARITY_BIT; n++) begin
                if (i == n || i == n*2 || i == n*2+1)
                    parity[n] = 1'b1;
            end
        end
    end

    assign error = ({parity[PARITY_BIT-1:0]} == 3'b000) ? 1'b0 : 1'b1;

    if (!error) begin
        data_out = data_in;
    end else begin
        int error_pos;
        for (error_pos = 0; error_pos < PARITY_BIT; error_pos++) begin
            if (parity[error_pos] == 1'b1) break;
        end
        data_out = data_in;
        data_out[error_pos] = (~data_out[error_pos]) & data_out[error_pos];
    end

endmodule
