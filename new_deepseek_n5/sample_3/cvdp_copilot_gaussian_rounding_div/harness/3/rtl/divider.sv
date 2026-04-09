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
    localparam IDLE = 2'b00;
    localparam BUSY = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state_reg, state_next;

    reg [AW+WIDTH-1 : 0] aq_reg, aq_next;
    reg [AW-1 : 0]       m_reg, m_next;
    reg [AW-1 : 0]       n_reg, n_next;
    reg [WIDTH-1:0]      quotient_reg, quotient_next;
    reg [WIDTH-1:0]      remainder_reg, remainder_next;
    reg valid_reg, valid_next;

    if (start) begin
        m_reg = dividend;
        aq_reg = dividend;
        state_next = BUSY;
    end

    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            state_reg = IDLE;
            aq_reg = 0;
            m_reg = 0;
            n_reg = WIDTH;
            quotient_reg = 0;
            remainder_reg = 0;
            valid_reg = 0;
        end else if (state_reg == IDLE) begin
            if (start) begin
                state_reg = BUSY;
                aq_next = aq_reg;
                m_next = m_reg;
            end
        end else if (state_reg == BUSY) begin
            if (n_reg == 0) begin
                state_next = DONE;
            end else begin
                n_next = n_reg - 1;
                aq_next = (aq_reg << 1) | (valid ? (n_reg % 2) ? 1 : 0 : 0);
                
                if (valid) begin
                    if (valid) begin
                        if (valid) begin
                            m_next = m_reg;
                        end else begin
                            m_next = m_reg ^ (1 << (WIDTH-1));
                        end
                    end
                end else begin
                    m_next = m_reg;
                end

                if (valid) begin
                    if (valid) begin
                        if (valid) begin
                            quotient_next = quotient_reg | (1 << (WIDTH-1 - n_reg));
                        end else begin
                            quotient_next = quotient_reg;
                        end
                    end else begin
                        quotient_next = quotient_reg;
                    end
                else begin
                    quotient_next = quotient_reg;
                end

                if (valid) begin
                    if (valid) begin
                        if (valid) begin
                            remainder_next = remainder_reg + m_reg;
                        end else begin
                            remainder_next = remainder_reg - m_reg;
                        end
                    end else begin
                        remainder_next = remainder_reg;
                    end
                else begin
                    remainder_next = remainder_reg;
                end
            end
        end else if (state_reg == DONE) begin
            valid_next = 1;
        end
    end

    assign aq_next = aq_next;
    assign m_next = m_next;
    assign n_next = n_next;
    assign quotient_next = quotient_next;
    assign remainder_next = remainder_next;
    assign valid_next = valid_next;

    always @* valid begin
        quotient_reg = quotient_reg;
        remainder_reg = remainder_reg;
        valid_reg = valid;
    end

    // Final adjustment
    if (valid) begin
        if (remainder_reg[WIDTH-1] == 1) begin
            remainder_reg = remainder_reg + m_reg;
        end
    end

    // Update state
    state_reg = state_next;
endmodule