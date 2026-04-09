module pseudo_rand_generator_ca(
    input logic clock,
    input logic reset,
    input logic[15:0] CA_seed,
    input logic[1:0] rule_sel,
    output logic[15:0] CA_out
);

    // Function to get previous bit value considering wrap-around
    function logic get_left_neighbor(bit pos) {
        if (pos == 0) return 15;
        else return pos - 1;
    }

    function logic get_right_neighbor(bit pos) {
        if (pos == 15) return 0;
        else return pos + 1;
    }

    // Compute next bit value based on rule
    function logic compute_next_bit(bit pos, logic[2:0] rule) {
        bit left = get_left_neighbor(pos);
        bit center = (CA_out[pos] ? 1 : 0);
        bit right = get_right_neighbor(pos);

        logic[3:0] triplet;
        triplet[2] = left;
        triplet[1] = center;
        triplet[0] = right;

        case (triplet)
            3'b111: out = 0;
            3'b110: out = 0;
            3'b101: out = 0;
            3'b100: out = 1;
            3'b011: out = 1;
            3'b010: out = 1;
            3'b001: out = 1;
            default: out = 0;
        endcase
    }

    // Always combinatorial block to compute next state
    always_comb begin
        logic[16:0] next_state = {15{0}};
        
        for (int i = 0; i < 16; i++) {
            next_state[i] = compute_next_bit(i, (rule_sel << 1) & 2);
        }
    end

    // Register to hold current state
    reg [15:0] CA_out;

    // State update
    always logic [
        posedge clock
    ] begin
        if (reset) begin
            CA_out = CA_seed;
        else
            CA_out = next_state;
        end
    end

endmodule