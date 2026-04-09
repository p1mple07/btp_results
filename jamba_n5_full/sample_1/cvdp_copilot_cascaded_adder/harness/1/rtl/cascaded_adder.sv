module cascaded_adder #(
    parameter IN_DATA_WIDTH = 16,
    parameter IN_DATA_NS   = 4
)(
    input  logic clk,
    input  logic rst_n,
    input  logic i_valid,
    input  logic [IN_DATA_WIDTH-1:0] i_data,
    output logic o_valid,
    output logic [IN_DATA_WIDTH*IN_DATA_NS-1:0] o_data
);

    // Synchronise the asynchronous reset to the positive clock edge
    always @(posedge clk) begin
        if (!rst_n) begin
            o_valid <= 0;
            o_data <= 0;
        end else begin
            o_valid <= 1;
            o_data <= o_data_reg;
        end
    end

    // Accumulator register
    reg [IN_DATA_WIDTH*IN_DATA_NS-1:0] acc;

    // Main processing loop
    always @(posedge clk) begin
        if (!rst_n) begin
            acc <= 0;
        end else begin
            acc <= acc + i_data;
        end
        o_valid <= 1;
        o_data <= acc;
    end

endmodule
