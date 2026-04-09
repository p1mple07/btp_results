module pseudo_rand_generator_ca (
    input logic clock,
    input logic reset,
    input logic [15:0] CA_seed,
    input logic [1:0] rule_sel,
    output logic [15:0] CA_out
)

    // Function to compute next state bit
    function logic bit compute_next_bit(input logic bit left, input logic bit center, input logic bit right, input logic bit [1:0] rule) {
        case { 111, 110, 101, 011 }
            if (rule == 2'b00) return 0;
            else return 1;
        case { 100, 010 }
            if (rule == 2'b00) return 1;
            else return 0;
        default
            return compute_next_bit(1, 0, 1, 2'b00); // Default to Rule 30
    }

    // Compute next state using cellular automata function
    always_comb logic [15:0] next_state = compute_next_bit(
        CA_out[(15 + (i - 1)) % 16], 
        CA_out[i], 
        CA_out[(i + 1) % 16], 
        rule_sel
    ) for i in 0 to 15;

    // Update state on posedge clock
    always_ff @posedge clock
        if (reset)
            CA_out <= CA_seed;
        else
            CA_out <= next_state;

endmodule