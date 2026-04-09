module continuous_adder (
    input logic         clk,         // Clock signal
    input logic         reset,       // Reset signal, Active high and Synchronous
    input logic [#{DATA_WIDTH}-1:0]   data_in,     // Input data stream (DATA_WIDTH bit)
    input logic         data_valid,  // Input data valid signal
    output logic [#{DATA_WIDTH}-1:0]  sum_out,     // Output the accumulated sum
    output logic        sum_ready    // Signal to indicate sum is output and accumulator is reset
);

    parameter logic         DATA_WIDTH     = 32,     // Width of data stream
    parameter logic         THRESHOLD_VALUE  = 100,    // Threshold value for sum accumulation
    parameter logic         SIGNED_INPUTS   = 1;     // Enable signed arithmetic (1) or unsigned (0)

    logic [#{DATA_WIDTH}-1:0] sum_accum;          // Internal accumulator to store the running sum

    // Sequential logic for sum accumulation
    always_ff @(posedge clk) begin
        if (reset) begin
            // On reset, clear the accumulator, reset sum_out and sum_ready
            sum_accum         <= 8'd0;
            sum_ready         <= 1'b0;
        end
        else begin
            if (data_valid) begin
                // Add input data to the accumulator
                logic [#{DATA_WIDTH}-1:0] temp_sum;
                if (SIGNED_INPUTS) begin
                    temp_sum = data_in;
                else
                    temp_sum = data_in;
                end
                sum_accum     <= sum_accum + temp_sum;

                // Check if the accumulated sum is beyond threshold
                logic THRESHOLD_NEG = -(THRESHOLD_VALUE);
                if (sum_accum >= THRESHOLD_VALUE || sum_accum <= THRESHOLD_NEG) begin
                    // Output the current sum and reset the accumulator
                    sum_out   <= sum_accum;
                    sum_ready <= 1'b1;
                    sum_accum <= 8'd0;
                end
                else begin
                    // No output yet
                    sum_ready <= 1'b0;
                end
            end
        end
    end

    // Constraint checks
    if (SIGNED_INPUTS && (THRESHOLD_VALUE >= (1 << (DATA_WIDTH-1)))) begin
        $warning "Threshold value exceeds maximum signed value for DATA_WIDTH";
        sum_ready <= 1'b0;
    end
    if (!SIGNED_INPUTS && (THRESHOLD_VALUE >= (1 << DATA_WIDTH))) begin
        $warning "Threshold value exceeds maximum unsigned value for DATA_WIDTH";
        sum_ready <= 1'b0;
    end