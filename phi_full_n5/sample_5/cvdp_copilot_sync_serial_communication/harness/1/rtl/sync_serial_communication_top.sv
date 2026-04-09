module sync_serial_communication_top (
    input clk,
    input reset_n,
    input [63:0] data_in,
    input [2:0] sel,
    output reg [63:0] data_out,
    output reg done
);

    reg [1:0] tx_sel;
    reg [1:0] rx_sel;
    reg [1:0] current_sel;

    always @(posedge clk or posedge reset_n) begin
        if (reset_n) begin
            tx_sel <= 3'd0;
            rx_sel <= 3'd0;
            current_sel <= 3'd0;
        end else begin
            current_sel <= sel;
            tx_sel <= sel;
            rx_sel <= sel;
        end
    end

    tx_block tx_inst(.clk(clk), .reset_n(reset_n), .data_in(data_in), .sel(tx_sel), .serial_out(serial_out), .serial_clk(serial_clk));
    rx_block rx_inst(.clk(clk), .reset_n(reset_n), .data_in(serial_in), .sel(rx_sel), .serial_clk(serial_clk), .data_out(data_out), .done(done));

    assign serial_out = tx_inst.serial_out;
    assign serial_clk = tx_inst.serial_clk & rx_inst.serial_clk;

    always @(posedge clk or posedge reset_n) begin
        if (reset_n) begin
            done <= 1'b0;
        end else begin
            if (tx_sel == rx_sel) begin
                done <= 1'b1;
                data_out <= rx_inst.data_out;
            end else begin
                done <= 1'b0;
                data_out <= 64'h0;
            end
        end
    end

endmodule
