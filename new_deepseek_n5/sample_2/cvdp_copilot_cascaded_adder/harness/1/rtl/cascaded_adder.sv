parameter IN_DATA_WIDTH = 16;
parameter IN_DATA_NS = 4;

input wire clocks;
input wire rst_n;
input wire i_valid;
input bit_vector i_data [IN_DATA_WIDTH * IN_DATA_NS - 1:0];

output wire o_valid;
output bit_vector o_data [IN_DATA_WIDTH + $clog2(IN_DATA_NS) - 1:0];

reg accumulator;
reg [IN_DATA_WIDTH + $clog2(IN_DATA_NS) - 1:0] o_data_reg;

always clocked begin
    if (rst_n) begin
        o_valid = 0;
        o_data = 0;
        accumulator = 0;
        $continue;
    end
    #1;
    if (i_valid) begin
        accumulator = 0;
        for (int i = 0; i < IN_DATA_NS; i++) begin
            accumulator = accumulator + i_data[i * IN_DATA_WIDTH: (i * IN_DATA_WIDTH) + IN_DATA_WIDTH - 1];
            accumulator = accumulator << IN_DATA_WIDTH;
        end
        o_valid = 1;
        o_data = accumulator;
    end
    $end
end