

We need to fill in the code.

We should implement the logic as described.

Let's create the code inside the always block.

We need to handle reset, then else.

Inside else:

prev_data_in = data_in;

if (data_in == prev_data_in) begin
    run_length = run_length + 1;

    if (run_length == DATA_WIDTH) begin
        run_length = 0;
        run_value = prev_data_in;
    end else begin
        run_value = prev_data_in;
    end
end else begin
    run_length = 1;
    run_value = prev_data_in;
    prev_data_in = data_in;
end

Also, we need to output data_out and valid and run_value and run_length.

But the partial code already has some outputs. We just need to fill in the logic.

We also need to consider valid: the problem says "valid is HIGH when the incoming data_in bit count reaches the DATA_WIDTH and becomes LOW after a clock cycle. It also becomes HIGH, when the data_in at the current clock cycle is not equal to the value during the previous clock cycle."

This seems confusing. Maybe valid is simply the same as data_out? But the problem says: "valid is HIGH when the incoming data_in bit count reaches the DATA_WIDTH and becomes LOW after a clock cycle. It also becomes HIGH, when the data_in at the current clock cycle is not equal to the value during the previous clock cycle."

We might interpret that valid is set to 1 when data_in is different from previous, and reset to 0 after a clock cycle.

But we might simplify: valid = !(data_in == prev_data_in). But we need to output valid as 1 when data_in differs.

But the partial code has:

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        valid    <= 1'b0;
        data_out <= 1'b0;
    end 
    else begin
        //Insert code here for handling valid and data_out signals of runlength coding logic  


We need to fill this block.

Given the complexity, maybe we can output valid and data_out as per the same condition as run_value.

Let's propose:

valid = (data_in != prev_data_in);
data_out = prev_data_in;

But the problem says: "Update data_out to the value of the previous input when the present data_in is different from the previous data_in."

So data_out should be prev_data_in when data_in differs. When same, data_out remains previous? Actually, data_out is the previous data_in, regardless of whether same or different? The requirement: "Update data_out to the value of the previous input when the present data_in is different from the previous data_in." So if data_in is same, data_out stays same. If different, data_out becomes previous.

But also, data_out should be the previous input when present data_in is different. That means if data_in changes, data_out updates to previous value.

Thus, we can set data_out = prev_data_in; but also we need to update prev_data_in to data_in for next cycle.

But the problem says "when the present data_in is different from the previous data_in". So when different, data_out is set to prev_data_in (previous data_in). When same, data_out remains same.

So we can do:

data_out = prev_data_in;

Then, after that, prev_data_in = data_in.

But we need to incorporate this in the always block.

Let's structure the code:

always @(posedge clk) begin
    if (!reset_n) begin
        run_length <= 'b0;
        run_value <= 'b0;
        prev_data_in <= 1'b0;
    end else begin
        prev_data_in = data_in;

        if (data_in == prev_data_in) begin
            run_length = run_length + 1;

            if (run_length == DATA_WIDTH) begin
                run_length = 0;
                run_value = prev_data_in;
            end else begin
                run_value = prev_data_in;
            end
        end else begin
            run_length = 1;
            run_value = prev_data_in;
            prev_data_in = data_in;
        end

        data_out = prev_data_in;
        valid = (data_in != prev_data_in);
    end
end

But we also need to set run_value to the previous run value? Actually, run_value is set to prev_data_in when data_in differs, or when saturating, etc.

But the requirement: "output run_value" which is the previous run value when we reset, etc.

We need to ensure the output lines are correctly placed.

Now, the partial code already has:

output reg data_out,
output reg [$clog2(DATA_WIDTH):0] run_value,
output reg valid.

So we just need to fill the code inside the always blocks.

Thus, we will provide the full Verilog code inside the module.

We need to output the code as plain text.

Let's write the code:

We need to include the reset handling, then the main logic.

We'll include:

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        run_length   <= 'b0;
        run_value    <= 'b0;
        prev_data_in <= 1'b0;
    end
    else begin
        prev_data_in = data_in;

        if (data_in == prev_data_in) begin
            run_length = run_length + 1;

            if (run_length == DATA_WIDTH) begin
                run_length = 0;
                run_value = prev_data_in;
            end else begin
                run_value = prev_data_in;
            end
        end else begin
            run_length = 1;
            run_value = prev_data_in;
            prev_data_in = data_in;
        end

        data_out = prev_data_in;
        valid = (data_in != prev_data_in);
    end
end

We need to put this inside the module.

We also need to ensure the output signals are declared.

The partial code includes:

output reg data_out,
output reg [$clog2(DATA_WIDTH):0] run_value,
output reg valid.

We just need to fill the code.

Thus, the final answer should be the complete Verilog module.

Let's format accordingly.


