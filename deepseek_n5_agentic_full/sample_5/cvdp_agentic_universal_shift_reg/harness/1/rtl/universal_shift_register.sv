Module declaration
module universal_shift_register(
    parameter N,
    input clock,
    input rst,
    input mode_sel,
    input shift_dir,
    input serial_in,
    input parallel_in,
    output q,
    output serial_out
);

// Internal registers and signals
reg [N-1:0] q;          // Register to hold N-bit values
wire [N-1:0] temp_q;     // Temporary register for shifting
wire serial_out;        // Output for serial shift directions

// Process description
always begin
    // Reset behavior
    if (rst == 1)
    begin
        q = 0;
        serial_out = 0;
        $finish;
    end
end

// Mode processing
case (mode_sel)
    // Hold mode: retain current value
    00: 
        temp_q = q;
        serial_out = 0;
        q = temp_q;
        break;
    // Shift mode: perform arithmetic shift
    01:
        serial_out = q & 1;
        q = (q >> 1);
        serial_out = serial_out | (q << (N-1));
        break;
    // Rotate mode: perform circular shift
    10:
        serial_out = q & 1;
        q = (q >> 1) | ((q & 1) << (N-1));
        break;
    // Parallel Load mode: copy parallel_in to register
    11:
        q = parallel_in;
        break;
endcase

// Cleanup process
process (posedge clock)
begin
    // Update q from temp_q after all shifts
    q = temp_q;
endprocess

endmodule