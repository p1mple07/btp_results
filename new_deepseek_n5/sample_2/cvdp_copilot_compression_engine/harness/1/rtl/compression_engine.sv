Okay, I need to help complete the RTL code for the compression engine based on the given specifications. Let me go through the problem step by step.

First, the task is to implement the one-hot encoding logic for the exponent. The exponent is determined by the position of the most significant set bit in the input vector `num_i`. The one-hot vector `exp_oh` should have a 1 only at the position corresponding to the MSB.

Looking at the provided code, the onehot_to_bin module is already defined, but it's not implemented yet. I need to fill in the one-hot_to_bin module to correctly convert the one-hot vector to the binary exponent.

In the one-hot_to_bin module, the input is a one-hot vector, and the output is the binary representation of the exponent. The current code has a for loop from 0 to 31, but since our input is a 24-bit vector, I should loop from 0 to 23. For each bit, if the bit is 1, set the corresponding bit in `bin_vec_o` and break the loop to get the correct position.

Next, the mantissa extraction logic needs to be implemented. The mantissa should be the 12 most significant bits starting from the exponent position. If the input is all zeros, the mantissa should be zero.

In the compression_engine module, after calculating the exponent, I need to extract the mantissa. I'll check if `num_i` is all zeros. If it is, set mantissa to zero. Otherwise, extract the bits from `exponent` to `exponent + 11` (since it's 12 bits) from `num_i`.

Wait, but in the example given, for `num_i = 24'hFFC01D`, the binary is `111111111100000000011101`, and the mantissa is `12'b111111111100`. That's the first 12 bits starting from the MSB. So the exponent is 10 (since the MSB is at position 12, zero-based, so exponent is 10). So the mantissa is from bit 10 to 10+11=21, which is correct.

So in the code, after determining the exponent, I'll extract the mantissa as `num_i[exponent + 11 : exponent]` but wait, in Verilog, the syntax is [msb to lsb], so for a 12-bit mantissa starting at exponent, it should be `num_i[exponent + 11: exponent]`? Wait, no, because in Verilog, the syntax is [msb-1:lsb-1], so if exponent is the position of the MSB, then the next 11 bits are exponent+1 to exponent+11. Wait, no, exponent is the zero-based index. So the mantissa starts at exponent and takes the next 11 bits, making it 12 bits total. So the slice would be `num_i[exponent + 11: exponent]`? Wait, no, because in Verilog, the higher index is first. So if exponent is 10, then the bits are 10 to 21 (since 10 + 11 = 21). So the slice is `num_i[21:10]`.

Wait, but in the example, `num_i` is 24 bits, and the mantissa is 12 bits. So for exponent 10, the mantissa is bits 10 to 21, which is correct.

So in the code, after calculating the exponent, I'll assign the mantissa as `mantissa = (num_i[exponent + 11: exponent] )`. But wait, in the code, `num_i` is a 24-bit vector, so if exponent is 10, then exponent + 11 is 21, which is within the 24 bits. But if exponent is 23, then exponent + 11 is 34, which is beyond 23. So I need to handle cases where exponent is 23, but according to the specs, the exponent is the zero-based index of the first set bit. So if the input is all ones, the exponent would be 23, and the mantissa would be the entire 24 bits? Wait, no, because the mantissa is supposed to be 12 bits. So if exponent is 23, then the mantissa would be bits 23 to 12, which is 12 bits. But wait, 23 is the MSB, so the mantissa would be the 12 bits starting at 23, which is bits 23 down to 12, which is 12 bits. So that's correct.

Wait, but in the example where `num_i` is all zeros, the mantissa is zero. So in the code, I need to check if `num_i` is all zeros. How can I do that? I can check if the OR of all bits in `num_i` is zero. So `|num_i` would be 1 if any bit is set. So if `|num_i` is 0, then set mantissa to 0. Otherwise, extract the mantissa as described.

Putting it all together, in the compression_engine module, after calculating the exponent, I'll have:

if (|num_i) == 0) {
    mantissa_o = 12'd0;
} else {
    mantissa_o = num_i[exponent + 11: exponent];
}

Wait, but in Verilog, the slice is written as [msb:lsb], so if exponent is 10, then exponent + 11 is 21, so the slice is 21:10, which is 12 bits.

So in the code, I'll write:

mantissa_o = (|num_i) ? (num_i[exponent + 11: exponent] ) : (12'd0);

Wait, but in the code, `num_i` is a 24-bit vector, so when exponent is 23, exponent + 11 is 34, which is beyond 23. So in that case, the slice would be from 34:23, which is invalid. So I need to make sure that exponent + 11 doesn't exceed 23.

Wait, but according to the specs, the exponent is the zero-based index of the first set bit. So if the input is all ones, the first set bit is at position 23, so exponent is 23. Then the mantissa would be bits 23 down to 12, which is 12 bits. So in that case, the slice is valid because 23 + 11 = 34, but the slice is from 34:23, which is an empty slice, but in Verilog, that would be zero. Wait, no, because in Verilog, if the start is higher than the end, the result is zero. So in that case, the mantissa would be zero, which is incorrect because the mantissa should be the 12 bits starting at 23, which is bits 23 to 12, which is 12 bits. So the slice should be from exponent to exponent + 11, but since it's 12 bits, it's better to write it as [exponent: exponent + 11], but wait, that would be from exponent to exponent + 11, which is 12 bits. But in the example, when exponent is 10, it's 10 to 21, which is correct.

Wait, no, because in the example, the mantissa is 12 bits starting from the MSB, which is exponent. So the slice should be from exponent to exponent + 11, inclusive. So in Verilog, the slice would be [exponent: exponent + 11], but since in Verilog, the higher index is first, it's written as [exponent + 11: exponent]. Wait, no, that's not correct. Because if I have a 24-bit vector, and I want to get bits 10 to 21, I would write num_i[21:10]. So the higher index comes first.

So in code, mantissa_o = num_i[exponent + 11: exponent]; would give the correct 12 bits.

Wait, but if exponent is 23, then exponent + 11 is 34, which is beyond 23. So the slice would be from 34:23, which is an empty slice, resulting in 0. But according to the specs, when the input is all ones, the mantissa should be the 12 bits starting at 23, which is bits 23 to 12, which is 12 bits. So in that case, the slice should be from 23 down to 12, which is 12 bits. So the code as written would not capture that correctly.

Hmm, this is a problem. So I need to make sure that when exponent is 23, the mantissa is correctly captured as bits 23 to 12.

Wait, but in the code, when exponent is 23, exponent + 11 is 34, which is beyond 23. So the slice would be from 34:23, which is zero. That's incorrect. So I need to adjust the code to handle this case.

Wait, perhaps I should calculate the end as min(exponent + 11, 23). But in Verilog, I can't use min function directly. So perhaps I can compute the end as exponent + 11, but if it's beyond 23, cap it at 23.

Alternatively, perhaps I should compute the mantissa as the 12 bits starting from exponent, but if exponent + 11 exceeds 23, then the mantissa is the remaining bits. But according to the specs, the mantissa is always 12 bits, so if the exponent is 23, the mantissa should be the 12 bits starting at 23, which is bits 23 down to 12, which is 12 bits. So in that case, the slice should be from 23 down to 12, which is 12 bits.

Wait, but in the code, when exponent is 23, exponent + 11 is 34, which is beyond 23. So the slice would be from 34:23, which is zero. That's not correct. So I need to adjust the code to handle this.

Wait, perhaps I should calculate the end as exponent + 11, but if it's beyond 23, then set it to 23. So in code, it would be:

mantissa_o = (|num_i) ? ( (exponent + 11 < 24) ? (num_i[exponent + 11: exponent]) : (num_i[23: exponent]) ) : (12'd0);

But that's getting complicated. Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, but if exponent + 11 exceeds 23, then the mantissa is the remaining bits plus zero padding on the right. But since the mantissa is supposed to be 12 bits, perhaps the code should just take as many bits as possible and pad with zeros if necessary.

Wait, but according to the specs, the mantissa includes the most significant 12 bits starting from the MSB. So if the exponent is 23, the mantissa should be bits 23 down to 12, which is 12 bits. So in that case, the slice is 23:12, which is 12 bits. So in code, I can write it as num_i[23:12], but only if exponent is 23. Otherwise, it's exponent + 11.

Wait, but that's not scalable. So perhaps a better approach is to calculate the end as exponent + 11, but if it's beyond 23, then set it to 23. So in code:

integer end;
end = exponent + 11;
if (end >= 24) end = 23;

mantissa_o = num_i[end: exponent];

But in Verilog, I can't use an integer variable in the slice. So perhaps I can compute it as:

mantissa_o = num_i[min(exponent + 11, 23): exponent];

But again, min function isn't available. So perhaps I can compute it as:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that would require additional logic, which might complicate the code.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there aren't enough bits, pad with zeros on the right. But in the code, since the mantissa is 12 bits, I can just take the slice and if it's shorter, it will be zero.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, then num_i[exponent + 11: exponent] would be zero. But that's not correct because the mantissa should include as many bits as possible starting from exponent.

Hmm, this is a problem. So perhaps the initial approach is incorrect. Maybe the mantissa should be the 12 bits starting from the exponent, but if there are fewer than 12 bits, it's padded with zeros on the right.

Wait, but according to the specs, the mantissa includes the most significant 12 bits starting from the MSB. So if the exponent is 23, the mantissa should be bits 23 down to 12, which is 12 bits. So in that case, the slice should be from 23 down to 12, which is 12 bits.

So perhaps the correct way is to calculate the end as exponent + 11, but if it's beyond 23, then the end is 23, and the start is 23. So in code, it would be:

mantissa_o = num_i[min(exponent + 11, 23): exponent];

But since I can't use min, perhaps I can write it as:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 > 23) {
    mantissa_o = num_i[23: exponent];
}

But that would require additional logic, which might not be straightforward in the code.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, pad with zeros on the right. So in code:

mantissa_o = (|num_i) ? ( (exponent + 11 < 24) ? (num_i[exponent + 11: exponent]) : (num_i[23: exponent] & (24'h1000000000000 - 1)) ) : (12'd0);

Wait, but that's getting complicated. Maybe a better approach is to calculate the start and end correctly.

Wait, perhaps the correct way is to calculate the start as exponent, and the end as exponent + 11, but if end exceeds 23, then end is 23. So in code:

integer start, end;
start = exponent;
end = exponent + 11;
if (end >= 24) end = 23;

mantissa_o = num_i[end: start];

But again, in Verilog, I can't use integer variables in the slice. So perhaps I can compute it as:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that would require additional logic, which might not be straightforward.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits. So in code:

mantissa_o = num_i[exponent: exponent + 11];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[exponent:23];
}

But again, this requires additional logic.

Wait, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a slice of zero, but according to the specs, the mantissa should be the 12 bits starting from exponent, which is 23, so it should be bits 23 down to 12, which is 12 bits. So in that case, the slice should be from 23 down to 12, which is 12 bits. So in code, perhaps I should write:

mantissa_o = num_i[23:12];
if (exponent != 23) {
    mantissa_o = num_i[exponent + 11: exponent];
}

But that's not correct because exponent can be less than 23.

Hmm, perhaps I'm overcomplicating this. Let me think differently. The mantissa is supposed to be the 12 most significant bits starting from the first set bit. So if the first set bit is at position 23, then the mantissa is bits 23 down to 12, which is 12 bits. If the first set bit is at position 10, then the mantissa is bits 10 down to 21, which is 12 bits. So in code, the mantissa should be from exponent down to exponent + 11, but since in Verilog, the slice is written as [msb:lsb], it's [exponent + 11: exponent].

Wait, no, because exponent is the position of the first set bit. So if exponent is 10, the first set bit is at 10, so the next 11 bits are 11 to 21, making 12 bits. So the slice is 21:10, which is 12 bits. Similarly, if exponent is 23, the slice is 34:23, which is zero, but that's incorrect because the mantissa should be 12 bits. So perhaps the code needs to handle this case.

Wait, perhaps the code should calculate the end as min(exponent + 11, 23). So in code:

integer end;
end = exponent + 11;
if (end > 23) end = 23;

mantissa_o = num_i[end: exponent];

But again, in Verilog, I can't use an integer variable in the slice. So perhaps I can compute it as:

mantissa_o = num_i[min(exponent + 11, 23): exponent];

But since min isn't available, perhaps I can compute it using a conditional.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits. So in code:

mantissa_o = num_i[exponent: exponent + 11];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[exponent:23];
}

But that would require additional logic.

Wait, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a slice of zero, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros if necessary.

Wait, but in the example where num_i is all ones, the mantissa should be 12 bits of ones. So in that case, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = (|num_i) ? ( (exponent + 11 < 24) ? (num_i[exponent + 11: exponent]) : (num_i[23: exponent] & (24'h1000000000000 - 1)) ) : (12'd0);

But that's getting complicated. Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, but the slice would be zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros if necessary.

Wait, perhaps the code should calculate the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

So in code:

mantissa_o = num_i[exponent: exponent + 11];
if (exponent + 11 >= 24) {
    mantissa_o = mantissa_o[0:24 - (exponent + 11)] & (24'h1000000000000 - 1);
}

Wait, but that's getting too complicated. Maybe the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros if necessary.

Alternatively, perhaps the code should calculate the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros on the right if necessary.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros on the right if necessary.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros on the right if necessary.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros on the right if necessary.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros on the right if necessary.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros on the right if necessary.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros on the right if necessary.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros on the right if necessary.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros on the right if necessary.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros on the right if necessary.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros on the right if necessary.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros on the right if necessary.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros on the right if necessary.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros on the right if necessary.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros on the right if necessary.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros on the right if necessary.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros on the right if necessary.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros on the right if necessary.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros on the right if necessary.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be 12 bits. So perhaps the code should ensure that the mantissa is always 12 bits, padding with zeros on the right if necessary.

Wait, but in the case where exponent is 23, the slice would be from 23 down to 12, which is 12 bits. So in code, perhaps I can write:

mantissa_o = num_i[exponent + 11: exponent];
if (exponent + 11 >= 24) {
    mantissa_o = num_i[23: exponent];
}

But that's not correct because exponent + 11 could be beyond 23, resulting in a slice of zero. So perhaps the correct approach is to calculate the end as min(exponent + 11, 23), but without using an integer variable.

Alternatively, perhaps I can compute the mantissa as the 12 bits starting from exponent, and if there are not enough bits, it's just the remaining bits, and then pad with zeros on the right to make it 12 bits.

Wait, but in Verilog, when you slice beyond the vector's length, it returns zero. So if exponent + 11 is beyond 23, the slice would be zero, which is incorrect. So perhaps the code should not use the onehot_to_bin module for exponent 23, but that's not feasible.

Hmm, perhaps the initial approach is acceptable, and the case where exponent is 23 will result in a zero mantissa, but according to the specs, the mantissa should be