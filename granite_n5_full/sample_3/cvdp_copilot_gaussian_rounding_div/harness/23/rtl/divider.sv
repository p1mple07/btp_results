module
module divider #(parameter WIDTH = 32) (
    input  wire                  clk,
    input  wire                  rst_n,      // Active-low asynchronous reset
    input  wire                  start,      // Start signal for new operation
    input  wire [WIDTH-1 : 0]    dividend,   // Dividend (numerator)
    input  wire [WIDTH-1 : 0]    divisor,    // Divisor (denominator)
    output wire [WIDTH-1 : 0]    quotient,   // Result of the division
    output wire [WIDTH-1 : 0]    remainder,  // Remainder after division
    output wire                  valid       // Indicates output is valid
);

    // one extra bit for A
    localparam AW = WIDTH + 1;
    // Simple 3-state FSM
    localparam IDLE = 2'h00;
    localparam BUSY = 2'h01;
    localparam DONE = 2'h10;

    reg [1:0] state_reg, state_next;

    // A+Q combined into one WIDTH times
    reg [AW+WIDTH-1 : 0] aq_reg,   aq_next;

    // Divisor register
    reg [AW-1 : 0]       m_reg,    m_next;

    // Iterate exactly WIDTH times
    reg [$clog2(WIDTH)-1:0] n_reg, n_next;

    // Final outputs
    reg [WIDTH-1 : 0] quotient_reg, quotient_next;
    reg [WIDTH-1 : 0] remainder_reg, remainder_next;
    reg valid_reg, valid_next;

    //------------------------------------------------
    // SEQUENTIAL: State & register updates
    //------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Default "hold" behavior
            state_reg     <= IDLE;
            aq_reg        <= 0;
            m_reg         <= 0;
            n_reg         <= $clog2(WIDTH);
            quotient_reg <= 0;
            remainder_reg <= 0;
            valid_reg    <= 0;
        end
        else begin
            // Default "hold" behavior
            state_reg     <= IDLE;
            aq_reg        <= 0;
            m_reg         <= 0;
            n_reg         <= 0;
            quotient_reg <= 0;
            remainder_reg <= 0;
            valid_reg    <= 0;
        end
        else begin
            // 1) SHIFT LEFT
            aq_next = aq_reg << 1;

            // 2) If sign bit of A == 1? Then perform the N iterations
            for (i=0 to 11):
            for (i=0 to 11), we want to iterate 10000 iterations.
            for (i=0 to 10000), we want to divide.
            For example, let's assume that the dividend is between 1 and 1000000000.

            The division process is as follows:
            - 1) SHIFT LEFT content of AQ.
             1) Check the sign bit of A.
             2) Shift Left content of AQ.
             3) Check the sign bit of A.
             4) Check if dividend < 10000.
             5) Shift Left content of AQ.
             6) Check if dividend is < 100000.
             7) Shift Left content of AQ.
             8) Check the sign bit of AQ.
             9) Shift Left content of AQ.
             10) Check if dividend is > 1000000.
             11) Shift Left content of AQ to AQ.
            12) Check the sign bit of AQ.
            13) Shift Left content of AQ.
            14) Check whether the input is positive.
            15) If the input is positive, set the first two bits.
            16) Shift Left content of AQ.
            17) Generate the code that generate the code for the Shifted Right.
            For example:
            for (i=0 to i=15) begin
                // 2) Shift Left content of AQ.
                // 3) If sign bit of AQ is 1, then shift left content of AQ.
                // 4) Shift Left content of AQ and sign bit of AQ.
                // 5) Check the sign bit of AQ
    // 6) Shift Left content of AQ.
                // 7) Shift Left content of AQ.
                // 8) Check the sign bit of AQ.
                // 9) Shift Left content of AQ.
                // 10) If the sign bit of AQ is 1, then generate the
    for (i=0 to i=15) begin
                    // 1) Update the file.
    for (i=0 to i=15) begin
                        // 2) Generate the code for the Shifted Right.
    for (i=0 to i=15) begin
                        // 3) Shift Left content of AQ.
                        // 4) Shift Left content of AQ.
                        // 5) Shift Left content of AQ.
    end
endmodule