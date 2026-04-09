always_ff @(posedge i_axi_clk or posedge rst) begin
    if (rst) begin
        o_block_fifo_act   <= 1'b0;
        o_axi_valid        <= 1'b0;
        fifo_data_buffer   <= {DATA_WIDTH{1'b0}};
        fifo_valid_buffer  <= 1'b0;
        fifo_last_buffer   <= 1'b0;
    end else begin
        // Process FIFO data
        if (i_block_fifo_rdy) begin
            // Read FIFO
            if (i_block_fifo_act) begin
                // FIFO is active, read data
                // Assume the data is stored in fifo_data_buffer.
                // But we need to copy to output.
                // Let's just copy the buffer.
                o_axi_data = fifo_data_buffer;
                o_axi_last = fifo_last_buffer;
                o_axi_valid = 1'b1;
            end

            // Update FIFO buffers
            fifo_data_buffer   <= {DATA_WIDTH{1'b0}};
            fifo_valid_buffer  <= 1'b0;
            fifo_last_buffer   <= 1'b0;
        end

        // Now process AXI interface
        if (i_axi_ready) begin
            // Send data to AXI
            o_axi_data = o_axi_data_out; // Wait, we don't have o_axi_data_out defined. We need to output to AXI.

            Actually, we need to output the data from the buffer.

            So we should assign o_axi_data to the buffer content.

            But we need to check if we have any output signals.

Let's re-evaluate the partial code.

The partial code has:

output logic o_axi_data,
output logic o_axi_last,
output logic o_axi_valid.

So we need to set these.

In the always_ff block, after reading FIFO, we can set:

o_axi_data = fifo_data_buffer;
o_axi_last = fifo_last_buffer;
o_axi_valid = 1'b1;

But we must ensure that the buffer is updated before writing.

Also, we need to handle the case when FIFO not ready: we don't want to output anything, so set all outputs to zero.

Also, we need to handle the case when AXI not ready: we may output nothing.

But the specification: "AXI not ready, the data transfer should stall without losing data." So we should set output signals to 0.

Thus, we can structure:

In the always_ff block:

if (i_block_fifo_rdy) begin
    if (i_block_fifo_act) begin
        // Copy data to AXI
        o_axi_data = fifo_data_buffer;
        o_axi_last = fifo_last_buffer;
        o_axi_valid = 1'b1;
    end

    // Update FIFO buffers
    fifo_data_buffer   <= {DATA_WIDTH{1'b0}};
    fifo_valid_buffer  <= 1'b0;
    fifo_last_buffer   <= 1'b0;
end

else begin
    o_axi_valid = 1'b0;
    o_axi_data = 0;
    o_axi_last = 0;
    // ... maybe o_axi_user? We can leave as 0.
end

Also, we need to handle the case when i_axi_ready is deasserted: we should not output data. So we can set o_axi_valid=0, etc.

But the partial code already has:

output logic o_axi_user,
input  logic i_axi_user,
input  logic i_axi_ready,
output logic o_axi_ready.

But we don't need to output o_axi_ready because we can stall.

But the specification says: "handle readiness and transfer controls."

We need to produce the full code.

Let's try to write the code with the necessary blocks.

We also need to include the reset conditions:

always_ff @(posedge i_axi_clk or posedge rst) begin
    if (rst) begin
        o_block_fifo_act   <= 1'b0;
        o_axi_valid        <= 1'b0;
        fifo_data_buffer   <= {DATA_WIDTH{1'b0}};
        fifo_valid_buffer  <= 1'b0;
        fifo_last_buffer   <= 1'b0;
    end else begin
        // Process FIFO
        if (i_block_fifo_rdy) begin
            if (i_block_fifo_act) begin
                o_axi_data = fifo_data_buffer;
                o_axi_last = fifo_last_buffer;
                o_axi_valid = 1'b1;
            end

            fifo_data_buffer   <= {DATA_WIDTH{1'b0}};
            fifo_valid_buffer  <= 1'b0;
            fifo_last_buffer   <= 1'b0;
        end

        // AXI interface
        if (i_axi_ready) begin
            o_axi_valid = 1'b1;
            o_axi_data = o_axi_data_out; // We need to define o_axi_data_out. But maybe we can assume that the previous assignment sets it? Actually, we might not need to set it again. But in our partial code, there's no output for o_axi_data except maybe in the always_ff block. So we can set o_axi_data to the current buffer value, but we have to ensure we don't overwrite.

Wait, maybe we should avoid using the partial code's o_axi_data variable. Instead, we can compute the output based on the state.

Given the complexity, maybe we can simplify: we output the data from the FIFO if ready, otherwise nothing.

The question: "Complete the given partial SystemVerilog code for a module ping_pong_fifo_2_axi_stream".

We need to produce the entire module with the internal signals and the always_ff block.

We should also include the reset condition and any other necessary code.

Let's draft the code:

We need to include the module instantiation inside the always_ff block? Actually, we can write the always_ff block at the end.

The module should have:

module ping_pong_fifo_2_axi_stream #( ... ) (
    input  logic rst,

    // Ping Pong FIFO Read Interface
    input  logic i_block_fifo_rdy,
    output logic o_block_fifo_act,
    input  logic [23:0] i_block_fifo_size,
    input  logic [(DATA_WIDTH + 1) - 1:0] i_block_fifo_data,
    output logic o_block_fifo_stb,

    // AXI Stream Output
    input  logic i_axi_clk,
    output logic [3:0] o_axi_user,
    input  logic i_axi_ready,
    output logic [DATA_WIDTH - 1:0] o_axi_data,
    output logic o_axi_last,
    output logic o_axi_valid
);

    // Internal signals
    logic [DATA_WIDTH - 1:0] fifo_data_buffer;
    logic fifo_valid_buffer;
    logic fifo_last_buffer;

    // Reset condition
    always_ff @(posedge i_axi_clk or posedge rst) begin
        if (rst) begin
            o_block_fifo_act   <= 1'b0;
            o_axi_valid        <= 1'b0;
            fifo_data_buffer   <= {DATA_WIDTH{1'b0}};
            fifo_valid_buffer  <= 1'b0;
            fifo_last_buffer   <= 1'b0;
        end else begin
            // Process FIFO data
            if (i_block_fifo_rdy) begin
                if (i_block_fifo_act) begin
                    o_axi_data     = fifo_data_buffer;
                    o_axi_last      = fifo_last_buffer;
                    o_axi_valid     = 1'b1;
                end

                fifo_data_buffer   <= {DATA_WIDTH{1'b0}};
                fifo_valid_buffer  <= 1'b0;
                fifo_last_buffer   <= 1'b0;
            end

            // AXI interface
            if (i_axi_ready) begin
                o_axi_valid     = 1'b1;
                o_axi_data       = o_axi_data_out; // We need to set it. But we don't have o_axi_data_out defined. Maybe we can use the same buffer?

Alternatively, we can simply set o_axi_data to the current buffer value, but we must ensure we don't overwrite. Since we are in a sequential process, we can just copy.

But we might not need to set it again if we already did.

However, for simplicity, we can set o_axi_data to the same value as fifo_data_buffer, but we might need to use a different method.

Given the constraints, we can output the data from the FIFO as is, and the rest can be zero.

But the problem is that the output must be per the AXI Stream protocol.

Let's just set o_axi_data to the value from the buffer, and o_axi_last to the last value, and o_axi_valid to 1.

But we need to avoid recomputing if we already did.

Maybe we can use a combinational block outside the always_ff, but the always_ff will handle it.

Given the time, I'll write the code as follows:

Inside the always_ff block:

if (i_block_fifo_rdy) begin
    if (i_block_fifo_act) begin
        o_axi_data = fifo_data_buffer;
        o_axi_last = fifo_last_buffer;
        o_axi_valid = 1'b1;
    end

    fifo_data_buffer   <= {DATA_WIDTH{1'b0}};
    fifo_valid_buffer  <= 1'b0;
    fifo_last_buffer   <= 1'b0;
end

else begin
    o_axi_valid = 1'b0;
    o_axi_data = 0;
    o_axi_last = 0;
    // ... maybe o_axi_user? We can set to 0 as well.
end

Also, we need to handle the case when i_axi_ready is deasserted: set o_axi_valid=0, etc.

But the above code does that implicitly.

Now, we need to produce the full code.

We should also include the module declaration and ports.

The partial code ends with:

end
