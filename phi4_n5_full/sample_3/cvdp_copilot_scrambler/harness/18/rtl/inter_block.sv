Below is the lint review for the inter_block module (excluding the intra_block instantiation):

1. Unused Signal:
   • The signal “counter_output” (and its related parameter “NBW_COUNTER_OUTPUT”) is declared but never used anywhere in the module. If this signal is not required, it should be removed to avoid confusion.

2. Mixing Blocking and Non-blocking Assignments:
   • In the always_ff block that updates out_data_aux and out_data, the for loop uses blocking assignments (using “=”) to update bit slices of the signals. All sequential logic in always_ff blocks should use non-blocking assignments (“<=”) to ensure proper simulation semantics and to avoid unintended race conditions.
   • It is recommended to replace the blocking assignments within the for loop with non-blocking assignments. For example, change:
     
     out_data_aux[0][(i+1)*CHUNK-1-:CHUNK] = out_data_intra_block_reg[i%4][((i+1)*CHUNK)-1-:CHUNK];
     
     to
     
     out_data_aux[0][(i+1)*CHUNK-1-:CHUNK] <= out_data_intra_block_reg[i%4][((i+1)*CHUNK)-1-:CHUNK];
     
   • Apply similar changes for the other assignments in that loop.

This review addresses the two issues identified and provides suggestions to improve the RTL code for better clarity and correct simulation behavior.