module qam16_demapper_interpolated(
    parameter N,
    parameter OUT_WIDTH,
    parameter IN_WIDTH
);

    parameter ERROR_THRESHOLD = 8;

    input
        (N + N/2) * IN_WIDTH bit I,
        (N + N/2) * IN_WIDTH bit Q;

    output
        (N * OUT_WIDTH) bit [OUT_WIDTH-1:0] bits,
        bit error_flag;

    // Unpack I and Q into symbols
    reg [3:0] I_symbol,
         [3:0] Q_symbol;

    // Mapping for I and Q to bits
    reg [1:0] I_bits,
         [1:0] Q_bits;

    // Previous and next mapped symbols for error detection
    reg [3:0] prev_mapped_I,
         [3:0] next_mapped_I,
         [3:0] prev_mapped_Q,
         [3:0] next_mapped_Q;

    // Error accumulation
    reg [3:0] error_sum;

    // Error detection logic
    always @* begin
        // For each interpolated symbol, calculate error
        if (current_symbol is interpolated) begin
            expected_I = (prev_mapped_I + next_mapped_I) / 2;
            error_I = abs(expected_I - current_interpolated_I);
            error_Q = abs(expected_Q - current_interpolated_Q);
            error_sum = error_I + error_Q;
            if (error_sum > ERROR_THRESHOLD) error_flag = 1;
        end
    end

    // Demap I and Q to bits
    always @* begin
        case (I_symbol)
            -3: I_bits = 00;
            -1: I_bits = 01;
            1: I_bits = 10;
            3: I_bits = 11;
            default: I_bits = 00; // Handle unknown values
        endcase

        case (Q_symbol)
            -3: Q_bits = 00;
            -1: Q_bits = 01;
            1: Q_bits = 10;
            3: Q_bits = 11;
            default: Q_bits = 00; // Handle unknown values
        endcase

        // Combine I and Q bits into the output
        bits[ (i >> (IN_WIDTH * 2)) * OUT_WIDTH + (I_bits >> 1) * 2 + Q_bits >> 1 ] = I_bits[1];
        bits[ (i >> (IN_WIDTH * 2)) * OUT_WIDTH + (I_bits >> 1) * 2 + Q_bits >> 1 + 1 ] = I_bits[0];
        bits[ (i >> (IN_WIDTH * 2)) * OUT_WIDTH + (I_bits >> 1) * 2 + Q_bits >> 1 + 2 ] = Q_bits[1];
        bits[ (i >> (IN_WIDTH * 2)) * OUT_WIDTH + (I_bits >> 1) * 2 + Q_bits >> 1 + 3 ] = Q_bits[0];
    end

    // Buffering logic for symbols
    always @* begin
        I_symbol = I[(N + N/2)*IN_WIDTH - 1];
        Q_symbol = Q[(N + N/2)*IN_WIDTH - 1];
    end

    // Error accumulation
    always @* begin
        error_sum = 0;
    end