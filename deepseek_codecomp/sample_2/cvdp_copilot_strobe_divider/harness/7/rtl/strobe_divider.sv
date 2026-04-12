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

    // Combinational logic to compute next state and outputs
    always @* begin
        // *** Hold variables stable ***
        r_next_Count    = r_Count;
        r_next_OutValid = r_OutValid;

        // Ratio Counter Logic
        if (In_Valid) begin
            if (In_Ratio == 0 || r_Count >= In_Ratio) begin
                r_next_Count    = 0;
                r_next_OutValid = 1'b1;
            end else begin
                r_next_Count = r_Count + 1;
                // r_next_OutValid remains unchanged
            end
        end

        // Latency Handling
        if (Latency_g == 0) begin
            OutValid_v = r_next_OutValid;
        end else begin
            OutValid_v = r_OutValid;
        end

        // Generate output latency control
        if (OutValid_v && Out_Ready) begin
            r_next_OutValid = 1'b0;
        end

        // Outputs
        Out_Valid = OutValid_v;
    end

    // Sequential logic to update state on clock edge or reset
    always @(posedge Clk) begin
        if (Rst) begin
            r_Count    <= 0;
            r_OutValid <= 1'b0;
        end else begin
            r_Count    <= r_next_Count;
            r_OutValid <= r_next_OutValid;
        end
    end

endmodule