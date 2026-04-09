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

    // Calculate the ceiling of log2 to determine the number of bits
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
    always @(Clk or Rst) begin
        if (Rst) begin
            r_Count <= 0;
            r_OutValid <= 0;
            OutValid_v <= 0;
        end else begin
            if (In_Ratio != 0) begin
                if (In_Valid) r_Count = r_Count + 1;
                else r_Count = r_Count;
            else
                r_Count = 0;
            end
            Out_Valid_v = (Out_Ready) ? r_Count : 0;
        end
    end

    // Assign the output pulse
    Out_Valid = Out_Valid_v;

    // --------------------------------------------------------
    // Sequential Logic
    // --------------------------------------------------------
    always @(posedge Clk) begin
        if (Rst) begin
            // Reset all registers on reset
            r_Count <= 0;
            r_OutValid <= 0;
            OutValid_v <= 0;
        end else begin
            // Update counter on rising edge
            if (In_Ratio != 0) begin
                if (In_Valid) r_Count = r_Count + 1;
                else r_Count = r_Count;
            else
                r_Count = 0;
            end
            // Delay output pulse for latency
            Out_Valid_v = (Latency_g == 0) ? Out_Valid : 0;
            // Final output decision
            Out_Valid = Out_Valid_v;
        end
    end

endmodule
