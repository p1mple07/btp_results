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

    wire buffer_flag;
    wire buffer_reg;

    // Register for intermediate storage
    register reg1(
        .clk(clock),
        .rst(rst),
        .data_in(buffer_reg),
        .valid_in(valid_i),
        .ready_out(ready_o),
        .valid_out(valid_o),
        .data_out(data_o),
        .ready_in(ready_i)
    );

    // Skid buffer logic
    always @(posedge clock or posedge rst) begin
        if (rst) begin
            buffer_reg <= 4'b0;
            buffer_flag <= 0;
        end else begin
            if (ready_i && !valid_i) begin
                buffer_reg <= data_i;
                buffer_flag <= 1;
            end else if (buffer_flag && valid_i && !ready_i) begin
                buffer_reg <= data_i;
            end
        end
    end

    // Connect buffer_reg to data_o when ready
    assign data_o = buffer_reg;
    assign valid_o = buffer_flag;
    assign ready_o = buffer_flag & ready_i;

endmodule

module register(
    input clk,
    input rst,

    input [3:0]data_in,
    input valid_in,
    output ready_out,
    output valid_out,
    output [3:0]data_out,
    input ready_in    
    );

    reg [3:0]data_reg;
    reg valid_reg;

    // Register logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_reg <= 4'b0;
            valid_reg <= 0;
        end else if (valid_in && ready_in) begin
            data_reg <= data_in;
            valid_reg <= 1;
        end else if (valid_reg) begin
            data_reg <= data_reg;
        end
    end

    // Output connections
    assign data_out = data_reg;
    assign valid_out = valid_reg;
    assign ready_out = valid_reg & ready_in;

endmodule

module skid_buffer(

    input  clk,
    input  reset ,

    input  [3:0]i_data,
    input  i_valid,
    output o_ready,

    output [3:0]o_data,
    output o_valid,
    input  i_ready

    );

    wire buffer_flag;
    wire buffer_reg;

    // Skid buffer logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            buffer_reg <= 4'b0;
            buffer_flag <= 0;
        end else begin
            if (i_ready && !i_valid) begin
                buffer_reg <= i_data;
                buffer_flag <= 1;
            end else if (buffer_flag && i_valid && !i_ready) begin
                buffer_reg <= i_data;
            end
        end
    end

    // Output connections
    assign o_data = buffer_reg;
    assign o_valid = buffer_flag;
    assign o_ready = buffer_flag & i_ready;

endmodule
