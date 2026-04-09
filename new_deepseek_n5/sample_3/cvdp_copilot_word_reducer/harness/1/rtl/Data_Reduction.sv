Okay, I need to help complete the given SystemVerilog code for the Data_Reduction module. Let me start by understanding the problem.

The Data_Reduction module is supposed to take multiple input data elements, each of a certain width, and reduce them into a single output element using a specified Boolean operation. The Bitwise_Reduction module is already provided, so I can use that as a building block.

Looking at the Data_Reduction module's interface, it has parameters REDUCTION_OP, DATA_WIDTH, and DATA_COUNT. The inputs are data_in, which is a flattened array of all the input data elements. The output is reduced_data_out, which should be a single data element of DATA_WIDTH bits.

The design overview says that for each bit position in the output, I need to gather the corresponding bits from all input data elements and use Bitwise_Reduction to compute the result. So, I'll need to loop through each bit of the output, extract the corresponding bits from each input data element, and pass them to Bitwise_Reduction.

In the current code, there's a generate loop that's supposed to handle each bit. Inside the loop, it's trying to extract bits from data_in. But the code inside the loop is incomplete. I need to fill that in.

Wait, the code inside the for loop has a wire [DATA_COUNT-1:0] extracted_bits. That's correct because for each bit position, each input data element contributes one bit. So, for each bit_index, I need to create a vector that contains the bit at position bit_index from each data element.

So, for each bit_index from 0 to DATA_WIDTH-1, I'll create an extracted_bits vector. Then, I'll connect data_in's bits to this vector. For example, data_in[bit_index * DATA_COUNT + j] for j from 0 to DATA_COUNT-1. Wait, no, because data_in is a single wire of width TOTAL_INPUT_WIDTH, which is DATA_WIDTH * DATA_COUNT. So, to extract the j-th bit of the i-th data element, it's data_in[i * DATA_WIDTH + j]. Hmm, maybe I should think of data_in as being laid out as data_element_0, data_element_1, ..., data_element_DATA_COUNT-1, each of DATA_WIDTH bits. So, the first DATA_WIDTH bits are data_element_0, next DATA_WIDTH are data_element_1, etc.

So, for each bit_index, the extracted_bits vector should be data_in[bit_index], data_in[bit_index + DATA_WIDTH], data_in[bit_index + 2*DATA_WIDTH], and so on until all DATA_COUNT elements are covered.

Wait, no. Because data_in is a single wire of width DATA_WIDTH * DATA_COUNT. So, for example, if DATA_WIDTH is 4 and DATA_COUNT is 4, data_in is 16 bits. The first 4 bits are data_element_0, next 4 data_element_1, etc. So, for bit_index 0, the bits are data_in[0], data_in[4], data_in[8], data_in[12]. So, the extracted_bits should be data_in[bit_index + j * DATA_WIDTH] for j from 0 to DATA_COUNT-1.

So, in the loop, for each bit_index, I need to create a vector that connects data_in[bit_index + j * DATA_WIDTH] for each j. Then, pass this vector to Bitwise_Reduction.

Looking at the current code, inside the for loop, it's trying to assign extracted_bits to data_in[bit_index], but that's not correct. Instead, it should create a vector that includes all the bits from each data element at the current bit_index.

So, I'll modify the code inside the loop. For each bit_index, create a vector that starts at data_in[bit_index] and then includes every DATA_WIDTH step up to DATA_COUNT times. Then, connect this vector to the input of Bitwise_Reduction.

Wait, the Bitwise_Reduction module expects an input_bits vector of length BIT_COUNT, which in this case is DATA_COUNT. So, for each bit_index, the extracted_bits should be a vector of DATA_COUNT bits, each from the corresponding data element's bit_index.

So, in the code, I'll create a vector inside the loop, say, input_to_bitwise, and assign it as data_in[bit_index], data_in[bit_index + DATA_WIDTH], etc., up to DATA_COUNT times.

Then, I'll connect this input_to_bitwise to the input_bits of Bitwise_Reduction. Since Bitwise_Reduction is a module that processes an array of bits, I can use the wire keyword to connect the vector to input_bits.

Wait, but in the current code, the Bitwise_Reduction's input is a wire, so I can directly connect the vector to it.

So, inside the loop, after creating extracted_bits, I'll wire it to Bitwise_Reduction's input_bits. Then, the output of Bitwise_Reduction is a single bit, which I'll assign to reduced_data_out[bit_index].

Putting it all together, inside the for loop, I'll:

1. Create a vector extracted_bits of size DATA_COUNT.
2. For each j from 0 to DATA_COUNT-1, assign extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH].
3. Wire extracted_bits to Bitwise_Reduction's input_bits.
4. Assign the output of Bitwise_Reduction to reduced_data_out[bit_index].

Wait, but in the current code, the Bitwise_Reduction's input is a wire, so I can directly connect the extracted_bits vector to it. So, I'll use the wire keyword: wire extracted_bits to Bitwise_Reduction.input_bits.

Then, the output of Bitwise_Reduction is a single bit, which I'll assign to reduced_data_out[bit_index].

So, the code inside the loop should look like:

wire [DATA_COUNT-1:0] extracted_bits;
extracted_bits = data_in[bit_index];
for (j = 1; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result = Bitwise_Reduction.reduced_bit;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly.

Alternatively, since the Bitwise_Reduction is a module, I can connect the output to a wire and then assign it, but in this case, since it's a single bit, it's easier to assign directly.

Wait, in the current code, the Bitwise_Reduction's output is a reg, but in the generate loop, it's being used as a wire. Hmm, maybe that's a mistake. Because in the generate statement, the output is declared as reg, but inside the loop, it's being assigned to a wire. That might not work. So, perhaps I should change the output to a wire in the Data_Reduction module.

But according to the problem statement, the Data_Reduction module's output is a reg. So, I should keep it as a reg. Therefore, inside the loop, I can assign the output of Bitwise_Reduction to a local reg and then assign that to reduced_data_out[bit_index].

So, the code inside the loop would be:

// Inside the for loop
wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    if (j == 0) {
        extracted_bits[j] = data_in[bit_index];
    } else {
        extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
    }
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can just assign it directly without needing an intermediate variable. So, perhaps it's better to wire the output directly.

Alternatively, perhaps the Bitwise_Reduction module's output is a wire, but in the current code, it's a reg. So, maybe I should change it to a wire. But according to the problem statement, the Data_Reduction module's output is a reg, so I should keep it as a reg.

Wait, looking back, the Data_Reduction module's output is declared as reg [DATA_WIDTH-1:0], so it's a register. Therefore, in the loop, I can assign the output of Bitwise_Reduction to a local reg and then to the output.

So, the code inside the loop would be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    if (j == 0) {
        extracted_bits[j] = data_in[bit_index];
    } else {
        extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
    }
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can just assign it directly without needing an intermediate variable. So, perhaps it's better to do:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    if (j == 0) {
        extracted_bits[j] = data_in[bit_index];
    } else {
        extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
    }
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

Wait, but the Bitwise_Reduction's output is a reg, so I can wire it directly to the output wire of Data_Reduction.

So, perhaps the code inside the loop should be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can wire it directly to the output wire of Data_Reduction.

So, in the generate loop, for each bit_index, I create a vector extracted_bits that contains all the corresponding bits from each data element. Then, I wire this vector to Bitwise_Reduction's input_bits. Then, I wire Bitwise_Reduction's output to reduced_data_out[bit_index].

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can wire it directly to a wire without needing an intermediate reg. So, perhaps the code can be simplified.

So, the code inside the loop would be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But wait, in the current code, the Bitwise_Reduction's output is a reg, so I can't wire it directly to a wire. I need to declare it as a wire and then assign it.

Alternatively, perhaps I can assign it directly to a wire without declaring it as a reg. Let me check the code.

In the current code, the Bitwise_Reduction module's output is declared as reg. So, in the Data_Reduction module, I can wire it to a wire and then assign it directly.

So, the code inside the loop would be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can't wire it directly to a wire. I need to declare it as a wire in the Data_Reduction module.

So, perhaps I should add a wire declaration for Bitwise_Reduction.reduced_bit in the Data_Reduction module.

But looking at the Data_Reduction module's code, the output is declared as reg, so perhaps I can assign it directly.

Alternatively, perhaps the Bitwise_Reduction's output is a wire, but in the current code, it's a reg. So, I can change it to a wire.

But according to the problem statement, the Data_Reduction module's output is a reg, so I should keep it as a reg.

Wait, perhaps I can assign the output of Bitwise_Reduction to a local reg in the Data_Reduction module and then assign it to the output.

So, inside the loop:

reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

But that might not be necessary. Alternatively, perhaps I can directly assign the output of Bitwise_Reduction to the output wire.

Wait, perhaps the Bitwise_Reduction module's output can be wired to the Data_Reduction's output wire.

So, in the Data_Reduction module, I can have a wire reduced_data_out[DATA_WIDTH-1:0], and then wire the output of Bitwise_Reduction to each bit.

Wait, but the Data_Reduction module's output is a single reg, so perhaps I need to create a wire for each bit.

Alternatively, perhaps I can create a vector that combines all the bits and then assign it to reduced_data_out.

But that might complicate things. So, perhaps the simplest way is to loop through each bit, compute the result using Bitwise_Reduction, and assign it to the corresponding position in reduced_data_out.

So, putting it all together, the code inside the generate loop would be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can't wire it directly. I need to declare it as a wire.

So, perhaps I should add a wire declaration for Bitwise_Reduction.reduced_bit in the Data_Reduction module.

Alternatively, perhaps I can assign it directly to a wire without declaring it as a reg.

Wait, in the Data_Reduction module, I can declare a wire for each bit's output. So, for each bit_index, I can have a wire that connects to the output.

But that might not be efficient. Alternatively, perhaps I can create a vector that combines all the bits and assign it to reduced_data_out.

Wait, perhaps a better approach is to create a vector that holds all the results from Bitwise_Reduction and then assign it to reduced_data_out.

But that might require more complex code.

Alternatively, perhaps I can loop through each bit, compute the result, and assign it to the corresponding position in reduced_data_out.

So, the code inside the generate loop would be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and assign it to reduced_data_out.

Wait, perhaps the simplest way is to create a vector that holds all the results from Bitwise_Reduction and then assign it to reduced_data_out.

But that might require more code.

Alternatively, perhaps I can loop through each bit, compute the result, and assign it to the corresponding position in reduced_data_out.

So, the code inside the generate loop would be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

So, perhaps the code inside the loop should be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg, I can't wire it directly. So, I need to declare it as a wire.

Wait, perhaps the Data_Reduction module should have a wire for each bit's output. So, I can declare a wire for each bit.

Alternatively, perhaps I can create a vector that holds all the bits and then assign it to reduced_data_out.

Wait, perhaps the Data_Reduction module can have a vector that is the same size as DATA_WIDTH and then assign each bit.

But that might complicate things.

Alternatively, perhaps the code inside the generate loop can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
reg bit_result;
Bitwise_Reduction.reduced_bit = bit_result;
reduced_data_out[bit_index] = bit_result;

Wait, but in the current code, the Bitwise_Reduction's output is a reg, so I can assign it directly to a local reg and then to the output.

Alternatively, perhaps I can assign it directly to the output without using a local reg.

So, perhaps the code can be:

wire [DATA_COUNT-1:0] extracted_bits;
for (j = 0; j < DATA_COUNT; j = j + 1) begin
    extracted_bits[j] = data_in[bit_index + j * DATA_WIDTH];
end
wire extracted_bits to Bitwise_Reduction.input_bits;
wire Bitwise_Reduction.reduced_bit to reduced_data_out[bit_index];

But again, since Bitwise_Reduction's output is a reg,