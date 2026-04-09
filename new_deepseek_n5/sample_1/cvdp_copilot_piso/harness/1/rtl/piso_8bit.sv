module piso_8bit (
    input clock,
    input rst,
    output serial_out
);
    // Counter for 8-bit increment
    reg [7:0] counter = 1;
    
    // 8-bit register to hold the temporary value
    reg [7:0] tmp;
    
    // Serial output
    reg serial_out;
    
    // Clock gate
    clock_gating clock_edge (., clock);
    
    // Counter increment logic
    integer i;
    integer count = 0;
    
    // Initialize tmp
    always clock_edge #1 tmp = 0;
    
    // Counter control
    always clock_edge #1 begin
        if (rst == 0) begin
            tmp = counter;
            counter = (counter + 1) % 256;
        end else begin
            tmp = 0;
            counter = 1;
        end
    end
    
    // Serial output is LSB of tmp
    serial_out = tmp & 1;
endmodule