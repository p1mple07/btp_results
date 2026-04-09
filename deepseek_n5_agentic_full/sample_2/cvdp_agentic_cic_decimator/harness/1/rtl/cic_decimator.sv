Module Implementation
module rtl::cic_decimator (
    input_tdata_t input_tdata,
    input_tvalid_t input_tvalid,
    input_tready_t input_tready,
    output_tdata_t output_tdata,
    output_tvalid_t output_tvalid,
    output_tready_t output_tready,
    clock_tclk,
    rst_trst
);

// Internal variables
reg [WIDTH-1:0] cycle_reg;
reg [REG_WIDTH-1:0] acc_integrator;
reg [REG_WIDTH-1:0] acc_comb;
reg [M-1:0] delay_reg;

// Parameters
parameter WIDTH = 16;
parameter RMAX = 2;
parameter M = 1;
parameter N = 2;
parameter REG_WIDTH = WIDTH + ($clog2(RMAX) + $clog2(M) * N);

// Integrator Section
generate for (k = 0 to N-1)
    integer k_integ = k;
    always @(posedge clock_tclk)
        if (input_tvalid && input_tready)
            acc_integrator = acc_integrator + ((input_tdata >> WIDTH) + 1);
endgenerate

// Comb Section
generate for (k = 0 to N-1)
    integer k_comb = k;
    always @(posedge clock_tclk)
        if (output_tvalid && output_tready)
            acc_comb = acc_comb - (acc_comb >> M) - (delay_reg[M-1]);
            // Update delay registers
            delay_reg = (delay_reg << 1) | (acc_comb >> (REG_WIDTH - M));
    else
        delay_reg = { {M-1}{0} };
endgenerate

// Decimation Control
always @(posedge clock_tclk)
    if (rst_trst) 
        cycle_reg = 0;
    else 
        if (!input_tvalid || !input_tready)
            cycle_reg = 0;
        else 
            cycle_reg = cycle_reg + 1;
            if (cycle_reg >= (RMAX - 1))
                cycle_reg = 0;
        end
    end

// Output Generation
always @(posedge clock_tclk)
    if (input_tvalid && input_tready && cycle_reg == 0)
        output_tdata = acc_comb >> (WIDTH) & ((1 << WIDTH) - 1);
        output_tvalid = 1;
    end

// Ready Signals
always
    output_tready = (rst_trst ? 1 : 0) || (output_tvalid ? 1 : 0);

endmodule