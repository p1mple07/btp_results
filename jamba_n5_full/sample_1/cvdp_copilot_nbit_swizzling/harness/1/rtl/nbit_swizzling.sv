module nbit_swizzling #(parameter DATA_WIDTH = 64) (
    input wire [DATA_WIDTH-1:0] data_in,
    input wire [1:0] sel,
    output reg [DATA_WIDTH-1:0] data_out
);

always @(*) begin
    if (sel == 0) begin
        // Reverse the entire input
        for (int i = 0; i < DATA_WIDTH / 2; i++) begin
            data_out[i] = data_in[DATA_WIDTH - 1 - i];
            data_out[DATA_WIDTH - 1 - i] = data_in[i];
        end
    end else if (sel == 1) begin
        // Split into two halves, reverse each
        int half = DATA_WIDTH / 2;
        for (int i = 0; i < half; i++) begin
            data_out[i] = data_in[DATA_WIDTH - 1 - i];
        end
        for (int i = 0; i < half; i++) begin
            data_out[DATA_WIDTH - 1 - i] = data_in[i];
        end
    end else if (sel == 2) begin
        // Split into four quarters, reverse each
        int quarter = DATA_WIDTH / 4;
        for (int i = 0; i < quarter; i++) begin
            data_out[i] = data_in[DATA_WIDTH - 1 - i];
        end
        for (int i = 0; i < quarter; i++) begin
            data_out[DATA_WIDTH - 1 - i] = data_in[i];
        end
        for (int i = quarter; i < half; i++) begin
            data_out[i] = data_in[DATA_WIDTH - 1 - i];
        end
        for (int i = half; i < DATA_WIDTH - 1; i++) begin
            data_out[i] = data_in[i];
        end
    end else if (sel == 3) begin
        // Split into eight octets, reverse each
        int eighth = DATA_WIDTH / 8;
        for (int i = 0; i < eighth; i++) begin
            data_out[i] = data_in[DATA_WIDTH - 1 - i];
        end
        for (int i = 0; i < eighth; i++) begin
            data_out[DATA_WIDTH - 1 - i] = data_in[i];
        end
        for (int i = eighth; i < quarter; i++) begin
            data_out[i] = data_in[DATA_WIDTH - 1 - i];
        end
        for (int i = quarter; i < half; i++) begin
            data_out[i] = data_in[i];
        }
        for (int i = half; i < DATA_WIDTH - 1; i++) begin
            data_out[i] = data_in[DATA_WIDTH - 1 - i];
        end
    end else
        data_out = data_in;
end

endmodule
