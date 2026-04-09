input delete_key; // Replaces search_key
output complete_deletion; // Replaces complete_found
output delete_invalid; // Replaces search_invalid
output modified_keys, modified_left_child, modified_right_child; // New outputs

// State machine for deletion
   case (S_*, S_*, ...)
       // SINIT: Initialize deletion parameters
       ...
       // S	search_left: Traverse left subtree if needed
       ...
       // S search_left_right: Traverse both subtrees
       ...
       // S DEL: Perform actual deletion based on children count
           if (node has both children):
               find in-order successor
               replace current node with successor
               delete successor
           else if (node has one child):
               replace current node with child
           else:
               mark node as invalid
       ...
       // S Complete deletion: Finalize deletion
   endcase

// After deletion, update keys, left_child, right_child
   if (node index exists):
       modified_keys[node_index] = DELETE_KEY_INVALID;
       modified_left_child[node_index] = DELETE_LEFT_INVALID;
       modified_right_child[node_index] = DELETE_RIGHT_INVALID;