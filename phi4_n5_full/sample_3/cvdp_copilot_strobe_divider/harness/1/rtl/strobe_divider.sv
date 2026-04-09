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
    // r_Count: counter for division ratio (when In_Ratio > 0)
    reg [log2ceil(MaxRatio_g)-1:0] r_Count, r_next_Count;
    // r_OutValid: registered output valid signal
    reg                            r_OutValid, r_next_OutValid;
    // OutValid_v: intermediate register used for latency (if Latency_g==1)
    reg                            OutValid_v;

    //-------------------------------------------------------------------------
    // Combinational Logic: Compute next state for counter and output valid
    //-------------------------------------------------------------------------
    always @(*) begin
        // Default assignments: hold current state
        r_next_Count    = r_Count;
        r_next_OutValid = r_OutValid;
        
        //-------------------------------------------------------------------------
        // Two operating modes:
        // 1. Bypass mode: When In_Ratio == 0, every valid input pulse generates
        //    an output pulse immediately (ignoring the counter).
        // 2. Count mode: When In_Ratio > 0, count In_Valid pulses until the count
        //    reaches (In_Ratio - 1), then generate an output pulse and reset the counter.
        //-------------------------------------------------------------------------
        if (In_Ratio == 0) begin  // Bypass mode
            if (!r_OutValid) begin
                if (In_Valid)
                    r_next_OutValid = 1;
                else
                    r_next_OutValid = 0;
            end else begin
                // If a pulse is pending, only clear it when handshake (Out_Ready) occurs.
                if (Out_Ready)
                    r_next_OutValid = 0;
                else
                    r_next_OutValid = 1;
            end
        end else begin  // Count mode
            if (!r_OutValid) begin
                if (In_Valid) begin
                    // If the counter has reached (In_Ratio - 1), generate a pulse and reset counter.
                    if (r_Count == In_Ratio - 1) begin
                        r_next_OutValid = 1;
                        r_next_Count    = 0;
                    end else begin
                        r_next_OutValid = 0;
                        r_next_Count    = r_Count + 1;
                    end
                end else begin
                    r_next_OutValid = 0;
                    r_next_Count    = r_Count; // Hold counter when no valid input
                end
            end else begin
                // When an output pulse is already asserted, do not count new pulses.
                // Wait for handshake: if Out_Ready is high, clear the pulse and reset counter.
                if (Out_Ready) begin
                    r_next_OutValid = 0;
                    r_next_Count    = 0;
                end else begin
                    r_next_OutValid = 1;
                    r_next_Count    = r_Count; // Maintain counter value
                end
            end
        end

        //-------------------------------------------------------------------------
        // Latency Handling:
        // For Latency_g == 0, the output pulse is updated immediately.
        // For Latency_g == 1, the output pulse is delayed by one clock cycle.
        // We use the intermediate register OutValid_v to implement the delay.
        //-------------------------------------------------------------------------
        if (Latency_g == 0)
            OutValid_v = r_next_OutValid;
        else
            OutValid_v = r_OutValid;
    end

    //-------------------------------------------------------------------------
    // Sequential Logic: Update registers on clock edge
    //-------------------------------------------------------------------------
    always @(posedge Clk) begin
        if (Rst) begin
            // Reset all internal states to 0 on reset assertion
            r_Count     <= 0;
            r_OutValid  <= 0;
            OutValid_v  <= 0;
            Out_Valid   <= 0;
        end else begin
            r_Count     <= r_next_Count;
            r_OutValid  <= r_next_OutValid;
            // Update output based on latency setting.
            // If no latency, drive output directly from r_OutValid.
            // If one-cycle latency, drive output from the delayed register OutValid_v.
            if (Latency_g == 0)
                Out_Valid <= r_OutValid;
            else
                Out_Valid <= OutValid_v;
        end
    end

endmodule