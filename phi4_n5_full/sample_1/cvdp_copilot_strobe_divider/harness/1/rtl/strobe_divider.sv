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
        // Default next state: hold current state
        r_next_Count    = r_Count;
        r_next_OutValid = r_OutValid;

        // Counter and pulse generation logic
        if (In_Valid) begin
            if (In_Ratio == 0) begin
                // Bypass division logic: generate pulse on every valid input
                r_next_OutValid = 1;
                r_next_Count    = 0;
            end else begin
                if (r_Count == In_Ratio - 1) begin
                    r_next_OutValid = 1;
                    r_next_Count    = 0;
                end else begin
                    r_next_Count = r_Count + 1;
                end
            end
        end

        // Output handshake: if an output pulse is generated and Out_Ready is asserted,
        // clear the pulse so that new pulses are generated only when Out_Ready is reasserted.
        if (r_next_OutValid && Out_Ready)
            r_next_OutValid = 0;

        // Latency handling:
        // For Latency_g = 0, pass the newly generated pulse immediately.
        // For Latency_g = 1, delay the output pulse by one clock cycle.
        if (Latency_g == 1)
            OutValid_v = r_OutValid;
        else
            OutValid_v = r_next_OutValid;
    end

    // --------------------------------------------------------
    // Sequential Logic
    // --------------------------------------------------------
    always @(posedge Clk) begin
        if (Rst) begin
            // Reset internal states on synchronous reset
            r_Count    <= 0;
            r_OutValid <= 0;
        end else begin
            r_Count    <= r_next_Count;
            r_OutValid <= r_next_OutValid;
        end
    end

endmodule