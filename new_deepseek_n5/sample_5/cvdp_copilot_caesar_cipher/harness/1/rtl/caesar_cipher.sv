module called caesar_cipher that implements a Caesar cipher for character encryption. The module should take an 8-bit ASCII character as input and produce a new character based on a 4-bit key. It should handle both uppercase and lowercase letters, leaving non-alphabetic characters unchanged.

First, I'll start by understanding the inputs and outputs. The input is an 8-bit character, input_char, and a 4-bit key. The output is the shifted character, output_char. 

I need to check if the input_char is an uppercase or lowercase letter. For uppercase, it should be between 'A' and 'Z', and for lowercase, between 'a' and 'z'. If it's neither, the output remains the same.

For uppercase letters, I'll calculate the new character by shifting it by the key value. Similarly, for lowercase. The shift should wrap around using modulo 26 to ensure it stays within the alphabet range.

Let me think about how to compute the shifted value. For a lowercase letter, I can subtract 'a' to get a value between 0 and 25, add the key, take modulo 26, then add 'a' back. The same logic applies to uppercase but with 'A' instead of 'a'.

I'll need to use bitwise operations to extract the key and manipulate the input_char. Since the key is 4 bits, it can range from 0 to 15. The input_char is an 8-bit value, so I can use bitwise shifts or masks to handle it.

Wait, but in System Verilog, I can directly use the input values. So, for example, to get the key, I can assign key = [3:0] input_char. But actually, the key is provided as an input, so I don't need to compute it from input_char. So I can just use the key as is.

Next, I'll write the logic. If input_char is between 'A' and 'Z', I'll shift it. Else if it's between 'a' and 'z', I'll shift it. Else, leave it as is.

Let me structure this with if-else statements. For the uppercase case, compute the shifted value as ((input_char - 'A' + key) % 26) + 'A'. Similarly for lowercase.

But wait, in Verilog, I can't directly use subtraction like that. I need to use ADD and SUB operations. So, I'll have to compute the new value using ADD and SUB.

Alternatively, I can use bitwise operations. For example, for lowercase, new_char = (input_char - 'a' + key) % 26 + 'a'. But in Verilog, I can't use the modulo operator directly. So I'll have to implement it using a loop or a conditional.

Wait, but in combinational logic, loops aren't allowed. So I need another approach. Maybe I can compute the shifted value and then use a conditional to wrap around if it exceeds 25.

Alternatively, I can compute the shifted value and then subtract 26 if it's greater than 25, or add 26 if it's negative. But since the key is positive (0-15), adding it to the input_char (which is within 0-25 for lowercase) will never make it negative. So for lowercase, the shifted value will be between 0 and 25 + 15 = 40. So modulo 26 would be (input_char - 'a' + key) % 26.

But how to implement modulo in Verilog? I can't use the % operator. So I'll have to compute it manually. One way is to subtract 26 multiplied by the quotient of (input_char - 'a' + key) divided by 26.

Wait, but in combinational logic, I can't have loops or assignments that depend on previous values. So I need to compute the modulo using bitwise operations or arithmetic operations.

Alternatively, I can compute the shifted value and then check if it's beyond 25. If it is, subtract 26. But since the key is 4 bits (0-15), the maximum shift is 15. So for lowercase, the maximum shifted value is 25 + 15 = 40. So 40 - 26 = 14, which is within 0-25. So for any value beyond 25, subtract 26.

But how to implement this in Verilog? I can compute the shifted value, then subtract 26 if it's greater than 25. But in Verilog, I can't use if statements in a combinational assignment. So I need another approach.

Wait, perhaps I can compute the modulo using a mathematical expression. For example, (a + b) % 26 can be written as (a + b - 26 * ((a + b) >> 4)).

Wait, because 26 is 16 + 8 + 2, which is 11010 in binary. So shifting right by 4 bits gives the number of times 26 fits into the sum. Multiplying back by 26 gives the total to subtract.

So, for example, (input_char - 'a' + key) can be computed, then subtract 26 multiplied by the quotient when divided by 26.

So, in Verilog, I can write:

new_lower = (input_char - 'a' + key) - 26 * ((input_char - 'a' + key) >> 4);

Similarly for uppercase.

But wait, in Verilog, the shift operator for integers is >>, but for signed numbers, it's arithmetic shift. However, in this case, since we're dealing with positive numbers (input_char is 0-25, key 0-15, so sum is 0-40), the shift will be correct.

So, putting it all together, the module will have:

if (input_char >= 'A' && input_char <= 'Z') {
    output_char = (input_char - 'A' + key) % 26 + 'A';
} else if (input_char >= 'a' && input_char <= 'z') {
    output_char = (input_char - 'a' + key) % 26 + 'a';
} else {
    output_char = input_char;
}

But since I can't use if statements in a combinational assignment, I need to find another way.

Wait, but in System Verilog, I can use a case statement or a series of assignments using if conditions in a combinational block.

Alternatively, I can compute the shifted value for each case and then select the appropriate one based on the input.

So, perhaps:

output_char = 0;

if (input_char >= 'A' && input_char <= 'Z') {
    output_char = (input_char - 'A' + key) % 26 + 'A';
} else if (input_char >= 'a' && input_char <= 'z') {
    output_char = (input_char - 'a' + key) % 26 + 'a';
} else {
    output_char = input_char;
}

But again, in a combinational block, I can't have if statements. So I need to find a way to compute the correct output without using conditionals.

Alternatively, I can compute all possible cases and then select the correct one using multiplexers or a case statement.

Wait, but in System Verilog, I can use a case statement in a combinational block.

So, perhaps:

always_comb:
    case(input_char)
    when 'A' to 'Z'
        output_char = (input_char - 'A' + key) % 26 + 'A';
    when 'a' to 'z'
        output_char = (input_char - 'a' + key) % 26 + 'a';
    default
        output_char = input_char;
    endcase

But wait, in System Verilog, the case statement can be used in a combinational block.

So, putting it all together, the module would be:

module caesar_cipher (
    input input_char,
    input key,
    output output_char
);

    always_comb caesar_cipher #(
        .input(input_char),
        .key(key),
        .output(output_char)
    ) {
        case(input_char)
            when 'A' to 'Z'
                output_char = (input_char - 'A' + key) % 26 + 'A';
            when 'a' to 'z'
                output_char = (input_char - 'a' + key) % 26 + 'a';
            default
                output_char = input_char;
            endcase
    }

endmodule