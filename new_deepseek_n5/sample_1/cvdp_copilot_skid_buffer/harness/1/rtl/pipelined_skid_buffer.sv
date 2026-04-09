module pipelined_skid_buffer(
    input wire clock,
    input wire rst,
    input wire [3:0] data_i,
    input wire valid_i,
    output wire ready_o,
    output wire valid_o,
    output wire [3:0] data_o,
    input wire ready_i
);

    // Reset logic
    always_comb begin
        if (rst) begin
            data_reg = 0;
            buffer = 0;
            valid_out = 0;
            ready_out = 0;
        end
    end

    // Data handling
    always_edge begin
        if (valid_i && !buffer) data_reg = data_i;
        if (ready_i) begin
            data_o = data_reg;
            valid_out = 1;
            ready_out = 1;
        end else begin
            data_o = data_reg;
            valid_out = valid_out;
            ready_out = ready_out;
        end
    end

    // Connect to register
    register (
        .clk(clk),
        .rst(rst),
        .data_in(data_reg),
        .valid_in(valid_out),
        .ready_in(ready_i),
        .data_out(data_o),
        .valid_out(valid_o),
        .ready_out(ready_out)
    );

    // Connect to skid_buffer
    skid_buffer (
        .clk(clk),
        .reset(rst),
        .i_data(data_i),
        .i_valid(valid_i),
        .i_ready(ready_out),
        .o_data(data_o),
        .o_valid(valid_o),
        .o_ready(ready_o)
    );

endmodule

module register(
    input clock,
    input rst,
    input [3:0] data_in,
    input valid_in,
    output ready_out,
    output valid_out,
    output [3:0] data_out,
    input ready_in
);

    // Reset logic
    always_comb begin
        if (rst) begin
            data_reg = 0;
            buffer = 0;
            valid_out = 0;
            ready_out = 0;
        end
    end

    // Data storage and forwarding
    always_edge begin
        if (valid_in && !buffer) begin
            data_reg = data_in;
            buffer = 1;
        end else begin
            data_reg = data_reg;
            buffer = 0;
        end
    end

    // Output data when ready
    always_edge begin
        if (ready_in && buffer) begin
            data_out = data_reg;
            valid_out = 1;
            ready_out = 1;
        end else begin
            data_out = data_reg;
            valid_out = valid_out;
            ready_out = ready_out;
        end
    end

endmodule

module skid_buffer(
    input clock,
    input reset,
    input [3:0] i_data,
    input i_valid,
    output o_ready,
    output [3:0] o_data,
    output o_valid,
    input i_ready
);

    // Reset logic
    always_comb begin
        if (reset) begin
            data_reg = 0;
            buffer = 0;
            o_valid = 0;
            o_ready = 0;
        end
    end

    // Data buffering
    always_edge begin
        if (i_valid && !buffer) data_reg = i_data;
        if (i_ready) begin
            o_data = data_reg;
            o_valid = 1;
            o_ready = 1;
        end else begin
            o_data = data_reg;
            o_valid = o_valid;
            o_ready = o_ready;
        end
    end

endmodule