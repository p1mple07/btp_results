module declaration
module universal_shift_register #(
    parameter N,
    input wire [N-1:0] parallel_in,
    input wire [N-1:0] serial_in,
    input [1:0] bitwise_op,
    input [2:0] op_sel,
    input [1:0] shift_dir,
    input enable,
    output reg [N-1:0] q,
    output wire [N-1:0] serial_out,
    output wire [N-1:0] parallel_out,

    output wire overflow,
    output wire parity_out,
    output wire zero_flag,
    output wire msb_out,
    output wire lsb_out // New outputs
);

    // internal state variables
    reg [N-1:0] expected_q;
    reg [N-1:0] parallel_in_state = {N{1'b0}};

    // Always blocks go here
    // Description
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 0; 
        end else begin
            case (op_sel)
                000: begin
                    q <= q; // Hold operation
                end
                001: begin
                    if (shift_dir == 0) begin
                        case (shift_dir)
                            0: begin
                                if (enable) {
                                    expected_q = {serial_in, expected_q[N-1:1]};
                                end
                                q <= expected_q;
                            end
                            1: break;
                        end
                    end
                end
                010: begin
                    if (shift_dir == 0) begin
                        case (shift_dir)
                            0: begin
                                if (enable) {
                                    expected_q = {parallel_in, expected_q[N-1:1]};
                                end
                                q <= expected_q;
                            end
                            1: break;
                        end
                    end
                end
                011: parallel_in = parallel_in_state; // Parallel load
                100: begin
                    if (shift_dir == 0) begin
                        case (shift_dir)
                            0: begin
                                if (enable) {
                                    expected_q = {0, expected_q[N-1:1]};
                                end
                                q <= expected_q;
                            end
                            1: break;
                        end
                    end
                end
                101: begin
                    if (enable) {
                        expected_q = expected_q + bitwise_op[0] ? parallel_in : parallel_in;
                    }
                    q <= expected_q;
                end
                110: expected_q = reverse_bits(expected_q); // Bit Reversal
                111: expected_q = ~expected_q; // Bitwise Inversion
            end
        end
    end

    // Additional logic for bitwise operations
    // Bitwise AND
    wire [N-1:0] bitwise_and = expected_q & parallel_in;
    // Bitwise OR
    wire [N-1:0] bitwise_or = expected_q | parallel_in;
    // Bitwise XOR
    wire [N-1:0] bitwise_xor = expected_q ^ parallel_in;
    // Bitwise XNOR
    wire [N-1:0] bitwise_xnor = ~expected_q & ~parallel_in;

    // Always block for bitwise operations
    always @(posedge clocks) begin
        if (op_sel == 101) begin
            if (bitwise_op == 00) {
                expected_q = bitwise_and;
            } else if (bitwise_op == 01) {
                expected_q = bitwise_or;
            } else if (bitwise_op == 10) {
                expected_q = bitwise_xor;
            } else if (bitwise_op == 11) {
                expected_q = bitwise_xnor;
            }
        end
    end

    // Calculate parity and zero flag
    wire carry = 0;
    foreach (i in 0..N-1) {
        carry = carry ^ q[i];
    }
    parity_out = carry;

    // Extract MSB and LSB
    msb_out = q[N-1];
    lsb_out = q[0];

    // Expected value calculation
    case (op_sel)
        000: expected_q = q; // No change
        001: expected_q = {serial_in, q[N-1:1]} | {(1 - shift_dir), q[N-1:1]};
        010: expected_q = {parallel_in, q[N-1:1]} | {(1 - shift_dir), q[N-1:1]};
        011: expected_q = parallel_in;
        100: expected_q = {shift_dir ? 1'b0 : 1'b0, q[N-1:1]};
        101: expected_q = parallel_in;
        110: expected_q = reverse_bits(q);
        111: expected_q = ~q;
    default: expected_q = q;
    end

    // Check outputs
    @always
    void check_outputs(string testname;
        q_out = q,
        serial_out = serial_out,
        parallel_out = parallel_out,
        q_expected = expected_q,
        overflow = overflow,
        parity = parity_out,
        zero = zero_flag,
        msb = msb_out,
        lsb = lsb_out);

    // Start checking
    check_outputs("HOLD");
    check_outputs("SHIFT");
    check_outputs("ROTATE");
    check_outputs("PARALLEL LOAD");
    check_outputs("ARITHMETIC SHIFT");
    check_outputs("BITWISE OP");
    check_outputs("BIT REVERSAL");
    check_outputs("BITWISE INVERSION");
endmodule