module sync_lifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 3
)(
    input  logic clk,
    input  logic reset,
    input  logic write_en,
    input  logic read_en,
    input  logic data_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic empty,
    output logic full
);

    // Internal variables
    reg [ADDR_WIDTH-1:0] idx;
    reg mem [0: (2**ADDR_WIDTH)-1];
    logic full_mem;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            idx <= 0;
            mem[0] <= 0;
            full_mem <= 0;
        end else begin
            if (write_en) begin
                if (!full_mem) begin
                    mem[idx] <= data_in;
                    idx <= idx + 1;
                    full_mem <= 1;
                end
            end
            if (read_en) begin
                if (idx >= 0) begin
                    data_out <= mem[idx];
                    full_mem <= 0;
                end else begin
                    data_out <= 1'b0;
                end
            end
        end
    end

endmodule
