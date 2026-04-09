Module declaration
module cic_decimator (
    input clock,
    input rst,
    input [WIDTH-1:0] input_tdata,
    input input_tvalid,
    input input_tready,
    output [REG_WIDTH-1:0] output_tdata,
    output output_tvalid,
    output output_tready
);

// Parameters
parameter WIDTH = 16;
parameter RMAX = 2;
parameter M = 1;
parameter N = 2;

// Register width calculation
parameter REG_WIDTH = WIDTH * N; // 32 bits

// Module internals
reg [
    N-1 downto 0
] intg_acc; // Array of integrator accumulators
reg [
    N-1 downto 0
] comb_reg; // Array of comb stage registers
wire [
    N-1 downto 0
] delay_reg; // Delay registers per comb stage

// State variables
integer cycle_reg = 0;

// Clock control
always_comb begin
    if (rst == 1)
        intg_acc[i]'s = 0;
    else if (clockposedge(clk))
        // Integrator section
        intg_acc[0] = intg_acc[0] + input_tdata;
        for (int i = 1; i < N; i++) {
            intg_acc[i] = intg_acc[i-1] + intg_acc[i];
        }

        // Combinatorial section
        comb_reg[0] = comb_reg[0] ^ delay_reg[0];
        for (int i = 1; i < N; i++) {
            comb_reg[i] = comb_reg[i-1] ^ comb_reg[i];
            delay_reg[i] = delay_reg[i-1] >> 1;
        }
    end

    // Decimation control
    if (cycle_reg == RMAX - 1) {
        output_tvalid = 1;
        cycle_reg = 0;
    } else {
        output_tvalid = 0;
        output_tready = 1;
        for (int i = N-1; i >= 0; i--) {
            delay_reg[i] = comb_reg[i];
        }
    }
end

// Validity handshakes
always_comb begin
    input_tready = output_tready || (cycle_reg != 0);
    output_tready = 0;
end

// Reset handling
always_comb begin
    if (rst == 1)
        cycle_reg = 0;
    else if (input_tvalid & input_tready)
        cycle_reg++;
    end
end

// Module initialization
initial begin
    // Initialize all registers to 0
    intg_acc[i]'s = 0;
    comb_reg[i]'s = 0;
    delay_reg[i]'s = 0;
    cycle_reg = 0;
    // Enable only once after power-up
    rst = 1;
    #1000
    rst = 0;
end

// End module declaration
endmodule