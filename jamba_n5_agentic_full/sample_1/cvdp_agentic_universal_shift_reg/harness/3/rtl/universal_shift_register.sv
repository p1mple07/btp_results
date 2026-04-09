`timescale 1ns / 1ps

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
    output wire zero_flag
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        q <= 0;
        serial_out <= 0;
        msb_out <= 1'b1;
        lsb_out <= 1'b1;
        overflow <= 1'b0;
        parity_out <= 1'b1;
        zero_flag <= 1'b1;
    end else begin
        case (mode_sel)
            2'b00: begin
                q <= q;
            end
            2'b01: begin
                if (shift_dir == 0) begin
                    q <= {serial_in, q[N-1:1]};
                end else begin
                    q <= {q[N-2:0], serial_in};
                end
            end
            2'b10: begin
                if (shift_dir == 0) begin
                    q <= {q[0], q[N-1:1]};
                end else begin
                    q <= {q[N-2:0], q[N-1]};
                end
            end
            2'b11: begin
                q <= parallel_in;
            end
            2'b100: begin
                // Arithmetic shift right – copy MSB to LSB
                q <= {q[N-1], q[N-2:0]};
                overflow <= (q[0] == 1'b1);
            end
            2'b101: begin
                // Bitwise logical operations (AND, OR, XOR, XNOR)
                q <= {
                    (parallel_in[0] & serial_in[0]) ? 1'b1 : 1'b0,
                    (parallel_in[1] & serial_in[1]) ? 1'b1 : 1'b0,
                    (parallel_in[2] & serial_in[2]) ? 1'b1 : 1'b0,
                    (parallel_in[3] & serial_in[3]) ? 1'b1 : 1'b0,
                    (parallel_in[4] & serial_in[4]) ? 1'b1 : 1'b0,
                    (parallel_in[5] & serial_in[5]) ? 1'b1 : 1'b0,
                    (parallel_in[6] & serial_in[6]) ? 1'b1 : 1'b0,
                    (parallel_in[7] & serial_in[7]) ? 1'b1 : 1'b0
                };
            end
            2'b110: begin
                // Bit reversal
                q = reverse_bits(q);
            end
            2'b111: begin
                // Bitwise inversion
                q <= ~q;
            end
            default: q <= q;
        endcase
    end
end

// Simple helper to reverse the bits of a 8‑bit value
function int reverse_bits(int x);
    integer j;
    for (j = 0; j < 8; j = j + 1) begin
        reverse_bits[j] = x[7 - j];
    end
    return x;
endfunction

endmodule
