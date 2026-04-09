module fixed_priority_arbiter (
    input        clk,               // Clock signal
    input        reset,             // Active-high reset
    input        enable,            // Arbitration enable
    input        clear,             // Manual clear
    input  [7:0] req,               // 8-bit request signal; each bit represents a request from a different source
    input  [7:0] priority_override, // External priority control

    output reg [7:0] grant,         // 8-bit grant signal; only one bit will be set high based on priority
    output reg       valid,         // Indicates if a request is granted
    output reg [2:0] grant_index,   // Outputs the granted request index in binary format
    output reg [2:0] active_grant   // Tracks latest granted index
);
