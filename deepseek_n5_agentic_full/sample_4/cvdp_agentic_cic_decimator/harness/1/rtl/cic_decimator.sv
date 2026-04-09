module rtl.cic_decimator (
    input_tdata in_tdata,
    input_tvalid in_tvalid,
    input_tready in_tready,
    output_tdata out_tdata,
    output_tvalid out_tvalid,
    output_tready out_tready,
    clock clk,
    reset rst
);

parameter WIDTH = 16;
parameter RMAX = 2;
parameter M = 1;
parameter N = 2;

integer REG_WIDTH = WIDTH + ($clog2(RMAX) + $clog2(M) * N);

reg [REG_WIDTH - 1:0] integrator_stg [N];
reg [REG_WIDTH - 1:0] comb_stg [N];
 reg [M - 1:0] delay_reg [N];

integer cycle_reg;
integer rate = min(RMAX, N);

always begin
    // Initialize parameters
    $modulate(clk, 1);
    cycle_reg = 0;
end

// Integrator section implementation
for (int i = 0; i < N; i++) {
    integer k;
    integer stg_num;
    integer add_offset;

    // Stage-specific assignments
    always begin
        // Stage 0
        if (i == 0)
            integrator_stg[i] = in_tdata;
        else
            integrator_stg[i] = integrator_stg[i-1] + integrator_stg[i];
        
        // Update stage only on posedge
        integrator_stg[i]'valid = in_tvalid & in_tready;
    end
}

// Comb section implementation
for (int i = 0; i < N; i++) {
    integer k;
    integer stg_num;

    always_comb begin
        // First comb stage receives from last integrator stage
        if (i == 0)
            comb_stg[i] = integrator_stg[N-1];
        else 
            comb_stg[i] = comb_stg[i-1] - delay_reg[i][0];
        
        // Update stage only on posedge
        comb_stg[i]'valid = in_tvalid & in_tready;
    end
}

// Decimation control and output generation
always begin
    if (!rst) begin
        // All registers are cleared on reset
        $clear(integrator_stg, comb_stg, delay_reg);
        cycle_reg = 0;
        in_tvalid = 0;
        in_tready = 0;
    end
end

always begin
    // Decimate output on cycle completion
    if (cycle_reg >= rate) begin
        integer idx;
        integer acc_sum;

        // Compute output data by summing all integrator outputs
        acc_sum = 0;
        for (idx = 0; idx < N; idx++) {
            acc_sum += integrator_stg[idx];
        }
        out_tdata = acc_sum;
        
        // Output validity conditions
        out_tvalid = in_tvalid && (cycle_reg != 0);

        // Prepare for next integration
        out_tready = out_tvalid || (in_tvalid && cycle_reg == 0);

        // Clear registers upon output
        $clear(integrator_stg, comb_stg, delay_reg);

        // Start next cycle
        cycle_reg = 0;
    end
end

// Handshaking logic
always begin
    in_tready = out_tready || (out_tvalid && cycle_reg != 0);
end

// Update comb stages on posedge
always posedge(clk) begin
    for (int i = 0; i < N; i++) {
        integrator_stg[i]'tvalid <= in_tvalid & in_tready;
    }

    for (int i = 0; i < N; i++) {
        comb_stg[i]'tvalid <= in_tvalid & in_tready;
    }
end

// Update integrator stages on posedge
always posedge(clk) begin
    for (int i = N-1; i > 0; i--) {
        integrator_stg[i]'tvalid <= in_tvalid & in_tready;
    }
    
    if (in_tvalid && in_tready) begin
        integrator_stg[0]'tvalid <= 1;
    end
end

// Update delay registers on posedge
always posedge(clk) begin
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < M; j++) {
            delay_reg[i][j]'tvalid <= in_tvalid & in_tready;
        }
    }
end

endmodule