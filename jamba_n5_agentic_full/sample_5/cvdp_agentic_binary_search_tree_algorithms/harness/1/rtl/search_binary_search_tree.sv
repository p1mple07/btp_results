module delete_node_binary_search_tree #(
    parameter DATA_WIDTH = 16,         // Width of the data
    parameter ARRAY_SIZE = 5           // Maximum number of elements in the BST
) (
    input clk,                         // Clock signal
    input reset,                       // Reset signal
    input reg start,                   // Start signal to initiate the search
    input reg [DATA_WIDTH-1:0] search_key, // Key to search in the BST
    input reg [$clog2(ARRAY_SIZE):0] root, // Root node of the BST
    input reg [ARRAY_SIZE*DATA_WIDTH-1:0] keys, // Node keys in the BST
    input reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] left_child, // Left child pointers
    input reg [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] right_child, // Right child pointers
    output reg [$clog2(ARRAY_SIZE):0] key_position, // Position of the found key
    output reg complete_deletion,         // Signal indicating deletion complete
    output reg delete_invalid,             // Signal indicating delete invalid
    output reg modified_keys,             // Updated keys after deletion
    output reg modified_left_child,       // Updated left children
    output reg modified_right_child,      // Updated right children
    output reg search_invalid
);
