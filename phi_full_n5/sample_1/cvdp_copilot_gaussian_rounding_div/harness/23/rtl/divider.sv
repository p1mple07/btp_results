module divider #(parameter WIDTH = 32)
(
    input  wire                  clk,
    input  wire                  rst_n,      // Active-low asynchronous reset
    input  wire                  start,      // Start signal for new operation
    input  wire [WIDTH-1:0]    dividend,   // Dividend (numerator)
    input  wire [WIDTH-1:0]    divisor,    // Divisor (denominator)
    output reg [WIDTH-1:0]    quotient,   // Result of the division
    output reg [WIDTH-1:0]    remainder,  // Remainder after division
    output wire                valid
);

    // Initialize registers
    reg [WIDTH-1:0] aq, m;
    reg [$clog2(WIDTH)-1:0] n;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            n <= WIDTH;
            aq <= {WIDTH{1'b0}, dividend};
            m <= divisor;
        end
        else begin
            case (n)
                0: begin
                    n <= WIDTH - 1;
                    m <= m << 1;
                end
                1: begin
                    n <= WIDTH - 2;
                    m <= m << 1;
                    if (aq[WIDTH-1] == 1'b1) begin
                        aq <= aq + m;
                    end else begin
                        aq <= aq - m;
                    end
                end
                _: begin
                    if (aq[WIDTH-1] == 1'b1) begin
                        aq <= aq;
                    end
                    n <= n - 1;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (!start) begin
            quotient <= 0;
            remainder <= 0;
            valid <= 0;
        end else begin
            if (n == 0) begin
                quotient <= aq[WIDTH-1:0];
                remainder <= aq[2*WIDTH-1:WIDTH];
                valid <= 1'b1;
            end
        end
    end

endmodule
