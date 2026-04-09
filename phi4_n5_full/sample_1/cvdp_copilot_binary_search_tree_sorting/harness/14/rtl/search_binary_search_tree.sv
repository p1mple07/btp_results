/* 
    File: rtl/search_binary_search_tree.sv
    Description: This module implements an RTL search for a given search_key in a BST.
    The BST is represented by three packed arrays: keys, left_child, and right_child.
    The search traverses the BST in an in‐order fashion to determine the sorted position
    of the search_key if found. If the BST is empty or the key is not found, the module
    asserts search_invalid and outputs a null key_position.
    
    FSM States:
      S_IDLE         - Waits for the start signal and resets internal variables.
      S_INIT         - Checks for an empty tree and compares search_key with the root.
                      Depending on the comparison, it either starts a left traversal,
                      or pushes the root for later right subtree processing.
      S_SEARCH_LEFT  - Traverses the left subtree. While traversing, if the search_key is found,
                      the inorder count is used to compute key_position.
      S_SEARCH_LEFT_RIGHT - After finishing the left subtree, this state processes the right subtree.
      S_COMPLETE_SEARCH  - Completes the search: if found, asserts complete_found; otherwise,
                      asserts search_invalid.
*/

module search_binary_search_tree #(
    parameter DATA_WIDTH = 32,         // Width of the data (of a single element)
    parameter ARRAY_SIZE = 15          // Maximum number of elements in the BST
) (
    input         clk,                         // Clock signal
    input         reset,                       // Reset signal
    input         start,                       // Start signal to initiate the search
    input  [DATA_WIDTH-1:0] search_key,        // Key to search in the BST
    input  [$clog2(ARRAY_SIZE):0] root,         // Root node of the BST (always 0)
    input  [ARRAY_SIZE*DATA_WIDTH-1:0] keys,    // Node keys in the BST
    input  [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] left_child,  // Left child pointers
    input  [ARRAY_SIZE*($clog2(ARRAY_SIZE)+1)-1:0] right_child, // Right child pointers
    output reg [$clog2(ARRAY_SIZE):0] key_position,   // Position of the found key (or null if not found)
    output reg