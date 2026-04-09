module pseudo_lru_nmru_policy #(
    parameter int NWAYS = 4,
    parameter int NINDEXES = 32
) (
    input  logic clock,
    input  logic reset,
    input  logic [($clog2(NINDEXES))-1:0] index,
    input  logic [($clog2(NWAYS))-1:0] way_select,
    input  logic access,
    input  logic hit,
    output logic [($clog2(NWAYS))-1:0] way_replace
);

    // Array to track recency for each cache way at every index.
    // Each element is a vector of NWAYS bits.
    reg [NWAYS-1:0] recency [NINDEXES-1:0];

    // Registered output for the replacement way.
    reg [($clog2(NWAYS))-1:0] way_replace_reg;

    // Internal loop variables.
    integer i, j;
    integer zero_count;
    integer chosen;

    // Synchronous process: on reset, initialize recency; on access update recency and select replacement.
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            // Reset: clear all recency bits for every index.
            for (i = 0; i < NINDEXES; i = i + 1) begin
                recency[i] <= '0;
            end
        end
        else begin
            if (access) begin
                if (hit) begin
                    // On a cache hit, mark the accessed way as recently used.
                    recency[index][way_select] <= 1'b1;
                end
                else begin
                    // On a miss, select a replacement way based on recency bits.
                    // Count the number of zero bits (i.e. not recently used) at the given index.
                    zero_count = 0;
                    for (i = 0; i < NWAYS; i = i + 1) begin
                        if (recency[index][i] == 1'b0)
                            zero_count = zero_count + 1;
                    end

                    if (zero_count == 1) begin
                        // LRU case: exactly one way is not recently used.
                        // Find that way, update recency (set chosen to 1, clear all others), and assign as replacement.
                        for (j = 0; j < NWAYS; j = j + 1) begin
                            if (recency[index][j] == 1'b0) begin
                                way_replace_reg <= j;
                                recency[index][j] <= 1'b1;
                                for (i = 0; i < NWAYS; i = i + 1) begin
                                    if (i != j)
                                        recency[index][i] <= 1'b0;
                                end
                                break;
                            end
                        end
                    end
                    else if (zero_count > 1 || zero_count == 0) begin
                        // NMRU case: either multiple ways are free or none are marked as free.
                        // Choose the free slot with the smallest index.
                        if (zero_count > 0) begin
                            chosen = NWAYS; // initialize with an invalid value
                            for (i = 0; i < NWAYS; i = i + 1) begin
                                if (recency[index][i] == 1'b0) begin
                                    chosen = i;
                                    break;
                                end
                            end
                        end
                        else begin
                            // If no zero bits exist, choose way 0.
                            chosen = 0;
                        end
                        way_replace_reg <= chosen;
                        // Update recency: if no zeros existed, clear all and mark the chosen one as 1;
                        // if multiple zeros exist, simply mark the chosen one as 1.
                        if (zero_count == 0) begin
                            for (i = 0; i < NWAYS; i = i + 1) begin
                                recency[index][i] <= 1'b0;
                            end
                            recency[index][chosen] <= 1'b1;
                        end
                        else begin
                            recency[index][chosen] <= 1'b1;
                        end
                    end
                end
            end
            // If access is deasserted, no update is performed.
        end
    end

    // Drive the output port.
    assign way_replace = way_replace_reg;

endmodule