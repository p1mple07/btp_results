module universal_shift_register #(
    parameter N,
    parameter OP_SIZE
)

    input wire [N-1:0] parallel_in, 
    input wire [N-1:1] serial_in, 
    input wire [N-1:0] shift_dir, 
    input wire [OP_SIZE:0] op_sel, 
    input wire shift_dir, 
    input wire [N-1:0] q, 
    output reg [N-1:0] q, 
    output wire serial_out,

    output wire [1'b0] overflow,
    output wire parity_out,
    output wire zero_flag,

    output wire [N-1:0] expected_q;
    reg  [N-1:0] expected_q;
    reg              expected_overflow;
    reg              expected_serial_out;
    reg              expected_parity;
    reg              expected_zero_flag;

    always @(posedge clk or negedge rst) begin
        if (rst) begin
            q <= 0; 
        end else begin
            case (op_sel)
            // Existing cases remain unchanged
            // ... original cases ...

            100: begin
                // Arithmetic Shift
                if (shift_dir) {
                    q = {(q[N-1:1]), q[N-1:1][0]} & parallel_in;
                } else {
                    q = {q[N-2:0], 0} | parallel_in;
                }
                overflow = q[N-1] ^ q[N-1];
                end

            101: begin
                // Bitwise Logical Operations
                case (bitwise_op)
                00: q = q & parallel_in;
                01: q = q | parallel_in;
                10: q = q ^ parallel_in;
                11: q = ~q & ~parallel_in;
                endcase
                end

            110: begin
                // Bit Reversal
                q = reverse_bits(q);
                overflow = 0;
                end

            111: begin
                // Bitwise Inversion
                q = ~q;
                overflow = 0;
                end
            endcase
        end
        update_expected_signals();
    end

    assign serial_out = (shift_dir && q[0]) ? q[N-1] : q[0];

    endmodule