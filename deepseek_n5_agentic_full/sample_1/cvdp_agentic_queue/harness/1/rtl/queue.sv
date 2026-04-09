// Parameter Declaration
parameter DEPTH = 8; // Number of queue entries
parameter DBITS  = 8; // Width of each data entry in bits
parameter ALMOST_EMPTY_THRESHOLD = 3; // Threshold for almost-empty condition
parameter ALMOST_FULL_THRESHOLD = 9; // Threshold for almost-full condition

// Module Port Declaration
input wire clk_i;
input wire rst_ni;
input wire clr_i;
input wire [DBITS-1:0] we_i;
input wire [DBITS*DEPTH-1:0] d_i;
output reg [DBITS-1:0] q_o;
output reg re_i;
output reg [1:0] empty_o; // 0 indicates empty
output reg [1:0] full_o;  // 0 indicates full
output reg almost_empty_o; // 0 indicates almost empty
output reg almost_full_o;  // 0 indicates almost full

// Internal State Variables
reg [DBITS-1:0] queue_data[DEPTH]; // Array of registers to store queue data
reg queue_wadr; // Queue pointer/writer address

// Initialization
initial begin
    // Initialize queue pointers and status flags
    queue_wadr = 0;
    // Initialize all status flags to default values
    empty_o = 1;
    full_o  = 1;
    almost_empty_o = 1;
    almost_full_o = 1;
end

// Module Implementation
always @(posedge clock_i) begin
    if (rst_ni) begin
        // Asynchronous reset: clear all registers and status flags
        queue_wadr = 0;
        empty_o  = 1;
        full_o   = 1;
        almost_empty_o = 1;
        almost_full_o = 1;
    elsif (clr_i) begin
        // Synchronous clear: clear queue on next rising edge
        queue_wadr = 0;
    end else begin
        // Process write or read operations
        if (we_i && !re_i) begin
            // Write-only operation: increment pointer and write data
            if (queue_wadr < DEPTH - 1) begin
                queue_wadr +== 1;
                queue_data[queue_wadr] = d_i;
            else
                // Queue is full: wrap around (not supported)
                queue_data[0] = d_i;
            end
        elsif (!we_i && re_i) begin
            // Read-only operation: decrement pointer and check underflow
            if (queue_wadr > 0) begin
                queue_wadr -== 1;
                q_o     = queue_data[queue_wadr];
                re_i    = 1;
            else
                // Queue is empty: output nothing and assert empty_o
                re_i    = 0;
                empty_o  = 1;
            end
        elsif (we_i && re_i) begin
            // Simultaneous read/write operation
            if (queue_wadr == 0) begin
                // Queue is empty: write data directly to output
                q_o     = d_i;
                re_i    = 1;
            else begin
                // Shift data and write new entry
                q_o     = queue_data[queue_wadr - 1];
                re_i    = 1;
                queue_data[queue_wadr]      = d_i;
                queue_wadr +== 1;
            end
        end else begin
            // No operation: propagate re_i and q_o
            re_i = 0;
            q_o  = 0;
        end
    end
end

// Update status signals based on queue pointer and thresholds
always begin
    // Almost empty condition
    almost_empty_o = (queue_wadr < ALMOST_EMPTY_THRESHOLD);
    
    // Almost full condition
    almost_full_o = (queue_wadr >= ALMOST_FULL_THRESHOLD);
    
    // Edge cases
    if (queue_wadr == 0) empty_o = 1;
    if (queue_wadr >= DEPTH) full_o  = 1;
end