module advanced_decimator_with_adaptive_peak_detection(
    input clock,
    input reset,
    input valid_in,
    output data_out,
    output peak_value
);

    reg data_reg[N];
    reg [DATA_WIDTH-1:0] samples_FIFO_in[N/DEC_FACTOR];
    reg [DATA_WIDTH-1:0] samples_FIFO_out[N/DEC_FACTOR];
    reg [DATA_WIDTH-1:0] decimated_FIFO_in[N/DEC_FACTOR];
    reg [DATA_WIDTH-1:0] decimated_FIFO_out[N/DEC_FACTOR];
    reg [DATA_WIDTH-1:0] peak_value_reg;

    initial begin
        data_reg = 0;
    end

    always @(posedge clock or valid_in) begin
        if (reset) begin
            data_reg = 0;
            samples_FIFO_in = 0;
            decimated_FIFO_in = 0;
        end
        else
            data_reg = data_in;
        end
    end

    // Unpack data
    always begin
        for (int i = 0; i < N; i++) begin
            samples_FIFO_in[i] = (data_reg[i] << (DATA_WIDTH * (N - 1 - i))) & ((1 << (DATA_WIDTH * N)) - 1);
        end
    end

    // Decimate
    always begin
        for (int i = 0; i < samples_FIFO_in.size; i++) begin
            if (i % DEC_FACTOR == 0) begin
                decimated_FIFO_out[0] = samples_FIFO_in[0];
                decimated_FIFO_out[0] <= samples_FIFO_in[0];
                decimated_FIFO_in[0] = samples_FIFO_in[1];
                decimated_FIFO_in[1] = samples_FIFO_in[2];
                decimated_FIFO_in[2] = samples_FIFO_in[3];
                decimated_FIFO_in[3] = samples_FIFO_in[4];
            end
        end
    end

    // Peak detection
    always begin
        peak_value_reg = decimated_FIFO_in[0];
        for (int i = 1; i < decimated_FIFO_in.size; i++) begin
            if (decimated_FIFO_in[i] > peak_value_reg) begin
                peak_value_reg = decimated_FIFO_in[i];
            end
        end
    end

    // Pack decimated data
    always begin
        data_out = 0;
        for (int i = 0; i < decimated_FIFO_out.size; i++) begin
            data_out |= (decimated_FIFO_out[i] << (DATA_WIDTH * (decimated_FIFO_out.size - 1 - i)));
        end
    end

    // Output valid
    always begin
        valid_out = valid_in;
    end
endmodule