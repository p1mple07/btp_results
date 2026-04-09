module barrel_shifter #(
    parameter data_width = 16,
    parameter shift_bits_width = 4
)(
    input [data_width-1:0] data_in,
    input [shift_bits_width-1:0] shift_bits,
    input [2:0] mode,
    input left_right,
    input [data_width-1:0] mask,
    input enable,
    input enable_parity,
    output reg [data_width-1:0] data_out,
    output reg parity_out,
    output reg error
);

    // Register to hold the previous data_out value when enable is 0
    reg [data_width-1:0] prev_data_out;

    always @(*) begin
        // If enable is 0, retain the previous value and disable parity calculation
        if (!enable) begin
            data_out = prev_data_out;
            parity_out = 0;
            error = 0;
            return;
        end

        // Error detection: if shift_bits is greater than or equal to data_width, invalid shift operation
        if (shift_bits >= data_width) begin
            data_out = {data_width{1'b0}};
            error = 1;
            parity_out = 0;
            prev_data_out = data_out;
            return;
        end

        // Evaluate operation based on mode
        case (mode)
            3'b000: begin // Logical Shift
                if (left_right)
                    data_out = data_in << shift_bits;
                else
                    data_out = data_in >> shift_bits;
            end
            3'b001: begin // Arithmetic Shift
                if (left_right)
                    data_out = data_in << shift_bits;
                else
                    data_out = $signed(data_in) >>> shift_bits;
            end
            3'b010: begin // Rotate
                if (left_right)
                    data_out = (data_in << shift_bits) | (data_in >> (data_width - shift_bits));
                else
                    data_out = (data_in >> shift_bits) | (data_in << (data_width - shift_bits));
            end
            3'b011: begin // Masked Shift
                if (left_right)
                    data_out = (data_in << shift_bits) & mask;
                else
                    data_out = (data_in >> shift_bits) & mask;
            end
            3'b100: begin // Arithmetic Addition/Subtraction
                if (left_right)
                    data_out = data_in + shift_bits;
                else
                    data_out = data_in - shift_bits;
            end
            3'b101: begin // Priority Encoder: find the position of the highest set bit in data_in
                integer i;
                data_out = 0;
                for (i = data_width-1; i >= 0; i = i-1) begin
                    if (data_in[i]) begin
                        data_out = i;
                        break;
                    end
                end
            end
            3'b110: begin // Modulo Arithmetic Addition/Subtraction
                if (left_right)
                    data_out = (data_in + shift_bits) % data_width;
                else
                    data_out = (data_in - shift_bits) % data_width;
            end
            3'b111: begin // Not supported
                data_out = {data_width{1'b0}};
                error = 1;
            end
            default: begin
                data_out = {data_width{1'b0}};
                error = 1;
            end
        endcase

        // Parity Calculation: if enable_parity is 1, compute XOR reduction of data_out bits
        if (enable_parity)
            parity_out = ^data_out;
        else
            parity_out = 0;

        // Store the computed data_out for retention when enable is 0
        prev_data_out = data_out;
    end

endmodule