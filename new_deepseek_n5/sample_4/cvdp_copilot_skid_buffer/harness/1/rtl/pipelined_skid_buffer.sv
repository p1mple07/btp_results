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

    // Input skid buffer
    wire [3:0] skid_0_data;
    wire skid_0_valid;
    wire skid_0_ready;

    // Register
    register
        input clock,
        input rst,
        input [3:0] skid_0_data,
        input skid_0_valid,
        output ready_out: skid_0_ready,
        output valid_out: skid_0_valid,
        output [3:0] reg1_data: skid_0_data,
        input ready_in: skid_0_ready
    reg1;

    // Output skid buffer
    wire [3:0] skid_2_data;
    wire skid_2_valid;
    wire skid_2_ready;

    // Final register
    register
        input clock,
        input rst,
        input [3:0] skid_2_data,
        input skid_2_valid,
        output ready_out: skid_2_ready,
        output valid_out: skid_2_valid,
        output [3:0] reg3_data: skid_2_data,
        input ready_in: skid_2_ready
    reg3;

    // Internal processing
    always clock begin
        if (rst) begin
            skid_0_valid = 0;
            skid_0_ready = 0;
            reg1_data = 4'b0000;
            skid_2_valid = 0;
            skid_2_ready = 0;
            reg3_data = 4'b0000;
        else begin
            // Input skid buffer
            if (valid_i && ready_i) begin
                skid_0_data = data_i;
                skid_0_valid = 1;
                skid_0_ready = 1;
            end

            // Register
            if (skid_0_valid && skid_0_ready) begin
                reg1_data = skid_0_data;
                reg1_valid_out = 1;
                reg1_ready_out = 1;
            end

            // Output skid buffer
            if (reg1_valid_out && reg1_ready_out) begin
                skid_2_data = reg1_data;
                skid_2_valid = 1;
                skid_2_ready = 1;
            end

            // Final register
            if (skid_2_valid && skid_2_ready) begin
                reg3_data = skid_2_data;
                reg3_valid_out = 1;
                reg3_ready_out = 1;
            end
        end
    end
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

    flip-flop data_reg;
    flip-flop valid_out_reg;
    flip-flop ready_out_reg;

    always clock begin
        if (rst) begin
            data_reg = 4'b0000;
            valid_out_reg = 0;
            ready_out_reg = 0;
        else begin
            if (valid_in && ready_in) begin
                data_reg = data_in;
                valid_out_reg = 1;
                ready_out_reg = 1;
            else begin
                data_reg = 4'b0000;
                valid_out_reg = 0;
                ready_out_reg = 0;
            end
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

    flip-flop data_reg;
    flip-flop valid_out_reg;
    flip-flop ready_out_reg;
    wire buffer;

    always clock begin
        if (reset) begin
            data_reg = 4'b0000;
            valid_out_reg = 0;
            ready_out_reg = 0;
            buffer = 0;
        else begin
            if (i_valid && !i_ready) begin
                buffer = 1;
                data_reg = i_data;
                valid_out_reg = 0;
                ready_out_reg = 0;
            else if (i_valid && i_ready) begin
                buffer = 0;
                valid_out_reg = 1;
                ready_out_reg = 1;
            else begin
                data_reg = 4'b0000;
                valid_out_reg = 0;
                ready_out_reg = 0;
            end
        end
    end

    if (buffer) begin
        o_data = data_reg;
        o_valid = valid_out_reg;
        o_ready = ready_out_reg;
    else begin
        o_data = 4'b0000;
        o_valid = 0;
        o_ready = 0;
    end
endmodule