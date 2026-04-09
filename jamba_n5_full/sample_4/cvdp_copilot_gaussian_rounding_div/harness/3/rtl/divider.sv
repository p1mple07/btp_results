module divider #(
    parameter WIDTH = 32
) (
    input  wire clk,
    input  wire rst_n,
    input  wire start,
    input  wire [WIDTH-1:0] dividend,
    input  wire [WIDTH-1:0] divisor,
    output wire [WIDTH-1:0] quotient,
    output wire [WIDTH-1:0] remainder,
    output wire valid
);

    localparam IDLE = 2'b00;
    localparam BUSY = 2'b01;
    localparam DONE = 2'b10;

    reg [1:0] state_reg, state_next;
    reg [AW-1:0] aq_reg, aq_next;
    reg [AW-1:0] a_reg, a_next;
    reg [AW-1:0] m_reg, m_next;
    reg [WIDTH-1:0] q_reg, q_next;
    reg [WIDTH-1:0] r_reg;

    assign state_next = case (state_reg)
        IDLE => BUSY,
        BUSY => DONE,
        default => IDLE;
    endassign

    assign aq_next = a_reg + q_reg;
    assign a_next = a_reg;
    assign m_next = m_reg;
    assign q_next = (a_reg ^ q_reg) + a_reg - m_reg;
    assign r_reg = a_reg ^ q_reg;

    assign valid = a_reg != 0 ? 1'b1 : 1'b0;

    always @(posedge clk) begin
        if (~rst_n) begin
            state_reg <= IDLE;
            a_reg <= 0;
            m_reg <= 0;
            q_reg <= 0;
            r_reg <= 0;
            valid <= 1'b1;
            quotient <= 0;
            remainder <= 0;
        end else begin
            #5;
        end
    end

endmodule
