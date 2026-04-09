module strobe_divider #(
    parameter MaxRatio_g = 10, // Maximum division ratio (positive integer)
    parameter Latency_g  = 1   // Latency: 0 (immediate) or 1 (one cycle delay)
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
    reg                            r_OutValid, r_next_OutValid; // Registered Out_Valid signal
    reg                            OutValid_v; // Intermediate signal for latency handling

    // --------------------------------------------------------
    // Combinational Logic
    // --------------------------------------------------------
    always @* begin
        // Default assignments
        r_next_Count    = r_Count;
        r_next_OutValid = r_OutValid;

        // Local variable to capture the new pulse condition
        reg new_pulse;

        // Compute new pulse based on input and division logic
        if (In_Valid) begin
            if (In_Ratio == 0) begin
                // Bypass division logic: generate a pulse for every valid input.
                new_pulse = 1'b1;
                r_next_Count = 0;  // Optionally reset counter
            end else begin
                // Normal division logic: count pulses until the threshold is reached.
                if (r_Count == In_Ratio - 1) begin
                    new_pulse = 1'b1;
                    r_next_Count = 0;  // Reset counter when threshold met
                end else begin
                    new_pulse = 1'b0;
                    r_next_Count = r_Count + 1;  // Increment counter
                end
            end
        end else begin
            new_pulse = 1'b0;
        end

        // Handshake: new pulses are generated only when Out_Ready is asserted.
        // If Out_Ready is deasserted, maintain the current Out_Valid.
        if (Out_Ready)
            r_next_OutValid = new_pulse;
        else
            r_next_OutValid = r_OutValid;

        // Latency handling:
        // For Latency_g = 1, delay the output pulse by one cycle.
        if (Latency_g == 1)
            OutValid_v = r_OutValid; // Use previous registered state (delayed)
        else
            OutValid_v = r_next_OutValid; // Immediate update

        // Drive the output
        Out_Valid = OutValid_v;
    end

    // --------------------------------------------------------
    // Sequential Logic
    // --------------------------------------------------------
    always @(posedge Clk) begin
        if (Rst) begin
            // Reset all internal states
            r_Count    <= 0;
            r_OutValid <= 0;
        end else begin
            r_Count    <= r_next_Count;
            r_OutValid <= r_next_OutValid;
        end
    end

endmodule