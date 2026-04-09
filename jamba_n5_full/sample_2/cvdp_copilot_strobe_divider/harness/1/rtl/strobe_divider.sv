module strobe_divider #(
    parameter MaxRatio_g = 10, // Maximum division ratio (positive integer)
    parameter Latency_g  = 1   // Latency: 0 or 1
)(
    input  wire                              Clk,        // Clock input
    input  wire                              Rst,        // Synchronous reset (active high)
    input  wire [log2ceil(MaxRatio_g)-1:0]   In_Ratio,   // Division ratio input
    input  wire                              In_Valid,   // Input pulse valid
    output reg                               Out_Valid,  // Output pulse valid
    input  wire                              Out_Ready   // Output ready signal
);

    // Function to calculate the ceiling of log2
    function integer log2ceil;
        input integer value;
        integer i;
        begin
            log2ceil = 1;
            for (i = 0; (2 ** i) < value; i = i + 1)
                log2ceil = i + 1;
        end
    endfunction

    // Internal state registers
    reg [log2ceil(MaxRatio_g)-1:0] r_Count, r_next_Count; // Counter register
    reg                            r_OutValid, r_next_OutValid; // Registered OutValid signal
    reg                            OutValid_v; // Intermediate OutValid for latency

    // --------------------------------------------------------
    // Combinational Logic
    // --------------------------------------------------------
    always @* begin
        // Hold current state as default
        r_next_Count    = r_Count;
        r_next_OutValid = r_OutValid;

        // Counter logic for division ratio
        // Insert code here

        // Latency handling
        // Insert code here

        // Output ready handshake
        // Insert code here

        // Output assignment
        Out_Valid = OutValid_v;
    end

    // --------------------------------------------------------
    // Sequential Logic
    // --------------------------------------------------------
    always @(posedge Clk) begin
        if (Rst) begin
            // Reset all internal states
            r_Count <= 0;
            r_OutValid <= 0;
            OutValid_v <= 0;
        end else begin
            // Update counter
            r_Count <= r_Count + 1;

            // Check division
            if (In_Ratio == 0) begin
                OutValid_v <= OutValid_v; // stay high if already high
            end else if (r_Count == In_Ratio) begin
                OutValid_v <= 1;
            else
                OutValid_v <= 0;
            end

            // Latency handling
            if (Latency_g == 1) begin
                // delay by one cycle
                OutValid_v <= OutValid_v; // same as before?
            } else begin
                OutValid_v <= OutValid_v;
            }

            // Output assignment
            Out_Valid = OutValid_v;
        end
    end

    // --------------------------------------------------------
    // Reset behavior
    // --------------------------------------------------------
    always @(Rst) begin
        if (Rst) begin
            r_Count <= 0;
            r_OutValid <= 0;
            OutValid_v <= 0;
        end else begin
            // No reset needed
        end
    end

endmodule
