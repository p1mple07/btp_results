module universal_shift_register #(
    parameter N = 8
)(
    input wire clk,
    input wire rst,
    input wire [1:0] mode_sel,
    input wire shift_dir,
    input wire serial_in,
    input wire [N-1:0] parallel_in,
    output reg [N-1:0] q,
    output wire serial_out,
    output wire msb_out,
    output wire lsb_out,
    output wire overflow,
    output wire parity_out,
    output wire zero_flag,
    output wire [1:0] bitwise_op,
    output wire en,
    output wire op_sel,
    output wire shift_dir
);

    // ... existing logic for mode_sel 2'b00 (hold), 2'b01 (shift), 2'b10 (parallel), 2'b11 (no-op)

    // New cases: 000, 001, 010, 011, 100, 101, 110, 111

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 0;
            expected_q         = {N{1'b0}};
            expected_overflow  = 1'b0;
            expected_serial_out= 1'b0;
            expected_msb_out   = 1'b0;
            expected_lsb_out   = 1'b0;
            expected_parity    = 1'b0;
            expected_zero_flag = 1'b1;
            op_sel = 3'd0;
            shift_dir = 1'b0;
            bitwise_op =2'b00;
            serial_in = 1'b0;
            parallel_in = {N{1'b0}};
            @(posedge clk);
            rst = 0;
            @(posedge clk);
            $display("[RESET] DUT has been reset.");
        end else begin

            case (mode_sel)

                2'b00: begin
                    // hold
                    q <= q;
                end

                2'b01: begin
                    // shift direction
                    if (shift_dir == 0) begin
                        q <= {serial_in, q[N-1:1]};
                    end else begin
                        q <= {q[N-2:0], serial_in};
                    end
                end

                2'b10: begin
                    // parallel load
                    if (serial_in != 0) begin
                        q <= serial_in;
                    end
                end

                2'b11: begin
                    // no-op
                end

                2'b000: begin
                    // arithmetic shift left
                    // logic: shift left, carry out from MSB
                    q <= {q[N-1], q[N-2:0]};
                    overflow <= (q[N-1] == 1'b1);
                end

                2'b001: begin
                    // arithmetic shift right
                    // shift right, zero in LSB
                    q <= {q[N-2:0], q[N-1]};
                    overflow <= (q[N-1] == 1'b0);
                end

                2'b010: begin
                    // rotate right
                    // rotate by shift_dir
                    if (shift_dir == 0) begin
                        q <= {q[N-1], q[0:N-2]};
                    end else begin
                        q <= {q[N-1:1], q[0]};
                    end
                end

                2'b011: begin
                    // rotate left
                    if (shift_dir == 1) begin
                        q <= {q[1:N-1], q[0]};
                    end else begin
                        q <= {q[1], q[N-1]};
                    end
                end

                2'b100: begin
                    // arithmetic shift
                    // same as above
                    q <= {q[N-1], q[N-2:0]};
                    overflow <= (q[N-1] == 1'b1);
                end

                2'b101: begin
                    // bitwise logical operations (AND, OR, XOR, XNOR)
                    // parallel_in is applied
                    bitwise_op_val = bitwise_op;
                    // For AND: parallel_in & q
                    if (bitwise_op_val == 2'b00) bitwise_op_val = 2'b00;
                    if (bitwise_op_val == 2'b01) bitwise_op_val = 2'b01;
                    if (bitwise_op_val == 2'b10) bitwise_op_val = 2'b10;
                    if (bitwise_op_val == 2'b11) bitwise_op_val = 2'b11;

                    // apply bitwise_op_val to q
                    q <= bitwise_op_val;
                end

                2'b110: begin
                    // bit reversal
                    q <= reverse_bits(q);
                end

                2'b111: begin
                    // bitwise inversion
                    q <= ~q;
                end

                default: q <= q;
            endcase
        end
    end

    assign serial_out = (shift_dir == 0) ? q[0] : q[N-1];

    // Overflow capture
    always @(*) begin
        overflow = (q[N-1] == 1'b1 && q[N-1:1] == 1'b0) ? 1'b1 : 1'b0;
    end

    assign parity_out = (q[0] ^ q[1] ^ q[2] ^ ... ^ q[N-1])? But easier: use XOR across all bits.
    We can compute parity_out as XOR of all bits.

    Actually we can use a simple XOR of all elements:

    reg [N-1:0] temp;
    initial assign temp = {N{1'b0}};
    @(posedge clk) begin
        temp = {temp[N-1], q[N-1]};
    end
    parity_out = ~temp[0];

    But maybe simpler to compute XOR of all q bits.

    Let's do:

    reg [N-1:0] parity;
    initial assign parity = 0;
    always @(*) begin
        parity = parity ^ q[0];
        if (N>1) parity = parity ^ q[1];
        ...
        parity = parity ^ q[N-1];
    end
    parity_out = parity;

    But we need to keep it simple.

    We'll just implement a simple XOR accumulator.

    However, due to time, we can approximate: parity_out = q[0] XOR q[1] XOR ... XOR q[N-1].

    We can compute using a bitmask.

    But the question says: "parity_out: 1-bit output that computes and outputs the XOR of all bits in the register (parity checking)."

    So we can implement:

    reg [N-1:0] parity;
    initial assign parity = 0;
    always @(*) begin
        parity = parity ^ q[0];
        if (N>1) parity = parity ^ q[1];
        // etc.
    end
    parity_out = parity;

    Similarly, zero_flag: 1'b1 if q == {N{1'b0}}.

    msb_out: q[N-1].

    lsb_out: q[0].

    We need to update the outputs accordingly.

    Also we need to add the new case for mode_sel 100 (arithmetic shift).

    We must ensure that the new case 2'b100 handles arithmetic shift.

    We also need to keep the existing case 2'b01 (shift_dir == 0) for shift right/left.

    This is quite extensive. We need to produce a full updated Verilog code.

    However, the user expects a single answer with the modified module. We need to produce the final code snippet.

    We should produce the full Verilog code with the necessary modifications.

    Let's draft the code:

    We'll include all the new cases.

    Also, we need to keep the original logic for existing modes.

    We'll write the code with comments.

    But the answer must be plain text.

    Let's produce the final code.


