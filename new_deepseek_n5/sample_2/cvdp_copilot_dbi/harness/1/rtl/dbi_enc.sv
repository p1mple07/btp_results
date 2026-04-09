module dbi_enc(
    input data_in,
    input clock,
    input rst_n,
    output data_out,
    output dbi_cntrl
);

    // Initialize previous data
    flip_flop_40 prev_data[40];
    wire [39:0] prev_group1 = {prev_data[39:20]};
    wire [19:0] prev_group0 = {prev_data[19:0]};

    // XOR for each bit in group1
    wire [39:0] xor_group1;
    for (int i = 0; i < 20; i++) {
        xor_group1[i] = data_in[39 - i] ^ prev_group1[i];
    }

    // XOR for each bit in group0
    wire [19:0] xor_group0;
    for (int i = 0; i < 20; i++) {
        xor_group0[i] = data_in[19 - i] ^ prev_group0[i];
    }

    // Full adder for group1
    wire [20:0] sum_group1;
    for (int i = 0; i < 19; i++) {
        full_adder sum_i(.a(xor_group1[i]), .b(xor_group1[i+1]), .c_in(0),
                        .c_out(sum_group1[i+1]));
    }

    // Full adder for group0
    wire [20:0] sum_group0;
    for (int i = 0; i < 19; i++) {
        full_adder sum_i(.a(xor_group0[i]), .b(xor_group0[i+1]), .c_in(0),
                        .c_out(sum_group0[i+1]));
    }

    // Control signals
    dbi_cntrl[1] = sum_group1[20] ? 1 : 0;
    dbi_cntrl[0] = sum_group0[20] ? 1 : 0;

    // Data output
    wire [39:0] data_out;
    data_out = 0;

    // Update data_out
    always @posedge clock begin
        if (!rst_n) begin
            // Shift previous data into data_out
            for (int i = 0; i < 20; i++) {
                data_out[39 - i] = prev_group1[i];
            }
            for (int i = 0; i < 20; i++) {
                data_out[19 - i] = prev_group0[i];
            }
        end
    end

    // Update previous data
    always @posedge clock begin
        prev_group1 = data_out[39:20];
        prev_group0 = data_out[19:0];
    end

    // Initialize flip-flops on reset
    initial begin
        if (rst_n) begin
            $lock $finish;
                prev_group1 = 0;
                prev_group0 = 0;
                $finish;
            end
        end
    end

endmodule