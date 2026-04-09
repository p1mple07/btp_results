Module: pseudo_lru_tree_policy
// Description:
//   Implements a strict Pseudo Least Recently Used (PLRU) replacement policy 
//   for a set-associative cache using a tree-based approach. Each cache set 
//   has a recency tree (stored as a linear array) that is updated on every 
//   access. On a cache hit, the tree is updated along the path for the 
//   accessed way (way_select) to mark it as most recently used (MRU). On a 
//   cache miss, the replacement way is determined by traversing the tree 
//   (via the slot_select_pseudo_lru_tree submodule) and then the tree is 
//   updated along that path to mark the replaced way as MRU.
//------------------------------------------------------------------------------
module pseudo_lru_tree_policy #(
    parameter NWAYS    = 4,
    parameter NINDEXES = 32
)(
    input  clock,
    input  reset,
    input  [$clog2(NINDEXES)-1:0] index,
    input  [$clog2(NWAYS)-1:0] way_select,
    input  access,
    input  hit,
    output [$clog2(NWAYS)-1:0] way_replace
);

    // Number of bits in the recency tree (NWAYS leaves -> NWAYS-1 internal nodes)
    localparam int unsigned NBITS_TREE = NWAYS - 1;
    // Depth of the binary tree (log2(NWAYS))
    localparam int unsigned MAX_DEPTH = $clog2(NWAYS);

    // Recency array: one per cache set, storing the internal nodes of the tree
    reg [NBITS_TREE-1:0] recency [NINDEXES-1:0];

    // Wires for the updated recency tree and the replacement way from the tree traversal
    wire [NBITS_TREE-1:0] recency_updated;
    wire [$clog2(NWAYS)-1:0] pseudo_lru_slot;

    integer i;

    //-------------------------------------------------------------------------
    // Sequential logic: On reset, initialize all recency trees to 0.
    // On every access, update the recency tree for the selected cache set.
    //-------------------------------------------------------------------------
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                recency[i] <= '0;
            end
        end else begin
            if (access) begin
                recency[index] <= recency_updated;
            end
        end
    end

    //-------------------------------------------------------------------------
    // Combinational logic: Compute the updated recency tree.
    // For a cache hit, traverse the tree along the path for way_select and 
    // update each node to reflect that the accessed way is now MRU.
    // For a cache miss, traverse the tree along the path determined by 
    // pseudo_lru_slot (the replacement way) and update accordingly.
    //-------------------------------------------------------------------------
    // Temporary signal to hold the new tree value.
    logic [NBITS_TREE-1:0] new_tree;
    always_comb begin
        // Start with the current recency tree for the given cache set.
        new_tree = recency[index];
        integer pos = 0;
        // Traverse the tree from the root (level 0) to the leaf.
        for (i = 0; i < MAX_DEPTH; i = i + 1) begin
            // Compute the index in the linear array for the current node.
            // Mapping: node index = (2^i - 1) + current_position
            int node_index = ((1 << i) - 1) + pos;
            if (hit)
                // For a hit, use the bit from way_select (MSB first)
                new_tree[node_index] = way_select[i];
            else
                // For a miss, use the corresponding bit from the replacement path
                new_tree[node_index] = pseudo_lru_slot[i];
            // Update the current position in the tree:
            // If the bit is '1', move to the right child; otherwise remain.
            if ((hit ? way_select[i] : pseudo_lru_slot[i]) == 1'b1)
                pos = pos + (1 << i);
        end
        recency_updated = new_tree;
    end

    //-------------------------------------------------------------------------
    // Instantiate the slot_select_pseudo_lru_tree module.
    // This submodule traverses the recency tree (given as a linear array)
    // to determine the replacement way. The traversal follows the bits:
    // a '0' indicates a move to the left child; a '1' indicates a move to 
    // the right child.
    //-------------------------------------------------------------------------
    slot_select_pseudo_lru_tree #(
        .NWAYS (NWAYS)
    ) slot_select_unit (
        .array (recency[index]),
        .index (pseudo_lru_slot)
    );

    // Drive the replacement output.
    assign way_replace = pseudo_lru_slot;

endmodule : pseudo_lru_tree_policy

//------------------------------------------------------------------------------
// Module: slot_select_pseudo_lru_tree
// Description:
//   Traverses the pseudo-LRU tree (represented as a linear array) to select 
//   the least recently used (LRU) way for replacement. The traversal starts 
//   at the root (array index 0) and, at each level, follows the bit: if the 
//   bit is '0', move to the left child; if '1', move to the right child.
//   The final leaf index is then converted to a binary vector (MSB first).
//------------------------------------------------------------------------------
module slot_select_pseudo_lru_tree #(
    parameter NWAYS = 4
)(
    input  [NWAYS-2:0] array,
    output logic [$clog2(NWAYS)-1:0] index
);

    // Depth of the binary tree.
    localparam int unsigned MAX_DEPTH = $clog2(NWAYS);
    integer pos, depth;
    integer node_index;

    always_comb begin
        pos = 0;
        // Traverse the tree from level 0 to MAX_DEPTH-1.
        for (depth = 0; depth < MAX_DEPTH; depth = depth + 1) begin
            // Calculate the node index in the linear array.
            node_index = ((1 << depth) - 1) + pos;
            // If the bit is '1', go to the right child; otherwise, left.
            if (array[node_index] == 1'b1)
                pos = pos + (1 << depth);
        end
        // Convert the resulting leaf index (pos) into a binary vector.
        // The most significant bit is assigned to bit 0.
        for (depth = 0; depth < MAX_DEPTH; depth = depth + 1) begin
            index[depth] = (pos >> (MAX_DEPTH - 1 - depth)) & 1'b1;
        end
    end

endmodule