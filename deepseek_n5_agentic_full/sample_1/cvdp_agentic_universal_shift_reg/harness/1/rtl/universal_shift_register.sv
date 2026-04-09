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

// Inside the module
// Implement the logic for each mode here

// Example implementation for hold mode
always_ff @*begin
    if (mode_sel == 00)
    // Hold mode: retain current value
        q = prev_value;
    endif
// End of hold mode implementation

// Similar implementations needed for other modes:
// shift, rotate, and parallel_load

// Connect the module to rest of system
// ...
endmodule