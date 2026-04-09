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
        // Replace `TODO` comments with the appropriate counter logic.
        always @(posedge Clk) begin
            if (In_Ratio > 0) begin
                // Increment the counter by 1 for each valid input pulse.
                r_next_Count <= r_Count + 1;
            end

            // Latency handling
            // Replace `TODO` comments with the appropriate latency handling logic.
            if (Latency_g == 0) begin
                // Pass the next state of Out_Valid directly.
                r_next_OutValid <= In_Valid;
            end else begin
                // Delay the output pulse by one clock cycle.
                r_next_OutValid <= r_OutValid & In_Valid;
            end

        end

        // Output ready handshake
        always @(posedge Clk) begin
            if (In_Valid) begin
                // Replace `TODO` comments with the appropriate handshake logic.
                r_next_OutValid <= r_OutValid & In_Valid;
            end

        end

        // Output assignment
        always @(*) begin
            Out_Valid <= r_next_OutValid;
        end

    endmodule