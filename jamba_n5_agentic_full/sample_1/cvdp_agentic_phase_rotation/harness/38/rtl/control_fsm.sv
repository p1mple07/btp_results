module control_fsm (
    input clk,
    input rst_async_n,
    input wire i_enable,
    input wire i_subsampling,
    input wire i_valid,
    output reg o_start_calc,
    output reg o_valid,
    output reg o_subsampling,
    output reg o_calc_valid,
    output reg o_calc_fail,
    output reg o_wait
);

localparam NBW_WAIT = 32;

reg [31:0] general_counter;
reg timeout_counter;

// Counters
always @(posedge clk or posedge rst_async_n) begin
    if (!rst_async_n) begin
        general_counter <= 0;
        timeout_counter <= 0;
    end else begin
        if (i_enable) begin
            general_counter <= general_counter + 1;
        end else begin
            // reset counter? Not specified. Maybe keep as is.
        end
    end
end

always @(posedge clk) begin
    if (i_enable) begin
        if (i_subsampling) begin
            o_subsampling = i_subsampling;
        end else begin
            o_subsampling = !i_subsampling;
        end
    end else begin
        o_subsampling = 0;
    end
end

always @(posedge clk) begin
    if (i_valid && !i_calc_fail) begin
        o_valid = 1;
    end else begin
        o_valid = 0;
    end
end

always @(posedge clk) begin
    if (i_calc_valid) begin
        o_calc_valid = 1;
    end else begin
        o_calc_valid = 0;
    end
end

always @(posedge clk) begin
    if (i_calc_fail) begin
        o_calc_fail = 1;
    end else begin
        o_calc_fail = 0;
    end
end

always @(posedge clk) begin
    if (i_calc_valid && ~i_calc_fail) begin
        o_calc_valid = 1;
    end else begin
        o_calc_valid = 0;
    end
end

always @(posedge clk) begin
    if (i_calc_fail && ~i_calc_valid) begin
        o_calc_fail = 1;
    end else begin
        o_calc_fail = 0;
    end
end

always @(posedge clk) begin
    if (i_calc_valid && ~i_calc_fail) begin
        o_calc_valid = 1;
    end else begin
        o_calc_valid = 0;
    end
end

always @(posedge clk) begin
    if (i_calc_fail && ~i_calc_valid) begin
        o_calc_fail = 1;
    end else begin
        o_calc_fail = 0;
    end
end

always @(posedge clk) begin
    if (i_calc_valid && ~i_calc_fail) begin
        o_calc_valid = 1;
    end else begin
        o_calc_valid = 0;
    end
end

always @(posedge clk) begin
    if (i_calc_fail && ~i_calc_valid) begin
        o_calc_fail = 1;
    end else begin
        o_calc_fail = 0;
    end
end

always @(posedge clk) begin
    if (i_calc_valid && ~i_calc_fail) begin
        o_calc_valid = 1;
    end else begin
        o_calc_valid = 0;
    end
end

always @(posedge clk) begin
    if (i_calc_fail && ~i_calc_valid) begin
        o_calc_fail = 1;
    end else begin
        o_calc_fail = 0;
    end
end

always @(posedge clk) begin
    if (i_calc_valid && ~i_calc_fail) begin
        o_calc_valid = 1;
    end else begin
        o_calc_valid = 0;
    end
end

always @(posedge clk) begin
    if (i_calc_fail && ~i_calc_valid) begin
        o_calc_fail = 1;
    end else begin
        o_calc_fail = 0;
    end
end

always @(posedge clk) begin
    if (i_calc_valid && ~i_calc_fail) begin
        o_calc_valid = 1;
    end else begin
        o_calc_valid = 0;
    end
end

always @(posedge clk) begin
    if (i_calc_fail && ~i_calc_valid) begin
        o_calc_fail = 1;
    end else begin
        o_calc_fail = 0;
    end
end

always @(posedge clk) begin
    if (i_calc_valid && ~i_calc_fail) begin
        o_calc_valid = 1;
    end else begin
        o_calc_valid = 0;
    end
end

always @(posedge clk) begin
    if (i_calc_fail && ~i_calc_valid) begin
        o_calc_fail = 1;
    end else begin
        o_calc_fail = 0;
    end
end

endmodule
