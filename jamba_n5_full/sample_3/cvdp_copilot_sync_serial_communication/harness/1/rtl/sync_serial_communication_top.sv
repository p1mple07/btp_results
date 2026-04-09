module sync_serial_communication_top (
    input clk,
    input reset_n,
    input data_in [63:0],
    input sel [2:0],
    output reg serial_out,
    output reg done,
    output reg serial_clk
);

    // Internal state variables
    localparam constant integer NUM_BITS = 64;
    localparam constant integer DATA_WIDTH = 8;
    localparam constant integer BITS_PER_BLOCK = 64 / DATA_WIDTH;

    wire [NUM_BITS-1:0] serial_data;
    wire serial_clk;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            serial_out <= 1'b0;
            done <= 1'b0;
            serial_clk <= 1'b0;
        end else begin
            if (sel == 3'h0) begin
                serial_data <= 0;
                serial_clk <= 1'b0;
            end else if (sel == 3'h1) begin
                serial_data <= data_in[7:0];
                serial_clk <= 1'b1;
            end else if (sel == 3'h2) begin
                serial_data <= data_in[15:8];
                serial_clk <= 1'b1;
            end else if (sel == 3'h3) begin
                serial_data <= data_in[31:16];
                serial_clk <= 1'b1;
            end else if (sel == 3'h4) begin
                serial_data <= data_in[63:32];
                serial_clk <= 1'b1;
            end else begin
                serial_data <= 0;
                serial_clk <= 1'b0;
            end

            serial_out <= serial_data;
            done <= 1'b1;
        end
    end

endmodule

module tx_block (
    input clk,
    input reset_n,
    input data_in,
    input sel,
    output reg serial_out,
    output reg done,
    output reg serial_clk
);

    // Implementation for tx_block
    assign serial_out = data_in[63:0];
    assign done = 1'b1;
    assign serial_clk = 1'b1;

endmodule

module rx_block (
    input clk,
    input reset_n,
    input data_in,
    input sel,
    output reg data_out,
    output reg done,
    output reg serial_clk
);

    // Implementation for rx_block
    assign data_out = serial_data;
    assign done = 1'b1;
    assign serial_clk = 1'b1;

endmodule

module top;
    input clk,
    input reset_n,
    input data_in [63:0],
    input sel [2:0],
    output reg serial_out,
    output reg done,
    output reg serial_clk;

    tx_block tx (
        .clk(clk),
        .reset_n(reset_n),
        .data_in(data_in),
        .sel(sel),
        .serial_out(serial_out),
        .done(done),
        .serial_clk(serial_clk)
    );

    rx_block rx (
        .clk(clk),
        .reset_n(reset_n),
        .data_in(serial_out),
        .sel(sel),
        .data_out(data_out),
        .done(done),
        .serial_clk(serial_clk)
    );

endmodule
