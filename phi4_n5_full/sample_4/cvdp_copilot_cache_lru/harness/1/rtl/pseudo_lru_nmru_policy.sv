module pseudo_lru_nmru_policy #(
    parameter integer NWAYS = 4,
    parameter integer NINDEXES = 32
) (
    input         clock,
    input         reset,
    input  [$clog2(NINDEXES)-1:0] index,
    input  [$clog2(NWAYS)-1:0]    way_select,
    input         access,
    input         hit,
    output reg [$clog2(NWAYS)-1:0] way_replace
);

  // recency array: for each cache set (indexed by 'index'), track a bit per way.
  reg [NWAYS-1:0] recency [NINDEXES-1:0];

  integer reset_counter;
  integer i;
  integer zero_count;
  integer candidate;

  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      // Initialize all recency bits to 0 for every index.
      for (reset_counter = 0; reset_counter < NINDEXES; reset_counter = reset_counter + 1) begin
        recency[reset_counter] <= {NWAYS{1'b0}};
      end
    end
    else begin
      // Process only for the selected cache set.
      if (access) begin
        if (hit) begin
          // On a cache hit, update the recency bit for the accessed way.
          recency[index][way_select] <= 1'b1;
          // No replacement decision is needed on a hit.
        end
        else begin
          // On a miss, determine the replacement candidate based on recency.
          zero_count = 0;
          // Count how many ways have a zero recency bit (i.e. not recently used).
          for (i = 0; i < NWAYS; i = i + 1) begin
            if (recency[index][i] == 1'b0)
              zero_count = zero_count + 1;
          end

          if (zero_count == 1) begin
            // LRU mode: exactly one way is marked for replacement.
            // Update recency bits: set the chosen (zero) bit to 1 and reset all others to 0.
            for (i = 0; i < NWAYS; i = i + 1) begin
              if (recency[index][i] == 1'b0)
                recency[index][i] <= 1'b1;
              else
                recency[index][i] <= 1'b0;
            end
            // Identify the candidate (the bit that was zero).
            candidate = 0;
            for (i = 0; i < NWAYS; i = i + 1) begin
              if (recency[index][i] == 1'b0) begin
                candidate = i;
                break;
              end
            end
            way_replace = candidate;
          end
          else if (zero_count > 1) begin
            // NMRU mode: multiple ways are eligible for replacement.
            // Choose the free slot with the smallest index (i.e. lowest bit position).
            candidate = NWAYS; // initialize to an invalid value
            for (i = 0; i < NWAYS; i = i + 1) begin
              if (recency[index][i] == 1'b0) begin
                candidate = i;
                break;
              end
            end
            // In the unlikely event that no zero is found, default to way 0.
            if (candidate == NWAYS)
              candidate = 0;
            way_replace = candidate;
            // Note: In NMRU mode, the recency bits remain unchanged.
          end
          else begin
            // No zero bits found (i.e. all ways are marked as recently used).
            // Default replacement candidate is way 0.
            way_replace = 0;
          end
        end
      end
      // If 'access' is not asserted, no update is performed.
    end
  end

endmodule