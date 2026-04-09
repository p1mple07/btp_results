module named signed_unsigned_comparator. It has parameters WIDTH default 5. Inputs i_A, i_B, i_enable, i_mode. Outputs o_greater, o_less, o_equal.

The design is purely combinational. We must implement two modes: signed and magnitude. For signed mode, we treat inputs as signed integers. In magnitude mode, treat as unsigned.

We need to handle the enable: if i_enable low, outputs low.

Also, we need to consider the comparisons: for signed mode, use signed comparison. For magnitude mode, treat as unsigned, but then how to compare? Since it's magnitude mode, we might just use unsigned comparison. But the requirement: "When i_mode is low, the comparison ignores the sign bit and treats both inputs as unsigned magnitudes." So we need to convert signed to unsigned for magnitude mode? But we must ensure that for signed mode, we use signed arithmetic.

We need to produce outputs based on the comparison:

- o_greater: i_A > i_B
- o_less: i_A < i_B
- o_equal: i_A == i_B

We need to implement this using combinational logic, but with enable.

We should note that the enable condition: i_enable must be high to perform the comparison.

Let's design the module.

Approach:

- We'll use a always block sensitive to i_enable.

- Inside, if i_enable == 0, output all low.

- Else, we need to compute the comparison.

We need to decide which mode. We can use a parameter or variable. We can have a local variable mode = i_mode; but we need to check i_mode is high or low.

We'll implement:

If i_mode == high: use signed comparison.

Else: magnitude mode.

In signed mode, we can do:

always @(*) begin
    if (i_enable) begin
        // compute signed comparison
    end
end

But we need to avoid sequential inside combinatorial. But we can use always block.

Better to use if statements inside always block.

We need to handle the comparisons with signed or unsigned.

For signed mode:

We can use the standard signed comparison:

(i_A > i_B) ? o_greater : (i_A < i_B ? o_less : o_equal);

But we need to ensure that the comparison is done on signed values.

In magnitude mode, we can treat as unsigned:

o_greater: i_A > i_B (unsigned comparison). But the inputs may be signed but we are treating as unsigned. So we can cast to unsigned? Actually, in SystemVerilog, we can use bitwise operations. But we can simply do:

In magnitude mode, we can cast to unsigned and compare.

But to keep it simple, we can implement the comparisons using bitwise operations, but we need to handle the mode.

Let's design:

Within the always block:

if (i_enable) begin
    // Signed mode
    if (i_mode == HIGH) begin
        // Signed comparison
        o_greater = (i_A > i_B);
        o_less = (i_A < i_B);
        o_equal = (i_A == i_B);
    end else begin
        // Magnitude mode
        o_greater = (i_A >> 1) != (i_B >> 1); // This is a trick: comparing bits after shifting right by 1.
        o_less = (~(i_A >> 1) & (i_B >> 1));
        o_equal = (i_A == i_B);
    end
end else begin
    o_greater = 0;
    o_less = 0;
    o_equal = 0;
end

But we need to be careful: For magnitude mode, the comparison should be unsigned, but we can use the same approach. However, we might want to use the same logic but with unsigned.

Alternatively, we can use a simpler method: For magnitude mode, we can use the same as unsigned comparison.

But the requirement: "When i_mode is low, the comparison ignores the sign bit and treats both inputs as unsigned magnitudes." So we can convert i_A and i_B to unsigned, then compare.

But we can also use the signed comparison but with the mode.

Let's design the module with a single always block that checks enable, then inside uses a conditional to choose between signed and magnitude mode.

We can do:

module signed_unsigned_comparator #(parameter WIDTH = 5) (
    input  logic i_A,
    input  logic i_B,
    input  logic i_enable,
    input  logic i_mode,
    output logic o_greater,
    output logic o_less,
    output logic o_equal
);

    logic [WIDTH-1:0] a, b;

    assign a = i_A;
    assign b = i_B;

    if (i_enable) begin
        if (i_mode == HIGH) begin
            // Signed mode
            o_greater = (a > b);
            o_less = (a < b);
            o_equal = (a == b);
        end else begin
            // Magnitude mode
            o_greater = (a[WIDTH-1] > b[WIDTH-1]);
            o_less = (~(a[WIDTH-1] >> 1) & (b[WIDTH-1] >> 1));
            o_equal = (a == b);
        end
    end else begin
        o_greater = 1'b0;
        o_less = 1'b0;
        o_equal = 1'b0;
    end

endmodule

Wait, but the magnitude mode comparison: we can use the same approach as signed but with unsigned values? Actually, in magnitude mode, we want to treat as unsigned. But the above uses the same signed comparisons but with the shift and AND trick. Let's test: For magnitude mode, we want to compare the unsigned values. We can do:

In magnitude mode:

o_greater = (a[WIDTH-1] > b[WIDTH-1]);
o_less = (~(a[WIDTH-1] >> 1) & (b[WIDTH-1] >> 1));
o_equal = (a == b);

This is the typical way to compare unsigned numbers after shifting right by 1.

But in the code above, I used:

o_greater = (a[WIDTH-1] > b[WIDTH-1]);
o_less = (~(a[WIDTH-1] >> 1) & (b[WIDTH-1] >> 1));
o_equal = (a == b);

This is correct for unsigned comparison.

But we need to ensure the bit width is WIDTH. So the shift is by WIDTH/2? For WIDTH=5, we shift by 2 bits. That matches the common implementation of comparing magnitude mode: compare the higher bits after shifting.

Thus, the code seems okay.

We need to ensure that the module is combinational and no sequential elements.

We also need to provide the file name rtl/signed_comparator.sv.

We need to provide the answer as plain text, no JSON.

We should write the code in SystemVerilog, with proper syntax.

Let's craft the code:

We'll define the module with the given name.

Parameters: WIDTH with default 5. So we can use param or default.

In SystemVerilog, we can declare parameters as:

parameter WIDTH = 5;

Then in the module instantiation, we can use the parameter.

But the module itself should be able to be instantiated with or without specifying WIDTH.

We can set default in the module.

So:

module signed_unsigned_comparator #(
    parameter WIDTH = 5
) (
    input  logic i_A,
    input  logic i_B,
    input  logic i_enable,
    input  logic i_mode,
    output logic o_greater,
    output logic o_less,
    output logic o_equal
);

    logic [WIDTH-1:0] a, b;

    assign a = i_A;
    assign b = i_B;

    if (i_enable) begin
        if (i_mode == 1) begin
            // Signed mode
            o_greater = (a > b);
            o_less = (a < b);
            o_equal = (a == b);
        end else begin
            // Magnitude mode
            o_greater = (a[WIDTH-1] > b[WIDTH-1]);
            o_less = (~(a[WIDTH-1] >> 1) & (b[WIDTH-1] >> 1));
            o_equal = (a == b);
        end
    end else begin
        o_greater = 1'b0;
        o_less = 1'b0;
        o_equal = 1'b0;
    end

endmodule

We need to ensure that the module is synthesizable and uses standard terminology.

Also, we need to include comments? Not necessary.

We should output the code as plain text.

We need to ensure that the output is saved to rtl/signed_comparator.sv.

Thus, the final answer should be the code block.

But the user says: "Please provide your response as plain text without any JSON formatting. Your response will be saved directly to: rtl/signed_comparator.sv."

So we need to output the code inside the rtl/signed_comparator.sv file.

We can just output the code as text.

Let's produce the code:

module signed_unsigned_comparator #(parameter WIDTH = 5) (
    input  logic i_A,
    input  logic i_B,
    input  logic i_enable,
    input  logic i_mode,
    output logic o_greater,
    output logic o_less,
    output logic o_equal
);

    logic [WIDTH-1:0] a, b;

    assign a = i_A;
    assign b = i_B;

    if (i_enable) begin
        if (i_mode == 1) begin
            o_greater = (a > b);
            o_less = (a < b);
            o_equal = (a == b);
        end else begin
            o_greater = (a[WIDTH-1] > b[WIDTH-1]);
            o_less = (~(a[WIDTH-1] >> 1) & (b[WIDTH-1] >> 1));
            o_equal = (a == b);
        end
    end else begin
        o_greater = 1'b0;
        o_less = 1'b0;
        o_equal = 1'b0;
    end

endmodule

We need to ensure that the code is syntactically correct. In SystemVerilog, we don't need semicolons after assignments? Actually, we do. We need to put each assignment on its own line.

Let's rewrite with proper indentation and line breaks.

We'll produce:

module signed_unsigned_comparator #(parameter WIDTH = 5) (
    input  logic i_A,
    input  logic i_B,
    input  logic i_enable,
    input  logic i_mode,
    output logic o_greater,
    output logic o_less,
    output logic o_equal
);

    logic [WIDTH-1:0] a, b;

    assign a = i_A;
    assign b = i_B;

    if (i_enable) begin
        if (i_mode == 1) begin
            o_greater = (a > b);
            o_less = (a < b);
            o_equal = (a == b);
        end else begin
            o_greater = (a[WIDTH-1] > b[WIDTH-1]);
            o_less = (~(a[WIDTH-1] >> 1) & (b[WIDTH-1] >> 1));
            o_equal = (a == b);
        end
    end else begin
        o_greater = 1'b0;
        o_less = 1'b0;
        o_equal = 1'b0;
    end

endmodule

Yes.

Now we need to ensure that the output file is named exactly rtl/signed_comparator.sv.

We'll just output that code.

We should not include any other text.

Thus, the final answer.


module signed_unsigned_comparator #(parameter WIDTH = 5) (
    input  logic i_A,
    input  logic i_B,
    input  logic i_enable,
    input  logic i_mode,
    output logic o_greater,
    output logic o_less,
    output logic o_equal
);

    logic [WIDTH-1:0] a, b;

    assign a = i_A;
    assign b = i_B;

    if (i_enable) begin
        if (i_mode == 1) begin
            o_greater = (a > b);
            o_less = (a < b);
            o_equal = (a == b);
        end else begin
            o_greater = (a[WIDTH-1] > b[WIDTH-1]);
            o_less = (~(a[WIDTH-1] >> 1) & (b[WIDTH-1] >> 1));
            o_equal = (a == b);
        end
    end else begin
        o_greater = 1'b0;
        o_less = 1'b0;
        o_equal = 1'b0;
    end

endmodule