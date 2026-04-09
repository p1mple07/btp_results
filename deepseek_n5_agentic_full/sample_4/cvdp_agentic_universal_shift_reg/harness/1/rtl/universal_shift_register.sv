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

// Internal variables
reg [N-1:0] q;
wire [N-1:0] serial_out;
wire [N-1:0] tmp_q;

// Always block defining the shift register functionality
always @posedge clock begin
    case (mode_sel)
        // Case 00: Hold Mode - retain current value
        00: 
            q = serial_in;
            serial_out = 0;
            break;
        // Case 01: Shift Mode
        01: 
            // Store serial_in temporarily
            tmp_q = q;
            q = (tmp_q << shift_dir) | serial_in;
            serial_out = tmp_q & 1;
            break;
        // Case 10: Rotate Mode
        10: 
            // Store MSB
            tmp_q = q >> shift_dir;
            q = (q << shift_dir) | ((tmp_q >> (N-1)) & 1);
            // Note: shift_dir may need adjustment depending on rotation direction
            break;
        // Case 11: Parallel Load
        11: 
            q = parallel_in;
            serial_out = 0;
            break;
    endcase
end

// Cleanup assignments
default: 
    q = 0;
    serial_out = 0;
    break;
endcase
end

// End module definition
endmodule