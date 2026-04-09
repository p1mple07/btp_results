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
        if (In_Ratio == 0) begin
            r_next_Count = 0;
        end else if (In_Ratio > 0) begin
            r_next_Count = r_Count + 1;
        end else begin
            $display("Invalid division ratio (%0d)", In_Ratio);
        end

        // Latency handling
        if (Latency_g == 0) begin
            r_next_OutValid = r_OutValid;
        end else if (Latency_g == 1) begin
            r_next_OutValid = r_OutValid & ~In_Valid;
        end else begin
            $display("Invalid Latency value");
        end

        // Output ready handshake
        if (~Out_Valid & In_Valid) begin
            r_next_OutValid = 0;
        end else begin
            r_next_OutValid = 1;
        end

        // Output assignment
        Out_Valid = OutValid_v;
    end

    // --------------------------------------------------------
    // Sequential Logic
    // --------------------------------------------------------
    always @(posedge Clk) begin
        if (Rst) begin
            // Reset all internal states to 0
            r_next_Count    = 0;
            r_next_OutValid = 0;
        end else begin
            // Implement the counter logic and latency handling as per the problem description
            // Implement the counter logic and latency handling as per the problem description
            //...

            // Implement the counter logic for division ratio and input pulses
            //...

            // Implement the latency handling
            //...

            // Implement the output ready handshake
            //...

            // Implement the output assignment
            //...

        end
    }