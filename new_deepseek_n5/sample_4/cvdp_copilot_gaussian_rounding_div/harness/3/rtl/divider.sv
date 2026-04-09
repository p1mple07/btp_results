module divider
(
    parameter WIDTH = 32
)
(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire [WIDTH-1:0]    dividend,
    input  wire [WIDTH-1:0]    divisor,
    output wire [WIDTH-1:0]    quotient,
    output wire [WIDTH-1:0]    remainder,
    output wire                  valid
)
// FSM states
localparam IDLE = 2'b00;
localparam BUSY = 2'b01;
localparam DONE = 2'b10;

// State register
reg [1:0] state_reg, state_next;

// A+Q register
reg [2*WIDTH-1:0] aq_reg, aq_next;

// Divisor register
reg [WIDTH-1:0] m_reg, m_next;

// Bit counter
reg [AWIDTH-1:0] n_reg, n_next;

// Quotient register
reg [WIDTH-1:0] quotient_reg, quotient_next;

// Remainder register
reg [WIDTH-1:0] remainder_reg, remainder_next;

// Valid register
reg valid_reg, valid_next;

// State transition logic
always @(posedge clk or posedge rst_n) begin
    if (rst_n) begin
        state_reg = IDLE;
        state_next = IDLE;
    else if (start) begin
        state_reg = IDLE;
        state_next = BUSY;
    end else if (state_reg == BUSY) begin
        // Load dividend and divisor
        aq_next = dividend;
        m_next = divisor;
        quotient_next = 0;
        n_next = WIDTH - 1;
        state_next = BUSY;
    end else if (state_reg == DONE) begin
        state_next = IDLE;
    end
end

// Main algorithm
always @ (state_reg) begin
    case (state_reg)
        IDLE: begin
            // Initialize registers
            aq_next = aq_reg;
            m_next = m_reg;
            quotient_next = 0;
            n_next = WIDTH - 1;
            state_next = BUSY;
        end
        BUSY: begin
            // Step 1: Shift AQ left
            aq_next = (aq_reg << 1);
            
            // Step 2: Add or subtract M
            if ((aq_reg >> (WIDTH-1)) & 1) begin
                // Sign bit of A is 1
                aq_next = aq_next + m_next;
            else begin
                aq_next = aq_next - m_next;
            end
            
            // Step 3: Update Q[0]
            quotient_next = (aq_reg >> (WIDTH-1)) & 1;
            
            // Step 4: Decrement n
            n_next = n_reg - 1;
            
            // Step 5: If n >=0, continue
            if (n_reg >= 0) begin
                aq_next = aq_next;
                aq_next = aq_next;
                m_next = m_reg;
                quotient_next = quotient_reg;
                n_next = n_reg;
                state_next = BUSY;
            else begin
                // Final adjustment
                if ((aq_reg >> (WIDTH-1)) & 1) begin
                    aq_next = aq_next + m_next;
                end
                state_next = DONE;
            end
        end
        DONE: begin
            valid_next = 1;
            state_next = IDLE;
        end
    end
end

// Assign outputs
assign quotient = quotient_reg;
assign remainder = remainder_reg;
assign valid = valid_reg;