module pseudo_lru_nmru_policy #(
    parameter int NWAYS = 4,
    parameter int NINDEXES = 32
) (
    input  logic                clock,
    input  logic                reset,
    input  logic [$clog2(NINDEXES)-1:0] index,
    input  logic [$clog2(NWAYS)-1:0]  way_select,
    input  logic                access,
    input  logic                hit,
    output logic [$clog2(NWAYS)-1:0] way_replace
);

  // The recency array tracks the recency bit for each cache way per index.
  // A value of 0 indicates that the way has not been recently accessed.
  logic [NWAYS-1:0] recency [NINDEXES-1:0];

  integer reset_counter;

  //-------------------------------------------------------------------------
  // Sequential block: Update the recency array on access events.
  //-------------------------------------------------------------------------
  always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
      // On reset, clear all recency bits.
      for (reset_counter = 0; reset_counter < NINDEXES; reset_counter = reset_counter + 1) begin
        recency[reset_counter] <= '0;
      end
    end
    else if (access) begin
      if (hit) begin
        // On a cache hit, mark the accessed way as recently used.
        recency[index][way_select] <= 1'b1;
      end
      else begin
        // On a miss, select a replacement candidate based on the recency bits.
        integer i;
        integer zero_count = 0;
        // Count how many ways are marked as not recently used (bit = 0).
        for (i = 0; i < NWAYS; i = i + 1) begin
          if (recency[index][i] == 1'b0)
            zero_count = zero_count + 1;
        end

        if (zero_count == 1) begin
          // LRU behavior: Only one candidate exists.
          // Find that candidate, then clear all bits and mark it as used.
          for (i = 0; i < NWAYS; i = i + 1) begin
            if (recency[index][i] == 1'b0) begin
              recency[index] <= '0;
              recency[index][i] <= 1'b1;
            end
          end
        end
        else if (zero_count > 1) begin
          // NMRU behavior: Multiple candidates exist.
          // Choose the candidate with the smallest index (lowest bit number)
          // and mark it as used.
          for (i = 0; i < NWAYS; i = i + 1) begin
            if (recency[index][i] == 1'b0) begin
              recency[index][i] <= 1'b1;
              break;
            end
          end
        end
        else begin
          // If no zero bits are found, default to candidate 0.
          recency[index][0] <= 1'b1;
        end
      end
    end
  end

  //-------------------------------------------------------------------------
  // Combinational block: Determine the replacement way based on recency bits.
  //-------------------------------------------------------------------------
  always_comb begin
    integer j;
    integer rep_zero_count = 0;
    // Default candidate.
    way_replace = '0;

    // Count the number of zero bits in the recency array for the selected index.
    for (j = 0; j < NWAYS; j = j + 1) begin
      if (recency[index][j] == 1'b0)
        rep_zero_count = rep_zero_count + 1;
    end

    if (rep_zero_count == 1) begin
      // LRU: Only one candidate exists; select that one.
      for (j = 0; j < NWAYS; j = j + 1) begin
        if (recency[index][j] == 1'b0) begin
          way_replace = j;
          break;
        end
      end
    end
    else if (rep_zero_count > 1) begin
      // NMRU: Multiple candidates exist; choose the one with the smallest index.
      for (j = 0; j < NWAYS; j = j + 1) begin
        if (recency[index][j] == 1'b0) begin
          way_replace = j;
          break;
        end
      end
    end
    else begin
      // If no zero bits exist, default to candidate 0.
      way_replace = 0;
    end
  end

endmodule