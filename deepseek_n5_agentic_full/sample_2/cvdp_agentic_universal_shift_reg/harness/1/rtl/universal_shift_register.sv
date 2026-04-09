module universal_shift_register(
    parameter N,
    input clock,
    input rst,
    input mode_sel,
    input shift_dir,
    input serial_in,
    input parallel_in,
    output [N-1:0] q,
    output serial_out
);

    // Internal variables
    reg [N-1:0] next_q;
    reg serial_out_val;
    
    // Process each mode case
    case (mode_sel)
        2'b00: // Hold mode
            next_q = q;
        2'b01: // Shift mode
            if (shift_dir == 1) // Left shift
                next_q = {
                    serial_in,
                    q >> 1
                };
            else // Right shift
                next_q = {
                    q << (N-1),
                    serial_in
                };
        2'b10: // Rotate mode
            if (shift_dir == 1) // Left rotate
                next_q = {
                    q[0],
                    q[1:N-1]
                };
            else // Right rotate
                next_q = {
                    q[N-2:0],
                    q[N-1]
                };
        2'b11: // Parallel load
            next_q = parallel_in;
    endcase
    
    // Update q on falling edge of clock
    always @posedge clock
        q = next_q;
        
    // Update serial_out for shift modes
    if ((mode_sel & 2'b01) || (mode_sel & 2'b10))
        serial_out_val = (mode_sel & 2'b01 ? serial_in : q)[0];
    else
        serial_out_val = 0;
        
    // Assign the captured serial output
    assign serial_out = serial_out_val;
    
    // Optional: Add assertions or monitoring here
endmodule