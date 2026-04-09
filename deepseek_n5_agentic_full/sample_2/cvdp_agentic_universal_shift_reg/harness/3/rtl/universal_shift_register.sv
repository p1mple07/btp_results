Module declaration
module universal_shift_register #(
    parameter N,
    input wire [N-1:0] parallel_in,
    input wire [N-1:0] serial_in,
    input clock,
    input rst,
    input en,
    input [2:0] op_sel,
    output reg [N-1:0] q,
    output wire shift_dir,
    output wire serial_out,
    output wire [SIPO] overflow,
    output wire parity_out,
    output wire zero_flag,
    output wire [N-1:0] parallel_out
);

// Parameters
parameter N = 8;

// Variables
reg              [(N-1):0] expected_q;
wire              [(N-1):0] expected_out;
wire             [N-1:0] expected_parallel_out;
wire             [N-2:0] expected_shifted_in;
wire             [N-1:0] expected_serial_out;
wire             [N-1:0] expected_msb_out;
wire             [N-1:0] expected_lsb_out;
wire             [N-1:0] expected_parity;
wire             [N-1:0] expected_zero_flag;
wire             [N-1:0] expected_parallel_in;

// Always block
always @+ #5 [
    // State machine
    case (op_sel)
    000: begin
        q <= q; 
    end // Hold
    001: begin
        if (shift_dir == 0) begin
            q <= {serial_in, q[N-1:1]};
        end else begin
            q <= {q[N-2:0], serial_in};
        end
    end // Logical Shift
    010: begin
        if (shift_dir == 0) begin
            q <= {q[0], q[N-1:1]};
        end else begin
            q <= {q[N-2:0], q[N-1]};
        end
    end // Rotate
    011: begin
        q <= parallel_in;
    end // Parallel Load
    100: begin
        if (shift_dir == 1) {
            q <= {q[N-2:0], 0};
        } else {
            q <= {q[1:N-1], q[N-1]};
        }
    end // Arithmetic Shift
    101: begin
        if (bitwise_op == 00) q <= parallel_in;
        else if (bitwise_op == 01) q <= q & parallel_in;
        else if (bitwise_op == 10) q <= q | parallel_in;
        else if (bitwise_op == 11) q <= q ^ parallel_in;
        else q <= ~q;
    end // Bitwise Logical Op
    110: begin
        q <= {q[N-1:0]}[::-1];
    end // Bit Reversal
    111: begin
        q <= ~q;
    end // Bitwise Inversion
    default: q <= q;
    endcase
    $finish;

    // Other code remains unchanged...

    assign serial_out = (shift_dir == 0) ? q[0] : q[N-1];
    assign shift_dir = 0;   // 0 = Shift Right, 1 = Shift Left
    assign overflow = (shift_dir == 0 && (q[0] != serial_in)) ? 1'b0 :
                       (shift_dir == 1 && (q[N-1] != serial_in)) ? 1'b1 : 1'b0;
    assign parity_out = ^q;
    assign zero_flag = (q == {N{1'b0}});
    
    // Additional tasks...
endmodule