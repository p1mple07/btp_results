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

    // Stage 1: Input Skid Buffer (skid_0)
    wire [3:0] data_skid0_out;
    wire valid_skid0_out;
    wire ready_skid0_out;

    // Stage 2: Register (reg1)
    wire [3:0] reg1_out;
    wire valid_reg1_out;
    wire ready_reg1_out;

    // Stage 3: Second Skid Buffer (skid_2)
    wire [3:0] data_skid2_out;
    wire valid_skid2_out;
    wire ready_skid2_out;

    // Stage 4: Final Register (reg3)
    wire [3:0] reg3_out;
    wire valid_reg3_out;
    wire ready_reg3_out;

    // Internal signals for register
    register reg1(
        input clock = clock,
        input rst = rst,
        input [3:0] data_in = data_skid0_out,
        input valid_in = valid_skid0_out,
        output ready_out = ready_reg1_out,
        output valid_out = valid_reg1_out,
        output [3:0] data_out = reg1_out,
        input ready_in = ready_skid2_out
    );

    // Internal signals for skid buffer
    skid_buffer skid0(
        input clock = clock,
        input reset = rst,
        input [3:0] i_data = data_i,
        input i_valid = valid_i,
        output o_ready = ready_skid0_out,
        output [3:0] o_data = data_skid0_out,
        output o_valid = valid_skid0_out,
        input i_ready = ready_i
    );

    skid_buffer skid2(
        input clock = clock,
        input reset = rst,
        input [3:0] i_data = reg1_out,
        input i_valid = valid_reg1_out,
        output o_ready = ready_skid2_out,
        output [3:0] o_data = data_skid2_out,
        output o_valid = valid_skid2_out,
        input i_ready = ready_reg3_out
    );

    register reg3(
        input clock = clock,
        input rst = rst,
        input [3:0] data_in = data_skid2_out,
        input valid_in = valid_skid2_out,
        output ready_out = ready_reg3_out,
        output valid_out = valid_reg3_out,
        output [3:0] data_out = reg3_out,
        input ready_in = ready_skid0_out
    );

    // Final Output
    data_o = reg3_out;
    valid_o = valid_reg3_out;
    ready_o = ready_reg3_out;
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

    // Internal state variables
    reg [3:0] data_reg;
    reg data_present;

    always @(posedge clock or posedge rst) begin
        if (rst) begin
            data_reg = 8'b0000;
            data_present = 0;
        else begin
            if (valid_in) begin
                if (data_present) begin
                    data_reg = data_in;
                    data_present = 0;
                else if (!ready_in) begin
                    data_reg = data_in;
                    data_present = 1;
                end
            end
            if (!data_present && !valid_in && !ready_in) begin
                data_reg = 8'b0000;
                data_present = 0;
            end
            ready_out = (data_present == 1);
            valid_out = (data_present == 1);
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

    // Internal state variables
    reg [3:0] data_reg;
    reg buffer;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            data_reg = 8'b0000;
            buffer = 0;
        else begin
            if (i_valid) begin
                if (buffer) begin
                    o_data = data_reg;
                    o_valid = 1;
                    o_ready = 1;
                    buffer = 0;
                else if (i_ready) begin
                    data_reg = i_data;
                    buffer = 1;
                end
            end
            if (!buffer && !i_valid && !i_ready) begin
                data_reg = 8'b0000;
                buffer = 0;
            end
            o_ready = (buffer == 0);
            o_valid = (buffer == 1);
        end
    end
endmodule