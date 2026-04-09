`timescale 1ns/1ps

module nbit_swizzling #(
    parameter DATA_WIDTH = 64
) (
    input  logic [DATA_WIDTH-1:0] data_in,
    input  logic [1:0] sel,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic [DATA_WIDTH-1:0] gray_out
);

    // Helper function for Gray code conversion
    function logic [DATA_WIDTH-1:0] gray_code(input logic [DATA_WIDTH-1:0] value);
        logic [DATA_WIDTH-1:0] gray;
        gray = value ^ {VALUE_LENGTH-1:1};
        return gray;
    endfunction

    // Case 1: sel == 2'b00: Reverse entire data
    always_comb begin
        if (sel == 2'b00) begin
            data_out = data_in[::-1]; // reverse array
            gray_out = gray_code(data_out);
        end
        else begin
            data_out = data_in;
            gray_out = data_out;
        end
    end

    // Case 2: sel == 2'b01: Half-Swizzle
    always_comb begin
        if (sel == 2'b01) begin
            logic [DATA_WIDTH/2 - 1:0] low_half, high_half;
            split_data(data_in, low_half, high_half);
            logic [DATA_WIDTH/2 - 1:0] reversed_low, reversed_high;
            reverse_array(low_half, reversed_low);
            reverse_array(high_half, reversed_high);
            data_out = reversed_low[DATA_WIDTH/2 : 0] + reversed_high[DATA_WIDTH/2 : 0];
            gray_out = gray_code(data_out);
        end
        else begin
            data_out = data_in;
            gray_out = data_out;
        end
    end

    // Case 3: sel == 2'b10: Quarter-Swizzle
    always_comb begin
        if (sel == 2'b10) begin
            logic [DATA_WIDTH/4 - 1:0] quarter1, quarter2, quarter3, quarter4;
            split_data(data_in, quarter1, quarter2, quarter3, quarter4);
            logic [DATA_WIDTH/4 - 1:0] reversed_quarter1, reversed_quarter2, reversed_quarter3, reversed_quarter4;
            reverse_array(quarter1, reversed_quarter1);
            reverse_array(quarter2, reversed_quarter2);
            reverse_array(quarter3, reversed_quarter3);
            reverse_array(quarter4, reversed_quarter4);
            data_out = quarter1[DATA_WIDTH/4 : 0] + quarter2[DATA_WIDTH/4 : 0] + quarter3[DATA_WIDTH/4 : 0] + quarter4[DATA_WIDTH/4 : 0];
            gray_out = gray_code(data_out);
        end
        else begin
            data_out = data_in;
            gray_out = data_out;
        end
    end

    // Case 4: sel == 2'b11: Eighth-Swizzle
    always_comb begin
        if (sel == 2'b11) begin
            logic [DATA_WIDTH/8 - 1:0] eighth1, eighth2, eighth3, eighth4, eighth5, eighth6, eighth7, eighth8;
            split_data(data_in, eighth1, eighth2, eighth3, eighth4, eighth5, eighth6, eighth7, eighth8);
            logic [DATA_WIDTH/8 - 1:0] reversed_eighth1, reversed_eighth2, reversed_eighth3, reversed_eighth4, reversed_eighth5, reversed_eighth6, reversed_eighth7, reversed_eighth8;
            reverse_array(eighth1, reversed_eighth1);
            reverse_array(eighth2, reversed_eighth2);
            reverse_array(eighth3, reversed_eighth3);
            reverse_array(eighth4, reversed_eighth4);
            reverse_array(eighth5, reversed_eighth5);
            reverse_array(eighth6, reversed_eighth6);
            reverse_array(eighth7, reversed_eighth7);
            reverse_array(eighth8, reversed_eighth8);
            data_out = eighth1[DATA_WIDTH/8 : 0] + eighth2[DATA_WIDTH/8 : 0] + eighth3[DATA_WIDTH/8 : 0] + eighth4[DATA_WIDTH/8 : 0] + eighth5[DATA_WIDTH/8 : 0] + eighth6[DATA_WIDTH/8 : 0] + eighth7[DATA_WIDTH/8 : 0] + eighth8[DATA_WIDTH/8 : 0];
            gray_out = gray_code(data_out);
        end
        else begin
            data_out = data_in;
            gray_out = data_out;
        end
    end

endmodule

// Gray code conversion helper
logic [DATA_WIDTH-1:0] gray_code(input logic [DATA_WIDTH-1:0] value) {
    logic [DATA_WIDTH-1:0] gray;
    gray = value ^ {VALUE_LENGTH-1:1};
    return gray;
}
