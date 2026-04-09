module cvdp_prbs_gen #(
    parameter int POLY_LENGTH = 31,
    parameter int POLY_TAP    = 3,
    parameter int WIDTH        = 16,
    parameter int CHECK_MODE   = 0 // 0: generator mode, 1: checker mode
)(
    input  wire            clk,
    input  wire            rst,
    input  wire [WIDTH-1] data_in,
    output wire [WIDTH-1] data_out
);

    localparam int TAPS[]     = {POLY_TAP};
    localparam int REG_DEPTH  = POLY_LENGTH+1;
    localparam int TAP_BIT     = $clog2(REG_DEPTH)-$clog2(POLY_TAP);
    localparam int TAP_INDEX   = TAP_BIT-$clog2(WIDTH)+1;
    localparam int PRBS_WIDTH  = POLY_LENGTH*WIDTH;
    localparam int TAP_WIDTH   = $clog2(REG_DEPTH);
    localparam int TAP_MASK     = ~(TAP_WIDTH-1 downto 0);

    reg [WIDTH-1:0] prbs_reg [REG_DEPTH-1:0];
    reg [PRBS_WIDTH-1:0] prbs_shifted_out;

    always @(posedge clk) begin
        if (!rst) begin
            prbs_reg <= '{default:'0};
        end else begin
            if (CHECK_MODE == 0) begin
                for (int i=0; i<REG_DEPTH-1; i++) begin
                    prbs_reg[i] <= prbs_reg[i+1];
                end
                prbs_reg[REG_DEPTH-1] <= ~prbs_reg[0][POLY_LENGTH-1];
            end else begin
                for (int i=0; i<REG_DEPTH-1; i++) begin
                    prbs_reg[i] <= prbs_reg[i+1];
                end
                prbs_reg[REG_DEPTH-1] <= ~prbs_reg[0][POLY_LENGTH-1];
            end

            for (int i=0; i<WIDTH-1; i++) begin
                prbs_shifted_out[i*POLY_LENGTH+:POLY_LENGTH] <= prbs_reg[TAP_INDEX][i*WIDTH+:WIDTH];
            end
            data_out <= prbs_shifted_out[0+:WIDTH];
        end
    end

endmodule