module data_width_converter(
    input wire clock,
    input wire reset,
    input wire [31:0] data_in,
    input wire data_valid,
    output wire [127:0] o_data_out,
    output wire o_data_out_valid
);

    wire [31:0] data_reg1,
    wire [31:0] data_reg2,
    wire [31:0] data_reg3,
    wire [31:0] data_reg4,
    wire [127:0] shifted_data,
    wire [127:0] o_data_out,
    wire [3:0] state,
    wire [3:0] count;

    // State machine
    always_comb begin
        if (reset) begin
            data_reg1 = 0;
            data_reg2 = 0;
            data_reg3 = 0;
            data_reg4 = 0;
            shifted_data = 0;
            o_data_out = 0;
            o_data_out_valid = 0;
            state = 0;
        end else if (data_valid) begin
            if (state == 0) begin
                data_reg1 = data_in;
                state = 1;
            end else if (state == 1) begin
                data_reg2 = data_in;
                state = 2;
            end else if (state == 2) begin
                data_reg3 = data_in;
                state = 3;
            end else if (state == 3) begin
                data_reg4 = data_in;
                state = 0;
                o_data_out_valid = 1;
                count = 0;
            end
        end
    end

    // Shift data
    always clock positive edge begin
        if (state == 0) begin
            shifted_data = data_reg1 << 32;
            shifted_data = (shifted_data << 32) | data_reg2;
            shifted_data = (shifted_data << 32) | data_reg3;
            shifted_data = (shifted_data << 32) | data_reg4;
        end else if (state == 1) begin
            shifted_data = data_reg2 << 32;
            shifted_data = (shifted_data << 32) | data_reg3;
            shifted_data = (shifted_data << 32) | data_reg4;
        end else if (state == 2) begin
            shifted_data = data_reg3 << 32;
            shifted_data = (shifted_data << 32) | data_reg4;
        end else if (state == 3) begin
            o_data_out = shifted_data;
            o_data_out_valid = 1;
            state = 0;
            count = 0;
        end
    end

    // Reset counter
    always clock positive edge begin
        if (reset) begin
            state = 0;
            o_data_out = 0;
            o_data_out_valid = 0;
        end else if (o_data_out_valid) begin
            count = (count + 1) % 4;
        end
    end
endmodule