Okay, I need to modify the aes_encrypt module to change from AES-128 to AES-256. Let's start by understanding the differences between AES-128 and AES-256. 

First, AES-128 uses a 128-bit key, split into four 32-bit words. AES-256 uses a 256-bit key, which means eight 32-bit words. So, the key input needs to be adjusted to accept these additional words. That makes sense because the user already mentioned changing the interface parameters to handle 256 bits.

Next, looking at the key expansion logic. In AES-128, the algorithm processes every fourth word, applying rotations, substitutions, and XOR operations with Rcon. For AES-256, the process is similar but applies Rcon every eighth word instead of every fourth. Also, there's a condition where some iterations don't require rotation or Rcon. I'll need to adjust the loop to check if i mod 8 equals 0 or 4, handling each case differently.

The Rcon array has specific values for each iteration. Since AES-256 requires Rcon up to index 11 (because we're processing every eighth word starting from 0), I'll extend the Rcon array to include these extra values. But wait, in the original code, Rcon was defined up to 3, which might not be sufficient anymore. Oh right, the initial Rcon was for 128-bit keys, so I definitely need to expand it.

Looking at the register sizes, AES-256 requires more round keys. The original code had 44 32-bit words, but now it should be 60. That means the expanded_key array needs to hold more elements. So, I'll change the size of expanded_key accordingly.

Another thing is the number of rounds. AES-128 uses 10 rounds, but AES-256 requires up to 14 rounds. I'll need to adjust the loop that iterates over the rounds to run one more time.

Also, the subkeys and other buffers might need their sizes updated. For example, subkeys were 44 words before, but now they should be 60 words to accommodate all the round keys.

I should also consider how the key is loaded initially. The testbench uses a specific key value, so maybe I need to ensure that the new key format is compatible. But since the user said the sbox doesn't need modification, perhaps the key loading can remain unchanged, relying on the new key expansion to handle it.

Wait, in the key expansion loop, when i is a multiple of 8, I have to rotate the word, substitute, and XOR with Rcon. When i mod 8 is 4, I just take the previous word without rotation or substitution. This adds complexity to the loop, so I need to make sure the conditions are correctly implemented.

Let me outline the steps:
1. Update the key input to accept 256 bits.
2. Modify the key expansion loop to handle every eighth word with Rcon.
3. Extend the Rcon array to include the necessary values up to index 11.
4. Increase the number of round keys stored in expanded_key from 44 to 60.
5. Adjust the round counter to go up to 14.
6. Update the subkeys buffer size to 60 words.
7. Ensure all registers and arrays are sized correctly for AES-256.

I think that covers the main points. Now, I'll proceed to make these changes in the aes_encrypt module.


Here is the modified `aes_encrypt` module for AES-256 encryption:

sv
module aes_encrypt (
    parameter NBW_KEY  = 'd256,
    parameter NBW_DATA = 'd128
) 

// Updated constants for 256-bit key
constant NBW_EXP_KEY_0: 'd8000000000000000000000000000000 = 'd8000000000000000000000000000000;
constant NBW_EXP_KEY_1: 'd8000000000000000000000000000000 = 'd8000000000000000000000000000000;
constant NBW_EXP_KEY_2: 'd8000000000000000000000000000000 = 'd8000000000000000000000000000000;
constant NBW_EXP_KEY_3: 'd8000000000000000000000000000000 = 'd8000000000000000000000000000000;
constant NBW_EXP_KEY_4: 'd8000000000000000000000000000000 = 'd8000000000000000000000000000000;
constant NBW_EXP_KEY_5: 'd8000000000000000000000000000000 = 'd8000000000000000000000000000000;
constant NBW_EXP_KEY_6: 'd8000000000000000000000000000000 = 'd8000000000000000000000000000000;
constant NBW_EXP_KEY_7: 'd8000000000000000000000000000000 = 'd8000000000000000000000000000000;
constant NBW_EXP_KEY_8: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_9: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_10: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_11: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_12: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_13: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_14: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_15: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_16: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_17: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_18: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_19: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_20: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_21: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_22: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_23: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_24: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_25: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_26: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_27: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_28: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_29: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_30: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_31: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_32: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_33: 'd4000000000000000000000000000000 = 'd4000000000000000000000000000000;
constant NBW_EXP_KEY_34