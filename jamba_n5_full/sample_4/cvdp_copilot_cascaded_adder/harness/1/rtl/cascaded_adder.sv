module cascaded_adder (
    input  logic clk,
    input  logic rst_n,
    input  logic i_valid,
    input  logic [IN_DATA_WIDTH - 1 : 0] i_data,
    output logic o_valid,
    output reg [ (IN_DATA_WIDTH * IN_DATA_NS) - 1 : 0 ] o_data
);

    localparam INT_NUM_ELEMS = IN_DATA_NS;
    localparam INT_WIDTH = IN_DATA_WIDTH;

    reg [INT_WIDTH * INT_NUM_ELEMS - 1 : 0] acc;

    always @(posedge clk or posedge rst_n) begin
        if (!rst_n) begin
            o_valid <= 0;
            o_data <= 0;
            return;
        end
    end

    always @(posedge clk) begin
        if (i_valid) begin
            acc <= 0; // Reset accumulator
            for (int i = 0; i < INT_NUM_ELEMS; i++) begin
                acc = acc + i_data[i];
            end
            o_valid = 1;
            o_data = acc;
        end
    end

endmodule
