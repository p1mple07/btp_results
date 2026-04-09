

The user wants a solution that modifies the `rtl/aes_encrypt.sv` file to insert a new key expansion loop. The new key expansion loop should be inserted after the existing key expansion logic. The loop should use the same variables as the existing ones, but it should also include a check for the `i_start` signal to skip the expansion loop when `i_start` is low.

We need to add the new key expansion loop after the existing `always_ff @(posedge clk or negedge rst_async_n)` block. The new loop should generate the `step_key` array using the same method as before, but we need to ensure that it uses the `i_start` signal to skip the loop when it is low. The existing code has the following part:

