Module
module rtl.cic_decimator (
    input    clock,
    input    rst,
    input    input_tdata,
    input    input_tvalid,
    input    input_tready,
    output   output_tdata,
    output   output_tvalid,
    output   output_tready,
    input    rate
);

    // Define the register width calculation
    integer reg_width = 18;

    // Module-level variables
    reg signed [reg_width-1:0] input_tacc记忆化;
    reg signed [reg_width-1:0] integrator_result;
    reg [reg_width-1:0] comb_output;
    reg cycle_reg = 0;

    // Integrator Section
    generate for (i = 0; i < 2; i++) {
        signed [reg_width-1:0] acc_value = 0;

        always_comb begin
            if (i == 0)
                acc_value = input_tdata;
            else
                acc_value = integrator_result;
        end

        integrator_result = integrator_result + acc_value;
    }

    // Comb Section
    generate for (j = 0; j < 2; j++) {
        signed [reg_width-1:0] comb_value = 0;

        always_comb begin
            if (j == 0)
                comb_value = integrator_result;
            else
                comb_value = comb_output;
        end

        unsigned [M-1:0] delay addressed;
        // Assuming M=1 for simplicity, adjust accordingly

        // Difference computation
        unsigned diff = comb_value ^ ((unsigned)(comb_value >> M));

        comb_output = comb_output - diff;
    }

    // Decimation Control
    int rate_val = (int) rate;

    // Decimate control logic
    always_comb begin
        if (!rst) begin
            cycle_reg = 0;
            integrator_result = 0;
            comb_output = 0;
        end

        // Only update when data is available
        if (input_tready && !rst) begin
            // Increment cycle counter
            cycle_reg = cycle_reg + 1;
            
            if (cycle_reg >= rate_val) begin
                // Decimation point reached
                cycle_reg = 0;
                output_tvalid = true;
            end

            // Enable accumulators on valid input
            #clock_enable(integrator_result, input_tvalid);
            #clock_enable(comb_output, !rst || (cycle_reg != 0));
        end
    end

    // Output the results
    output_tdata = comb_output;
    output_tvalid = false;
    output_tready = false;

endmodule