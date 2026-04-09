Module declarations
module gcd_top(
    parameter WIDTH,
    input_clk,
    input_rst,
    input_A,
    input_B,
    input_go,
    output_OUT,
    output_done
);

    // Instantiate control path
    gcd_controlpath gcd_controlpath(
        input_clk,
        input_rst,
        input_go,
        input_equal,
        input_greater_than,
        output_state,
        output_done
    );

    // Instantiate datapath
    gcd_datapath gcd_datapath(
        input_clk,
        input_rst,
        input_A,
        input_B,
        input_state,
        output_OUT,
        output_equal,
        output_greater_than
    );
endmodule

// GCD Control Path Module
module gcd_controlpath(
    input_clk,
    input_rst,
    input_go,
    input_equal,
    input_greater_than,
    output_state,
    output_done
);

    // State definitions
    enum state {
        S0 = 0,
        S1 = 1,
        S2 = 2,
        S3 = 3
    };

    // FSM state
    state current_state = S0;

    // Control signals
    output_state = 0;

    // Process
    always_comb begin
        if (input_rst) begin
            current_state = S0;
            output_done = 0;
        else if (input_go) begin
            if (current_state == S0) begin
                current_state = S1;
            else if (current_state == S1) begin
                current_state = S0;
            else if (current_state == S2) begin
                current_state = S3;
            else if (current_state == S3) begin
                current_state = S0;
            end
        end
    end

    // Output done signal
    output_done = (current_state == S1);
endmodule

// GCD Datapath Module
module gcd_datapath(
    input_clk,
    input_rst,
    input_A,
    input_B,
    input_state,
    output_OUT,
    output_equal,
    output_greater_than
);

    // Internal registers
    reg A_ff, B_ff;

    // FSM state
    enum state {
        S0 = 0,
        S1 = 1,
        S2 = 2,
        S3 = 3
    };

    // State transitions
    always_comb begin
        if (input_rst) begin
            A_ff = 0;
            B_ff = 0;
            state = S0;
        end else if (input_state == S0) begin
            if (A_ff == B_ff) begin
                state = S1;
                output_equal = 1;
                output_greater_than = 0;
            else if (A_ff > B_ff) begin
                state = S2;
                output_greater_than = 1;
                output_equal = 0;
            else begin
                state = S3;
                output_equal = 0;
                output_greater_than = 1;
            end
        end else if (input_state == S1) begin
            // No operation
        end else if (input_state == S2) begin
            A_ff = A_ff - B_ff;
            state = S0;
        end else if (input_state == S3) begin
            B_ff = B_ff - A_ff;
            state = S0;
        end
    end

    // Final output
    output_OUT = A_ff;
endmodule

// Main top module implementation
module gcd_top(
    parameter WIDTH,
    input_clk,
    input_rst,
    input_A,
    input_B,
    input_go,
    output_OUT,
    output_done
);

    // Instantiate control path
    gcd_controlpath gcd_controlpath(
        input_clk,
        input_rst,
        input_go,
        input_equal,
        input_greater_than,
        output_state,
        output_done
    );

    // Instantiate datapath
    gcd_datapath gcd_datapath(
        input_clk,
        input_rst,
        input_A,
        input_B,
        output_state,
        output_OUT,
        output_equal,
        output_greater_than
    );
endmodule