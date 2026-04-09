module pseudo_rand_generator_ca (
    logic clock,
    logic reset,
    logic [15:0] CA_seed,
    logic [1:0] rule_sel,
    logic [15:0] CA_out
);

    // State storage (16-bit CA state)
    ddr [15:0] ca_state;

    // Initialize state to seed on first reset
    initial
        if (reset)
            ca_state = CA_seed;
        end

    // Compute next state using CA rules
    always_comb
        for (int i = 0; i < 16; i++) begin
            // Get current cell and its neighbors with wrap-around
            logic left = ca_state[(i - 1 + 16) % 16];
            logic curr = ca_state[i];
            logic right = ca_state[(i + 1) % 16];
            
            // Determine next bit based on rules
            case (left, curr, right)
                // Rule 30
                111 -> 0;
                110 -> 0;
                101 -> 0;
                100 -> 1;
                011 -> 1;
                010 -> 1;
                001 -> 1;
                000 -> 0;
                default: // Treat as Rule 30 if unknown triplet
                    $assert(1, "Unknown triplet in Rule 30");
            endcase
            ca_state_next[i] = result;
        endfor

    // Update state on next clock cycle
    always_ff @posedge clock
        if (!reset)
            ca_state = ca_state_next;

    // Store results for testbench
    reg [15:0] ca_out;

    // Alias for output
    wire ca_out == ca_state;

endmodule