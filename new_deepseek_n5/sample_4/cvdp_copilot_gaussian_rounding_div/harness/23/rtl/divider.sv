module divider #(parameter WIDTH = 32)
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

    reg [AW+WIDTH-1:0] aq_reg, aq_next;
    reg [AW-1:0] m_reg, m_next;
    reg [$clog2(WIDTH)-1:0] n_reg, n_next;

    reg [WIDTH-1:0] quotient_reg, quotient_next;
    reg [WIDTH-1:0] remainder_reg, remainder_next;
    reg valid_reg, valid_next;

    assign quotient  = quotient_reg;
    assign remainder = remainder_reg;
    assign valid     = valid_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_reg     <= IDLE;
            aq_reg        <= 0;
            m_reg         <= 0;
            n_reg         <= 0;
            quotient_reg  <= 0;
            remainder_reg <= 0;
            valid_reg     <= 0;
        else begin
            state_reg     <= state_next;
            aq_reg        <= aq_next;
            m_reg         <= m_next;
            n_reg         <= n_next;
            quotient_reg  <= quotient_next;
            remainder_reg <= remainder_next;
            valid_reg     <= valid_next;
        end
    end

    always @* begin
        state_next     = state_reg;
        aq_next        = aq_reg;
        m_next         = m_reg;
        n_next         = n_reg;
        quotient_next  = quotient_reg;
        remainder_next = remainder_reg;
        valid_next     = valid_reg;

        case (state_reg)
        IDLE: begin
            valid_next = 1'b0;
            if (start) begin
                aq_next = { {AW{1'b0}}, dividend };
                m_next   = {1'b0, divisor};
                n_next   = WIDTH;
                state_next = BUSY;
            end
        end

        BUSY: begin
            aq_next = aq_reg << 1;
            if (aq_reg[AW+WIDTH-1] == 1'b1) begin
                aq_next[AW+WIDTH-1:WIDTH] = aq_next[AW+WIDTH-1:WIDTH] + m_reg;
            else begin
                aq_next[AW+WIDTH-1:WIDTH] = aq_next[AW+WIDTH-1:WIDTH] - m_reg;
            end
            if (aq_next[AW+WIDTH-1] == 1'b1) begin
                aq_next[0] = 1'b0;
            else begin
                aq_next[0] = 1'b1;
            end
            n_next = n_reg - 1;
            if (n_next == 0) state_next = DONE;
        end

        DONE: begin
            if (aq_reg[AW+WIDTH-1] == 1'b1) begin
                aq_next = aq_reg;
                aq_next[AW+WIDTH-1:WIDTH] = aq_reg[AW+WIDTH-1:WIDTH] + m_reg;
            end
            quotient_next = aq_reg[WIDTH-1:0];
            remainder_next = aq_reg[2*WIDTH-1:WIDTH];
            valid_next = 1'b1;
            if (!start) state_next = IDLE else state_next = DONE;
        end

        default: state_next = IDLE;
    endcase
endmodule