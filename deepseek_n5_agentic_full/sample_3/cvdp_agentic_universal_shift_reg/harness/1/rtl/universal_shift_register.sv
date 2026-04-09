module universal_shift_register(
    parameter N,
    input clock,
    input rst,
    input [1:0] mode_sel,
    input shift_dir,
    input serial_in,
    input parallel_in,
    output [N-1:0] q,
    output serial_out
);

// N-bit register initialized to 0
reg [N-1:0] q = 0;

always @posedge clock begin
    if (rst) 
        q = 0;
        serial_out = 0;
    else
        case (mode_sel)
        // Hold mode: retain current value
        00:     // Do nothing
        01:     // Shift left or right
            if (shift_dir == 0) // Left shift
                q = { serial_in << [N-2:0] };
                serial_out = q[N-1];
            else // Right shift
                q = { q[0], q[N-1:N-2] };
                serial_out = q[0];
        10:     // Rotate left or right
            if (shift_dir == 0) // Left rotate
                q = { q[N-1], q[N-2:N-1] };
                serial_out = q[N-1];
            else // Right rotate
                q = { q[1:N-1], q[0] };
                serial_out = q[0];
        11:     // Parallel load
            q = parallel_in;
            serial_out = 0;
        endcase
    end
endmodule