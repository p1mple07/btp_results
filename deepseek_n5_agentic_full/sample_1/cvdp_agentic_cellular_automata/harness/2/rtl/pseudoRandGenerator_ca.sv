module pseudo_rand_generator_ca (
    input logic clock,
    input logic reset,
    input [15:0] CA_seed,
    input [1:0] rule_sel,
    output reg [15:0] CA_out
);

    // State variables
    reg [15:0] CA_out;
    reg [15:0] ca_next;
    integer cycle_count;

    // Precomputed transition table for Rule 30 and Rule 110
    local constant rule30_map: [
        (3, 2, 1, 0) : 0,
        (7, 6, 5, 4) : 1,
        (3, 2, 1, 0) : 1,
        (7, 6, 5, 4) : 0,
        (1, 0, 7, 6) : 1,
        (5, 4, 3, 2) : 1,
        (1, 0, 7, 6) : 1,
        (5, 4, 3, 2) : 0
    ];

    // Compute next state based on current state and rule selection
    always_comb begin
        integer i;
        integer left, center, right;
        integer pattern;
        integer result;

        ca_next = CA_out;
        
        for (i = 0; i < 16; i++) {
            left = ((CA_out[i-1] >> 15) | (~CA_out[i-1] & 16'h1));
            center = CA_out[i];
            right = ((CA_out[i+1] >> 15) | (~CA_out[i+1] & 16'h1));

            // Wrap around indices
            i = (i + 1) % 16;
            j = (i - 1) % 16;

            // Create 3-bit pattern
            pattern = (left << 2) | (center << 1) | right;

            // Determine result based on rule
            case (rule_sel)
                2'b00: result = rule30_map[(pattern >> 2) | (pattern >> 1) | pattern];
                2'b01: result = rule30_map[(pattern >> 2) | (pattern >> 1) | pattern];
                default: result = rule30_map[(pattern >> 2) | (pattern >> 1) | pattern];
            endcase

            ca_next[i] = result;
        }
    end

    always_ff (ca_next -> CA_out) begin
        // Update state on next clock cycle
        CA_out = ca_next;
    end

    // Reset initialization
    initial begin
        CA_out = CA_seed;
    end

    // Testbench control logic
    integer j;
    integer first_seen[65536];
    integer cycle_count = 0;

    initial begin
        // Reset to seed
        reset = 1;
        CA_seed = 16'h1;
        rule_sel = 2'b10;
        #12;
        reset = 0;

        // Collect states during simulation
        for (j = 0; j < 65536; j++) begin
            first_seen[j] = -1;
        end

        #10
        while(true) begin
            #1;
            if (reset) begin
                CA_seed = 16'h1;
                rule_sel = 2'b10;
                #12;
                reset = 0;
            end
            CA_out = ca_next;
            cycle_count++;

            if (cycle_count > 65536) begin
                $display("Completed 65,536 cycles.");
                $finish;
            end

            if (first_seen[CA_out] == -1) begin
                first_seen[CA_out] = cycle_count;
            else begin
                $display("Cycle %0d: Value %h repeated; first seen at cycle %0d",
                         cycle_count, CA_out, first_seen[CA_out]);
            end
        end
    end
endmodule