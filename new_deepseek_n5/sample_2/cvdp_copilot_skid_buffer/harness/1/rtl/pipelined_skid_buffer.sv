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

    // Input Skid Buffer
    skid_buffer skid0(
        clock,
        rst,
        data_i,
        valid_i,
        output wire o_ready,
        output [3:0] o_data,
        output wire o_valid,
        ready_i
    );

    // Register 1
    register reg1(
        clock,
        rst,
        skid0.o_data,
        valid_i,
        output wire ready_out1,
        output [3:0] data_out,
        input wire valid_in1
    );

    // Skid Buffer 2
    skid_buffer skid2(
        clock,
        rst,
        reg1.output_data,
        reg1.valid_out,
        output wire o_ready2,
        output [3:0] o_data2,
        output wire o_valid2,
        reg1.ready_out
    );

    // Register 3
    register reg3(
        clock,
        rst,
        skid2.o_data2,
        reg1.valid_out,
        output wire ready_out3,
        output [3:0] data_out3,
        input wire valid_in3
    );

    // Final Outputs
    data_o = reg3.output_data;
    valid_o = reg3.valid_out;
    ready_o = reg3.ready_out;

endmodule

module register(
    input clk,
    input rst,
    input [3:0] data_in,
    input valid_in,
    output ready_out,
    output valid_out,
    output [3:0] data_out,
    input ready_in
);

    // Internal State
    reg data_reg;
    reg valid_reg;
    reg buffer;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_reg = 8'b0000;
            valid_reg = 1;
            buffer = 0;
        else begin
            if (valid_in && buffer) begin
                data_reg = data_in;
                valid_reg = 1;
                buffer = 1;
            else begin
                if (ready_in) begin
                    data_out = data_reg;
                    valid_out = valid_reg;
                    data_reg = 8'b0000;
                    valid_reg = 0;
                    buffer = 0;
                end
            end
        end
    end

    ready_out = buffer;
endmodule

module skid_buffer(
    inputclk,
    inputreset ,
    input [3:0]i_data,
    inputi_valid,
    output o_ready,

    output [3:0]o_data,
    output o_valid,
    inputi_ready
);

    // Internal State
    reg data_reg;
    reg valid_reg;
    reg buffer;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_reg = 8'b0000;
            valid_reg = 1;
            buffer = 0;
        else begin
            if (i_valid && buffer) begin
                data_reg = i_data;
                valid_reg = 1;
                buffer = 1;
            else begin
                if (i_ready) begin
                    o_data = data_reg;
                    o_valid = valid_reg;
                    data_reg = 8'b0000;
                    valid_reg = 0;
                    buffer = 0;
                end
            end
        end
    end

    o_ready = buffer;
endmodule