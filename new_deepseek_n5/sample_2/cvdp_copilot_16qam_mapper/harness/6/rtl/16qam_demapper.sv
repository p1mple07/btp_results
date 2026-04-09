module qam16_demapper_interpolated(
    parameter integer N,
    parameter integer OUT_WIDTH = 4,
    parameter integer IN_WIDTH = 3
);

    // Input unpacking and processing
    input [(N + N/2)*IN_WIDTH] I,
          [(N + N/2)*IN_WIDTH] Q;

    // Output unpacking and processing
    output [N*OUT_WIDTH] bits,
          error_flag;

    // Mapping functions
    function integer map signed [1:0] to bits;
        input signed [3:0] value;
        case (-3)
            0b00;
        case (-1)
            0b01;
        case (1)
            0b10;
        case (3)
            0b11;
        default
            $error("Invalid mapped value");
        endcase
    endfunction

    function integer map bits to signed [3:0];
        input bits [1:0] value;
        case (0b00)
            -3;
        case (0b01)
            -1;
        case (0b10)
            1;
        case (0b11)
            3;
        default
            $error("Invalid bits combination");
        endcase
    endfunction

    // Error detection threshold
    local constant integer ERROR_THRESHOLD = 2;

    // Processing
    integer i;
    for (i = 0; i < N; i = i + 2) begin
        // Unpack mapped and interpolated values
        signed [IN_WIDTH - 1:0] mapped_I = I[((N + N/2)*i) + 0];
        signed [IN_WIDTH - 1:0] interpolated_Q = Q[((N + N/2)*i) + 1];
        signed [IN_WIDTH - 1:0] mapped_Q = I[((N + N/2)*(i + 1)) + 0];
        
        // Calculate expected interpolated value
        signed [IN_WIDTH:0] expected_Q = (mapped_Q + mapped_I) / 2;
        
        // Calculate difference and check error
        signed [IN_WIDTH:0] diff_Q = interpolated_Q - expected_Q;
        integer abs_diff = abs(diff_Q);
        if (abs_diff > ERROR_THRESHOLD) begin
            error_flag = 1;
        end
    end

    // Map I and Q to bits and combine
    bits = 0;
    for (i = 0; i < N; i = i + 1) begin
        bits = (map(I[(N + N/2)*i + 0], Q[(N + N/2)*i + 0]) << (2*i)) | map(I[(N + N/2)*i + 1], Q[(N + N/2)*i + 1]);
    end

endmodule