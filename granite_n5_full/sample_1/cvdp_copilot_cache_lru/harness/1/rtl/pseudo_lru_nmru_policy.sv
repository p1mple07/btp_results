module pseudo_lru_nmru_policy #(
    parameter NWAYS = 4,
    parameter NINDEXES = 32
) (
    input wire clock,
    input wire reset,
    input wire [$clog2(NINDEXES)-1:0] index,
    input wire [$clog2(NWAYS)-1:0] way_select,
    input wire access,
    input wire hit,
    output wire [$clog2(NWAYS)-1:0] way_replace
);

    reg [NWAYS-1:0] recency [NINDEXES-1:0];

    integer reset_counter;
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            for (reset_counter = 0; reset_counter < NINDEXES; reset_counter = reset_counter + 1) begin
                recency[reset_counter] <= {NWAYS{1'b0}};
            end
        end else begin

        end
    end

    always_comb begin : update_recency
        if (access &&!hit) begin
            recency[index][way_select] <= 1'b1;
        end
    end

    always_comb begin : select_way_to_replace
        if (!access) begin // Non-access cycle
            case ({1'b0, recency})
                {{NWAYS{1'b1}}, 1'b0}:
                    way_replace = $unsigned'(index * NWAYS + popcount({NWAYS{1'b1}}));
                default:
                    way_replace = 0;
            endcase
        end else begin // Access cycle
            case ({1'b0, recency})
                {{NWAYS{1'b1}}, 1'b0}:
                    way_replace = 0; // LRU: Replacement must be done from cache set with smallest index
                default:
                    way_replace = index * NWAYS + popcount({NWAYS{1'b1}}); // NMRU: First available way
            endcase
        end
    end

endmodule