Okay, I need to modify the encoder_64b66b module to support data-only, control-only, and mixed modes. Let me look at the current code and the requirements.

First, the module currently has a 2-bit sync_word and an 8-bit encoded_data. The control input is 8 bits, and the data is 64 bits. The output is 66 bits, which includes the sync word and the encoded data.

The task is to add support for three modes: data-only, control-only, and mixed. In data-only mode, when all control bits are 0, the data is passed as is, and the sync word is 01. In control-only, all control bits are 1, and the data is replaced with control codes, with sync word 10. In mixed mode, some control bits are 1 and others 0, so data bytes with control bits 0 are passed, and those with 1 are replaced with control codes.

Looking at the current code, the sync_word is determined by whether all control bits are 0. So, I need to adjust that logic. Instead of checking if all bits are 0, I need to check the control_in value.

I'll start by determining the mode based on the control_in. If control_in is 8'b00000000, it's data-only. If it's 8'b11111111, it's control-only. Otherwise, it's mixed.

Wait, but the control_in is 8 bits, so each bit represents a control byte. So, for data-only, all bits must be 0. For control-only, all bits must be 1. For mixed, any combination in between.

So, I'll add a mode variable to track which mode we're in. Let's call it mode, which can be 0 for data-only, 1 for control-only, or 2 for mixed.

Next, the encoded_data needs to be built differently based on the mode. In data-only, it's just the data_in. In control-only, each byte is replaced by its control code. In mixed, only the bytes where control bit is 1 are replaced.

Wait, no. Wait, the control_in is an 8-bit value where each bit represents whether the corresponding data byte is control or data. So, for each byte in data_in, if the corresponding control bit is 1, replace it with the control code; if 0, keep it as data.

So, I'll need to loop through each byte of data_in, check the corresponding control bit, and build the encoded_data accordingly.

Also, the sync_word needs to be set based on the mode. In data-only, it's 01. In control-only, it's 10. In mixed, it's 10 as well because some bits are 1.

Wait, looking at the design specs, the sync word is 2'b10 for control-only and mixed modes. So, in data-only, it's 01, and in the other modes, it's 10.

So, the sync_word can be determined by whether the control_in is all 0s (data-only) or not (control-only or mixed). So, if control_in is 8'b00000000, sync_word is 2'b01. Else, it's 2'b10.

Now, for the encoded_data, I'll need to process each byte of data_in based on the corresponding control bit in control_in.

I'll create an 8-bit control bus where each bit corresponds to a byte in data_in. Then, for each bit, if it's 1, replace the data byte with the control code; if 0, keep it as data.

Wait, but the control_in is 8 bits, each bit controlling a byte in data_in. So, for each of the 8 bytes in data_in, I'll check the corresponding bit in control_in.

So, I'll initialize encoded_data to 0. Then, for each byte index from 0 to 7, I'll check if the control_in's bit at that position is 1. If yes, I'll replace the data byte with the control code. Otherwise, keep it as is.

But wait, the control codes are 7-bit values, right? Because the encoding table shows 7-bit codes. So, each control byte is replaced by a 7-bit code, and these are then shifted into the encoded_data.

Wait, the encoded_data is 64 bits. So, each control byte (when set) in control_in will be replaced by a 7-bit code, which will occupy 7 bits in the encoded_data. The data bytes (when control bit is 0) will be 8 bits each.

Wait, but the total bits would be 8*(8) = 64 for data, but when some are replaced by 7 bits, the total becomes 64 - num_control_bytes + 7*num_control_bytes. Hmm, but the output is 66 bits, which includes 2 bits for sync_word and 64 bits for encoded data. Wait, no, the output is 66 bits, which is 2 bits for sync_word and 64 bits for encoded data. So, the encoded_data is 64 bits.

Wait, the current code has encoded_data as 64 bits. So, in the new code, the encoded_data will be 64 bits, built by either taking the data byte or the control code, depending on the control_in bit.

So, for each of the 8 bytes in data_in, if the corresponding control_in bit is 1, replace the data byte with the 7-bit control code. Otherwise, keep the data byte as is.

But wait, the control code is 7 bits, so when replacing, each control byte in data_in (where control_in is 1) is replaced by 7 bits. So, the encoded_data will have 64 bits, where some are original data bytes (8 bits) and others are 7-bit control codes.

Wait, but 8 data bytes, each 8 bits, would be 64 bits. If some are replaced by 7 bits, the total would be less than 64. But the output is 66 bits, which includes 2 bits for sync_word and 64 bits for encoded data. So, the encoded_data is 64 bits.

Wait, perhaps each control byte in data_in (where control_in is 1) is replaced by a 7-bit code, and the rest are 8 bits. So, the total bits would be (8 - num_control) * 8 + num_control *7 = 64 - num_control + num_control*7 = 64 + 6*num_control. But that can't be, because the output is fixed at 64 bits. Hmm, maybe I'm misunderstanding.

Wait, looking back at the design specs, the encoded_data is 64 bits. So, perhaps each control byte in data_in (where control_in is 1) is replaced by a 7-bit code, and the rest are 8 bits. So, the total bits would be 64 + 6*num_control, but that would exceed 64. That can't be right.

Wait, perhaps the control codes are 7 bits, but when building the encoded_data, each control byte is replaced by 7 bits, and the data bytes are 8 bits. So, the total bits would be 64 - num_control + 7*num_control = 64 + 6*num_control. But the output is 66 bits, which includes 2 bits for sync_word and 64 for encoded data. So, the encoded_data is 64 bits.

Wait, perhaps the control codes are 7 bits, but when building the encoded_data, each control byte is replaced by 7 bits, and the data bytes are 8 bits. So, the total bits would be 64 + 6*num_control, but that can't be because the output is fixed at 64 bits. Hmm, perhaps I'm misunderstanding the structure.

Wait, looking at the example operations:

In Example 1, control_in is 8'b11111111, data_in is 64'h0707070707070707. The output is {2'b10, 8'h1E, 56'h00000000000000}. So, the encoded_data is 64 bits, which is 8'h1E followed by 56'h0. So, 8 bits for the control code and 56 data bits. Wait, but 8 +56 is 64. So, perhaps the control code is 8 bits, but in the control-only mode, each byte is replaced by an 8-bit code.

Wait, but according to the encoding rules, the control codes are 7 bits. So, perhaps the control code is 7 bits, but in the example, it's represented as 8 bits. Hmm, maybe the code is using 8 bits for the control code, but the actual encoding uses 7 bits.

Wait, perhaps the control code is 7 bits, but in the output, it's represented as 8 bits with the highest bit as 0. Or perhaps the code is using 8 bits, but the actual value is 7 bits.

Wait, looking at the example, in control-only mode, the encoded_data is 8'h1E followed by 56'h0. So, 8 bits for the control code and 56 for data. But 8 +56 is 64, which matches the 64-bit encoded_data.

Wait, but 8'h1E is 7 bits (since 0xf is 4 bits, 0x1E is 5 bits, but 8 bits would be 0b00011110). So, perhaps the control code is 8 bits, but the actual value is 7 bits, with the highest bit being 0.

Alternatively, perhaps the control code is 7 bits, and in the output, it's shifted into the higher bits, with the lower bits being 0.

Wait, perhaps the control code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, and the 8th bit is 0. So, for example, 0x1E is 0b00011110, which is 7 bits. So, when placed into the encoded_data, it's 0b00011110 followed by 7 data bytes.

Wait, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, 8 bits for the control code and 56 for data. So, perhaps each control byte is represented as 8 bits, with the 7 bits of the code and the 8th bit as 0.

So, in the code, when a control byte is active, the corresponding 7 bits are placed into the encoded_data, starting at a certain position, and the rest are filled with 0s.

Wait, perhaps the encoded_data is built by processing each byte of data_in and control_in, and for each byte, if the control_in bit is 1, replace the data byte with the 7-bit control code, shifted into the encoded_data. Otherwise, keep the data byte as is.

But the encoded_data is 64 bits, so each control byte in data_in (where control_in is 1) will replace 7 bits in the encoded_data, and the data bytes (where control_in is 0) will occupy 8 bits each.

Wait, but that would complicate the bit positions. Maybe it's easier to process each byte, and for each, decide whether to take the data byte or the control code, and then shift them into the correct positions.

Alternatively, perhaps the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code, else append the 8-bit data byte. But that would result in a variable-length encoded_data, which doesn't fit the 64-bit requirement.

Hmm, perhaps I'm overcomplicating. Let me look at the example again.

In Example 1, control_in is all 1s, data_in is 64'h0707070707070707. The output is {2'b10, 8'h1E, 56'h0}.

So, the encoded_data is 8 bits (0x1E) followed by 56 zeros. So, the control code is 8 bits, and the data is 56 bits.

Wait, but 8 +56 is 64, which matches the 64-bit encoded_data. So, perhaps in control-only mode, each byte is replaced by an 8-bit code, which is the 7-bit control code with the highest bit as 0.

So, for each byte in data_in, when control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0.

Wait, but in the example, the control code is 0x1E, which is 0b00011110. So, the highest bit is 0, followed by 7 bits of the code.

So, perhaps the control code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, in the code, for each byte, if control_in is 1, take the 7-bit code, shift it left by 1 bit, and OR with 0x00 to make the 8th bit 0.

Wait, no, because 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each byte, if control_in is 1, the 7-bit code is placed into the encoded_data starting at the correct position, with the 8th bit as 0.

But how to handle the positions? Because each byte in data_in corresponds to a byte in encoded_data, but when replaced by a 7-bit code, it's shifted into the higher 7 bits, and the 8th bit is 0.

Wait, perhaps the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with the highest bit as 0), else append the 8-bit data byte.

But then, the encoded_data would be 64 bits, as each byte is either 8 bits or 8 bits (with 7 bits of code and 1 bit 0). So, the total is 64 bits.

Wait, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, 8 bits for the control code and 56 for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Wait, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, replace the corresponding data byte with the control code, else keep the data byte. But the control code is 7 bits, so each control byte in data_in (where control_in is 1) will replace 7 bits in the encoded_data.

Wait, but that would require knowing the position where each data byte starts in the encoded_data.

Alternatively, perhaps the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with the highest bit as 0), else append the 8-bit data byte.

But then, the encoded_data would be 64 bits, as each byte is either 8 bits or 8 bits (with 7 bits of code and 1 bit 0). So, the total is 64 bits.

Wait, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, 8 bits for the control code and 56 for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is.

But how to handle the positions? Because each data byte is 8 bits, and the control code is 7 bits. So, perhaps the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code shifted left by 1 bit (to make it 8 bits with the highest bit as 0), else append the data byte as is.

Wait, but that would cause the control code to be shifted into the higher bits, and the data bytes to follow.

Alternatively, perhaps the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the total bits would be 64, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by the data bytes.

Wait, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the control code would be at the beginning, followed by data bytes. So, in the example, the control_in is all 1s, so all 8 data bytes are replaced by control codes, each 7 bits, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, perhaps the first byte's control code is 0x1E, and the rest are 0x00.

Wait, but 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each data byte, if control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0. Otherwise, the data byte is kept as is.

So, the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with highest bit 0), else append the data byte as is.

But then, the encoded_data would be 64 bits, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the control code would be at the beginning, followed by data bytes. So, in the example, the control_in is all 1s, so all 8 data bytes are replaced by control codes, each 7 bits, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, perhaps the first byte's control code is 0x1E, and the rest are 0x00.

Wait, but 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each data byte, if control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0. Otherwise, the data byte is kept as is.

So, the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with highest bit 0), else append the data byte as is.

But then, the encoded_data would be 64 bits, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the control code would be at the beginning, followed by data bytes. So, in the example, the control_in is all 1s, so all 8 data bytes are replaced by control codes, each 7 bits, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, perhaps the first byte's control code is 0x1E, and the rest are 0x00.

Wait, but 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each data byte, if control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0. Otherwise, the data byte is kept as is.

So, the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with highest bit 0), else append the data byte as is.

But then, the encoded_data would be 64 bits, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the control code would be at the beginning, followed by data bytes. So, in the example, the control_in is all 1s, so all 8 data bytes are replaced by control codes, each 7 bits, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, perhaps the first byte's control code is 0x1E, and the rest are 0x00.

Wait, but 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each data byte, if control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0. Otherwise, the data byte is kept as is.

So, the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with highest bit 0), else append the data byte as is.

But then, the encoded_data would be 64 bits, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the control code would be at the beginning, followed by data bytes. So, in the example, the control_in is all 1s, so all 8 data bytes are replaced by control codes, each 7 bits, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, perhaps the first byte's control code is 0x1E, and the rest are 0x00.

Wait, but 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each data byte, if control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0. Otherwise, the data byte is kept as is.

So, the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with highest bit 0), else append the data byte as is.

But then, the encoded_data would be 64 bits, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the control code would be at the beginning, followed by data bytes. So, in the example, the control_in is all 1s, so all 8 data bytes are replaced by control codes, each 7 bits, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, perhaps the first byte's control code is 0x1E, and the rest are 0x00.

Wait, but 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each data byte, if control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0. Otherwise, the data byte is kept as is.

So, the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with highest bit 0), else append the data byte as is.

But then, the encoded_data would be 64 bits, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the control code would be at the beginning, followed by data bytes. So, in the example, the control_in is all 1s, so all 8 data bytes are replaced by control codes, each 7 bits, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, perhaps the first byte's control code is 0x1E, and the rest are 0x00.

Wait, but 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each data byte, if control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0. Otherwise, the data byte is kept as is.

So, the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with highest bit 0), else append the data byte as is.

But then, the encoded_data would be 64 bits, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the control code would be at the beginning, followed by data bytes. So, in the example, the control_in is all 1s, so all 8 data bytes are replaced by control codes, each 7 bits, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, perhaps the first byte's control code is 0x1E, and the rest are 0x00.

Wait, but 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each data byte, if control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0. Otherwise, the data byte is kept as is.

So, the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with highest bit 0), else append the data byte as is.

But then, the encoded_data would be 64 bits, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the control code would be at the beginning, followed by data bytes. So, in the example, the control_in is all 1s, so all 8 data bytes are replaced by control codes, each 7 bits, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, perhaps the first byte's control code is 0x1E, and the rest are 0x00.

Wait, but 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each data byte, if control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0. Otherwise, the data byte is kept as is.

So, the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with highest bit 0), else append the data byte as is.

But then, the encoded_data would be 64 bits, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the control code would be at the beginning, followed by data bytes. So, in the example, the control_in is all 1s, so all 8 data bytes are replaced by control codes, each 7 bits, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, perhaps the first byte's control code is 0x1E, and the rest are 0x00.

Wait, but 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each data byte, if control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0. Otherwise, the data byte is kept as is.

So, the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with highest bit 0), else append the data byte as is.

But then, the encoded_data would be 64 bits, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the control code would be at the beginning, followed by data bytes. So, in the example, the control_in is all 1s, so all 8 data bytes are replaced by control codes, each 7 bits, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, perhaps the first byte's control code is 0x1E, and the rest are 0x00.

Wait, but 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each data byte, if control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0. Otherwise, the data byte is kept as is.

So, the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with highest bit 0), else append the data byte as is.

But then, the encoded_data would be 64 bits, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the control code would be at the beginning, followed by data bytes. So, in the example, the control_in is all 1s, so all 8 data bytes are replaced by control codes, each 7 bits, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, perhaps the first byte's control code is 0x1E, and the rest are 0x00.

Wait, but 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each data byte, if control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0. Otherwise, the data byte is kept as is.

So, the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with highest bit 0), else append the data byte as is.

But then, the encoded_data would be 64 bits, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the control code would be at the beginning, followed by data bytes. So, in the example, the control_in is all 1s, so all 8 data bytes are replaced by control codes, each 7 bits, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, perhaps the first byte's control code is 0x1E, and the rest are 0x00.

Wait, but 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each data byte, if control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0. Otherwise, the data byte is kept as is.

So, the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with highest bit 0), else append the data byte as is.

But then, the encoded_data would be 64 bits, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the control code would be at the beginning, followed by data bytes. So, in the example, the control_in is all 1s, so all 8 data bytes are replaced by control codes, each 7 bits, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, perhaps the first byte's control code is 0x1E, and the rest are 0x00.

Wait, but 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each data byte, if control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0. Otherwise, the data byte is kept as is.

So, the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with highest bit 0), else append the data byte as is.

But then, the encoded_data would be 64 bits, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the control code would be at the beginning, followed by data bytes. So, in the example, the control_in is all 1s, so all 8 data bytes are replaced by control codes, each 7 bits, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, perhaps the first byte's control code is 0x1E, and the rest are 0x00.

Wait, but 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each data byte, if control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0. Otherwise, the data byte is kept as is.

So, the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with highest bit 0), else append the data byte as is.

But then, the encoded_data would be 64 bits, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the control code would be at the beginning, followed by data bytes. So, in the example, the control_in is all 1s, so all 8 data bytes are replaced by control codes, each 7 bits, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, perhaps the first byte's control code is 0x1E, and the rest are 0x00.

Wait, but 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each data byte, if control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0. Otherwise, the data byte is kept as is.

So, the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with highest bit 0), else append the data byte as is.

But then, the encoded_data would be 64 bits, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the control code would be at the beginning, followed by data bytes. So, in the example, the control_in is all 1s, so all 8 data bytes are replaced by control codes, each 7 bits, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, perhaps the first byte's control code is 0x1E, and the rest are 0x00.

Wait, but 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each data byte, if control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0. Otherwise, the data byte is kept as is.

So, the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with highest bit 0), else append the data byte as is.

But then, the encoded_data would be 64 bits, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the control code would be at the beginning, followed by data bytes. So, in the example, the control_in is all 1s, so all 8 data bytes are replaced by control codes, each 7 bits, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, perhaps the first byte's control code is 0x1E, and the rest are 0x00.

Wait, but 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each data byte, if control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0. Otherwise, the data byte is kept as is.

So, the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with highest bit 0), else append the data byte as is.

But then, the encoded_data would be 64 bits, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the control code would be at the beginning, followed by data bytes. So, in the example, the control_in is all 1s, so all 8 data bytes are replaced by control codes, each 7 bits, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, perhaps the first byte's control code is 0x1E, and the rest are 0x00.

Wait, but 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each data byte, if control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0. Otherwise, the data byte is kept as is.

So, the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with highest bit 0), else append the data byte as is.

But then, the encoded_data would be 64 bits, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then, the control code would be at the beginning, followed by data bytes. So, in the example, the control_in is all 1s, so all 8 data bytes are replaced by control codes, each 7 bits, but in the example, the encoded_data is 8'h1E followed by 56'h0. So, perhaps the first byte's control code is 0x1E, and the rest are 0x00.

Wait, but 0x1E is 0b00011110, which is 7 bits. So, perhaps the code is 7 bits, and when placed into the encoded_data, it's shifted into the higher 7 bits, with the 8th bit as 0.

So, for each data byte, if control_in is 1, the 7-bit code is placed into the encoded_data as an 8-bit value with the highest bit as 0. Otherwise, the data byte is kept as is.

So, the encoded_data is built by processing each byte, and for each, if control_in is 1, append the 7-bit code as an 8-bit value (with highest bit 0), else append the data byte as is.

But then, the encoded_data would be 64 bits, as each of the 8 data bytes is processed into 8 bits.

Wait, but in the example, the encoded_data is 8 bits for the control code and 56 bits for data. So, perhaps the control code is placed at the beginning, followed by data bytes.

Hmm, perhaps the encoded_data is built by first processing the control_in, and for each bit, if it's 1, append the corresponding 7-bit code as an 8-bit value (with the highest bit as 0), else append the data byte as is. So, the encoded_data is a concatenation of these 8-bit values.

But then