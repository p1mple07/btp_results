Module declaration
module cic_decimator (
    input clock,
    input reset,
    input [WIDTH] input_tdata,
    input input_tvalid,
    input input_tready,
    output [REG_WIDTH] output_tdata,
    output output_tvalid,
    output output_tready
);

// Parameters
parameter WIDTH = 16;
parameter RMAX = 2;
parameter M = 1;
parameter N = 2;

// Register width calculation
parameter REG_WIDTH = WIDTH + (log2(RMAX * M) * N); // Calculates to 18

// Clock domain
clock domain mainclk = phase 0 period 10;

// Description
// This module implements a 2nd-order Cascaded Integrator-Comb (CIC)
// decimation filter with parameters WIDTH=16, RMAX=2, M=1, and N=2.
// The design consists of integrator and comb stages followed by decimation
// control using a cycle counter.

// Integrator stages setup
reg [
    WIDTH + (log2(M) * N)
] integrator_tstage[N];

// Variables for the cycle counter
int cycle_reg = 0;

// Comb stages setup
reg [
    M + (log2(M) * N)
] comb_tstage[N];

// Carry bits for integrator addition
reg carry_integrator [
    N
];
reg carry_comb [
    N
];

// Output registers
reg [
    REG_WIDTH
] output_reg;

// Clocking and handshaking
always_comb begin
    if (reset == 1 || input_tvalid == 0) 
        # Reset the entire system
        integrator_tstage.all = 0;
        comb_tstage.all = 0;
        output_reg = 0;
        
    if (input_tvalid && !input_tready) 
        # Start accepting new input samples
        cycle_reg <= 0;
        integrator_tstage[0].carry_in <= input_tdata;
        comb_tstage[0].input <= integrator_tstage[-1].output;
        
    if (input_tvalid && input_tready) 
        # Data is valid and ready; process through the pipeline
        for (int i = 0; i < N; i++) {
            integrator_tstage[i].carry_out <= carry_integrator[i];
            integrator_tstage[i+1].carry_in <= integrator_tstage[i].carry_out;
        }
        
        for (int i = N-1; i > 0; i--) {
            comb_tstage[i-1].difference <= comb_tstage[i].output ^ comb_tstage[i-1].output;
            comb_tstage[i-1].carry_out <= comb_tstage[i].carry_out;
            comb_tstage[i].carry_in <= comb_tstage[i-1].carry_out;
        }
        
        if (cycle_reg >= RMAX - 1 || cycle_reg >= rate - 1) 
            # Decimation point reached; assert output validity
            output_tvalid <= 1;
            
        cycle_reg <= (cycle_reg + 1) % (RMAX);
        
        if (!comb_tstage[-1].difference) 
            # If comb stage output is zero, reset the counter
            cycle_reg <= 0;
        end
end

// Output
output_tdata <= output_reg[0];
output_tvalid <= output_tvalid & (output_reg.valid);
output_tready <= output_tready | (output_tvalid & !output_tready);

// Wait for simulation to complete
task done;
endmodule