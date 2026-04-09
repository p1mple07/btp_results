
module divider #
(
    parameter WIDTH = 32
)
(
    input  wire                  clk,
    input  wire                  rst_n,      
    input  wire                  start,      
    input  wire [WIDTH-1 : 0]    dividend,   
    input  wire [WIDTH-1 : 0]    divisor,    
    output wire [WIDTH-1 : 0]    quotient,   
    output wire [WIDTH-1 : 0]    remainder,  
    output wire                  valid       
);

    localparam AW = WIDTH + 1;
    // FSM states
    localparam IDLE = 2'b00;
    localparam BUSY = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state_reg, state_next;

    // AQ register: A (upper AW bits) and Q (lower WIDTH bits)
    reg [AW+WIDTH-1 : 0] aq_reg, aq_next;

    // Divisor register
    reg [AW-1 : 0] m_reg, m_next;

    // Iteration counter (number of bits processed)
    reg [$clog2(WIDTH)-1:0] n_reg, n_next;

    // Final outputs registers
    reg [WIDTH-1:0] quotient_reg, quotient_next;
    reg [WIDTH-1:0] remainder_reg, remainder_next;
    reg valid_reg, valid_next;

    // Output assignments
    assign quotient  = quotient_reg;
    assign remainder = remainder_reg;
    assign valid     = valid_reg;

    // Next state logic and output logic
    always @(*) begin
        // Default assignments
        state_next = state_reg;
        aq_next = aq_reg;
        m_next = m_reg;
        n_next = n_reg;
        quotient_next = quotient_reg;
        remainder_reg = remainder_reg; // no update by default
        valid_next = valid_reg;

        case (state_reg)
            IDLE: begin
                if (start) begin
                    state_next = BUSY;
                    // Load registers: A = 0, Q = dividend, m = divisor, n = WIDTH
                    aq_next = { {AW{1'b0}}, dividend }; // top AW bits = 0, lower = dividend
                    m_next = divisor;
                    n_next = WIDTH;
                    quotient_next = {WIDTH{1'b0}};
                    remainder_reg = {WIDTH{1'b0}};
                    valid_next = 1'b0;
                end
            end

            BUSY: begin
                // Decision bit from previous A (MSB of A)
                // A is in aq_reg[AW+WIDTH-1 : WIDTH]
                // MSB of A is aq_reg[AW+WIDTH-1]
                bit decision;
                decision = aq_reg[AW+WIDTH-1];

                // Shift left AQ by 1: new AQ = { aq_reg[AW+WIDTH-1:1], 1'b0 }
                // But we need to compute new A and new Q separately.
                // New A = (aq_reg[AW+WIDTH-1:WIDTH] << 1) + (decision ? m_reg : -m_reg)
                // new Q = (aq_reg[WIDTH-1:0] << 1) | (~newA[AW-1])
                // Let's compute newA first.
                // We need to extend m_reg to AW bits: {1'b0, m_reg}
                wire [AW-1:0] m_ext = {1'b0, m_reg};
                wire [AW-1:0] sub_m = ~m_ext + 1; // two's complement of m_ext

                wire [AW-1:0] shifted_A = aq_reg[AW+WIDTH-1:WIDTH] << 1;
                wire [AW-1:0] newA;
                if (decision)
                    newA = shifted_A + m_ext;
                else
                    newA = shifted_A + sub_m; // addition of two's complement gives subtraction

                // The quotient bit is the inverse of the MSB of newA (i.e., ~newA[AW-1])
                bit q_bit;
                q_bit = ~newA[AW-1];

                // New Q = (aq_reg[WIDTH-1:0] << 1) OR q_bit
                wire [WIDTH-1:0] shifted_Q = aq_reg[WIDTH-1:0] << 1;
                wire [WIDTH-1:0] newQ = shifted_Q | q_bit;

                // Combine new A and new Q into aq_next
                aq_next = { newA, newQ };

                // Decrement iteration counter
                n_next = n_reg - 1;

                // Stay in BUSY if more iterations remain, else transition to DONE
                if (n_reg != 0)
                    state_next = BUSY;
                else
                    state_next = DONE;

                // In BUSY, outputs are not valid yet.
                valid_next = 1'b0;
            end

            DONE: begin
                // Final adjustment: if sign bit of A is 1, then A = A + m_reg
                // A is in aq_reg[AW+WIDTH-1: WIDTH]
                // Check MSB of A: aq_reg[AW+WIDTH-1]
                if (aq_reg[AW+WIDTH-1])
                    remainder_reg = (aq_reg[AW+WIDTH-1:WIDTH] + {1'b0, m_reg})[WIDTH-1:0];
                else
                    remainder_reg = aq_reg[AW+WIDTH-1:WIDTH][WIDTH-1:0];

                // Quotient is the Q part of aq_reg
                quotient_next = aq_reg[WIDTH-1:0];

                // Remain valid until start is de-asserted
                valid_next = 1'b1;

                // Transition back to IDLE when start is low.
                if (!start)
                    state_next = IDLE;
                else
                    state_next = DONE;
            end

            default: state_next = IDLE;
        endcase
    end

    // Sequential block
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_reg <= IDLE;
            aq_reg   <= { (AW+WIDTH){1'b0} };
            m_reg    <= {AW{1'b0}};
            n_reg    <= { $clog2(WIDTH){1'b0} };
            quotient_reg <= {WIDTH{1'b0}};
            remainder_reg <= {WIDTH{1'b0}};
            valid_reg <= 1'b0;
        end else begin
            state_reg <= state_next;
            aq_reg   <= aq_next;
            m_reg    <= m_next;
            n_reg    <= n_next;
            quotient_reg <= quotient_next;
            remainder_reg <= remainder_reg; // updated in combinational always block for DONE state, but we need to update in sequential block as well.
            valid_reg <= valid_next;
        end
    end

endmodule
