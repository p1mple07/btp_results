We need to modify the Verilog code to add new features: arithmetic shift, bitwise logical operations, bit reversal, bitwise inversion, parity check, zero detection, overflow indication.

We need to keep original functionality. The code is in rtl/universal_shift_register.sv. We need to add new modules or functions.

The instructions: "Modify the universal_shift_register module to expand its functionality by incorporating additional shift and bitwise operation capabilities while retaining its original functionality (including hold, shift, rotate, and parallel load operations)."

So we need to add new cases to the always block. Also add new inputs maybe? But the question says "only respond with the modified RTL code", so we just provide the code with modifications.

We must ensure the design matches the added capabilities.

Let's think:

Original operations:

- mode 00: hold
- 01: logical shift (shift_dir)
- 10: rotate
- 11: parallel load

We need to add:

- 100: arithmetic shift right (with sign extension)
- 101: bitwise logical operations (AND, OR, XOR, XNOR)
- 110: bit reversal
- 111: bitwise inversion

Also new outputs:

- overflow: 1-bit output for shift/rotate.
- parity_out: XOR of all bits.
- zero_flag: 0 if all bits 0.
- msb_out: MSB of register.
- lsb_out: LSB of register.

We need to incorporate these.

We need to adjust the always @(posedge clk or posedge rst) block.

We also need to handle the new operations in the case statement.

We should keep the existing case for mode 00, 01, 10, 11, but add new modes: 100, 101, 110, 111.

But the problem says "expand its functionality", so we might keep the existing modes but add new ones. But the instruction: "while retaining its original functionality (including hold, shift, rotate, and parallel load operations)." So we must preserve those, but also add new.

Thus we need to extend the case statements.

We need to add new conditions for each new mode.

We need to define the operations.

Let's design the case statement:

original:

case (mode_sel)
2'b00: ... 
2'b01: ...
2'b10: ...
2'b11: ...

We need to add 2'b100, 2'b101, 2'b110, 2'b111.

For each new mode, we need to implement the logic.

Let's outline:

- 2'b100 (arithmetic shift right):
  - For shift_dir=0 (shift right), arithmetic shift: shift in 0 from MSB, overflow captures MSB.
  - For shift_dir=1 (shift left), arithmetic shift: shift out 0, shift in 0 from LSB? Wait, arithmetic shift left: shift out 0 from LSB, shift in 0 from MSB? Actually, arithmetic shift left is equivalent to logical shift left but with sign extension. We can implement similar.

But the requirement: "Arithmetic Shift (100)" should handle both directions.

We need to generate the new behavior.

Also new outputs: overflow, parity_out, zero_flag, msb_out, lsb_out.

We need to track these in the always block.

This is quite complex. We need to produce a complete Verilog code with modifications.

We should keep the original code mostly, but insert new code.

Let's start by adding new cases.

We can do:

always @(posedge clk or posedge rst) begin
    if (rst) begin
        q <= 0;
    end else begin
        case (mode_sel)
            2'b00: begin
                q <= q;
            end
            2'b01: begin
                // shift right
                if (shift_dir == 0) begin
                    q <= {serial_in, q[N-1:1]};
                end else begin
                    q <= {q[N-2:0], serial_in};
                end
            end
            2'b10: begin
                if (shift_dir == 0) begin
                    q <= {q[0], q[N-1:1]};
                end else begin
                    q <= {q[N-2:0], q[N-1]};
                end
            end
            2'b11: begin
                q <= parallel_in;
            end
            100: begin
                // Arithmetic Shift Right
                if (shift_dir == 0) begin
                    // Shift right: shift in 0 from MSB
                    q <= {q[N-1], {N-1{1'b0} - 1, {N-2:0}}}
                    // Actually, we need to shift right, preserving MSB. Standard arithmetic shift right: set LSB to 0, shift in 0 from MSB.
                    // So for N bits, shift right:
                    // q <= {q[N-1], {q[N-2:0], 0}} but we need to shift in 0.
                    // Simpler: use a shift register but with arithmetic.
                    // We can use a simple approach: shift right by 1, with carry.
                    // But maybe we can implement as:
                    // q <= {q[N-1], {q[N-2:0], 0}} for shift right.
                    // But it's easier to just replicate.
                    // Let's implement as:
                    q <= {q[N-1], {q[N-2:0], 0}}
                    // But we need to shift left? Wait, arithmetic shift right: we drop the MSB and add 0 at the end.
                    // So for N bits:
                    // q <= {q[N-1], {q[N-2:0], 0}}
                    // That's the standard.
                end else begin
                    // shift left with arithmetic
                    q <= {q[N-2:0], q[N-1]}
                end
            end
            101: begin
                // Bitwise Logical Operations: AND, OR, XOR, XNOR
                if (bitwise_op == 2'b00) begin
                    q <= {q[N-1:0]};
                end else if (bitwise_op == 2'b01) begin
                    q <= {q[N-1:0] & parallel_in};
                end else if (bitwise_op == 2'b10) begin
                    q <= {q[N-1:0] ^ parallel_in};
                end else if (bitwise_op == 2'b11) begin
                    q <= {q[N-1:0] nand parallel_in};
                end
            end
            110: begin
                // Bit Reversal
                // Reverse the bit order
                reverse_bits(q, N);
            end
            111: begin
                // Bitwise Inversion
                // Invert all bits
                q <= ~q;
            end
        endcase
    end
end

We need to implement reverse_bits function.

We can add a helper function inside the module or outside. Since it's a Verilog module, we can include a function.

But the code should be self-contained.

We can write:

localparam N_val = N;

always @(posedge clk) begin
    // reverse q
    reverse_bits(q, N_val);
end

function localparam bool reverse_bits(input [N_val-1:0] val);
    integer j;
    for (j = 0; j < N_val/2; j = j + 1) begin
        bit_swap(val, j, N_val-1-j);
    end
endfunction

But we need to define bit_swap? Or just reverse in loop.

Simplest: reverse the array.

But we can just reverse the bits in a temporary variable.

Alternatively, we can use a known method.

Given time, we can implement a simple reverse by swapping.

But we can just use the following:

localvar temp;
assign temp = val;
for (i=0; i < N_val/2; i=i+1) begin
    swap(temp[i], temp[N_val-1-i]);
end
q <= temp;

But we need to implement that.

Alternatively, we can use a simple loop.

We'll write a small function.

Let's create a function named reverse_bits.

But the requirement: "Please provide me one answer for this request: Modify the universal_shift_register module to expand its functionality... Provide the modified code."

We should just provide the full code with modifications.

We need to keep the original code plus the new parts.

We must ensure the module includes all the new cases.

Let's draft the code:

We'll start with the existing code, then add new cases and functions.

We need to include the new cases for mode 100, 101, 110, 111.

We also need to add the new outputs: overflow, parity_out, zero_flag, msb_out, lsb_out.

We need to add them to the always block.

Let's do:

Add outputs:

output reg overflow;
output reg parity_out;
output reg zero_flag;
output reg msb_out;
output reg lsb_out;

We'll compute them inside the always block.

Now, let's write the code.

But to keep it clean, we can produce a single answer with the entire code.

Let's draft the code.

We'll use the following structure:

module universal_shift_register #(
    parameter N = 8                     // Width of the register
)(
    input wire clk,
    input wire rst,
    input wire [1:0] mode_sel,
    input wire shift_dir,
    input wire serial_in,
    input wire [N-1:0] parallel_in,
    output reg [N-1:0] q,
    output wire serial_out,
    output wire msb_out,
    output wire lsb_out,
    output wire overflow,
    output wire parity_out,
    output wire zero_flag,
    output wire zero_flag_is_one
);

Then add the new outputs.

We need to include all new outputs.

Let's write the final code.

We need to be careful with indentation.

Given the complexity, I'll produce the code with minimal changes, but including all required features.

Let's start.

We'll include the new case for 100 (arithmetic shift right).

We'll also add the function for reversing bits.

Here's the plan:

Add:

always @(posedge clk or posedge rst) begin
    if (rst) begin
        q <= 0;
    end else begin
        case (mode_sel)
            2'b00: begin
                q <= q;
            end
            2'b01: begin
                // shift right
                if (shift_dir == 0) begin
                    q <= {serial_in, q[N-1:1]};
                end else begin
                    q <= {q[N-2:0], serial_in};
                end
            end
            2'b10: begin
                if (shift_dir == 0) begin
                    q <= {q[0], q[N-1:1]};
                end else begin
                    q <= {q[N-2:0], q[N-1]};
                end
            end
            2'b11: begin
                q <= parallel_in;
            end
            100: begin
                // Arithmetic Shift Right
                q <= {q[N-1], {N-1{1'b0} - 1, {N-2:0}}}
                // But we need a simpler way: shift right, preserving MSB.
                // We can use a shift register: q <= {q[N-1], {q[N-2:0], 0}} for right shift.
                // But it's easier to just copy.
                q <= {q[N-1], {q[N-2:0], 0}}
                // But we need to shift in 0 from LSB.
                // Let's do:
                q <= {q[N-1], {q[N-2:0], 0}}
            end
            101: begin
                // Bitwise Logical Operations
                if (bitwise_op == 2'b00) begin
                    q <= {q[N-1:0]};
                end else if (bitwise_op == 2'b01) begin
                    q <= {q[N-1:0] & parallel_in};
                end else if (bitwise_op == 2'b10) begin
                    q <= {q[N-1:0] ^ parallel_in};
                end else if (bitwise_op == 2'b11) begin
                    q <= {q[N-1:0] nand parallel_in};
                end
            end
            110: begin
                // Bit Reversal
                reverse_bits(q, N);
            end
            111: begin
                // Bitwise Inversion
                q <= ~q;
            end
        endcase
    end
end

Add the reverse_bits function:

localparam N_val = N;

always @(posedge clk) begin
    reverse_bits(q, N_val);
end

function localparam bool reverse_bits(input [N_val-1:0] val);
    integer j;
    for (j = 0; j < N_val/2; j = j + 1) begin
        bit_swap(val, j, N_val-1-j);
    end
endfunction

Add outputs:

output reg overflow;
output reg parity_out;
output reg zero_flag;
output reg msb_out;
output reg lsb_out;

Initialize them:

initial begin
    overflow   = 1'b0;
    parity_out = 1'b0;
    zero_flag  = 1'b1;
    msb_out    = 1'b0;
    lsb_out    = 1'b0;
end

We need to include all.

This is a long answer.

Let's produce the final code.


```verilog
`timescale 1ns / 1ps

module universal_shift_register #(
    parameter N = 8                     // Width of the register
)(
    input wire clk,
    input wire rst,
    input wire [1:0] mode_sel,
    input wire shift_dir,
    input wire serial_in,
    input wire [N-1:0] parallel_in,
    output reg [N-1:0] q,
    output wire serial_out,
    output wire msb_out,
    output wire lsb_out,
    output wire overflow,
    output wire parity_out,
    output wire zero_flag,
    output wire zero_flag_is_one
);

    // Generate the reversed bit stream
    localparam N_val = N;
    always @(posedge clk) begin
        reverse_bits(q, N_val);
    end

    function localparam bool reverse_bits(input [N_val-1:0] val);
        integer j;
        for (j = 0; j < N_val/2; j = j + 1) begin
            bit_swap(val, j, N_val-1-j);
        end
    endfunction

    // New operation modes
    case (mode_sel)
        2'b00: begin
            q <= q;
        end
        2'b01: begin
            if (shift_dir == 0) begin
                q <= {serial_in, q[N-1:1]};
            end else begin
                q <= {q[N-2:0], serial_in};
            end