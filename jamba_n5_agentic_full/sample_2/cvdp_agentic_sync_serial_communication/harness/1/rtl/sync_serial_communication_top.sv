module sync_serial_communication_tx_rx (
    input logic clk,
    input logic reset_n,
    input logic [2:0] sel,
    input logic [63:0] data_in,
    output logic [63:0] data_out,
    output logic done,
    output logic [63:0] gray_out
);

// --- Transmitter ---------------------------------------------------------
module tx_block (
    input logic clk,
    input logic reset_n,
    input logic [2:0] sel,
    input logic [63:0] data_in,
    output logic [63:0] serial_out,
    output logic done,
    output logic [63:0] serial_clk
);

    always @(posedge clk or posedge reset_n) begin
        if (reset_n) begin
            serial_out <= 64'b0;
            data_out <= 64'b0;
            serial_clk <= 1'b0;
        end else begin
            // Transmit logic here
            serial_out <= data_in[63];
            serial_clk <= serial_clk;
            done <= 1'b0;
        end
    end

endmodule

// --- Receiver ------------------------------------------------------------
module rx_block (
    input logic clk,
    input logic reset_n,
    input logic [63:0] data_in,
    output logic [63:0] data_out
);

    always @(posedge clk or posedge reset_n) begin
        if (reset_n) begin
            data_out <= 64'b0;
        end else begin
            data_out <= serial_out;
        end
    end

endmodule

// --- Binary‑to‑Gray conversion ------------------------------------------
module binary_to_gray_conversion (
    input logic data_out,
    output logic [63:0] gray_out
);

    always @(*) begin
        gray_out = {64{data_out[62]}} ^ {63{data_out[63]}};
    end

endmodule

// --- Top‑level interface -------------------------------------------------
module top (
    input logic clk,
    input logic reset_n,
    input logic [2:0] sel,
    input logic [63:0] data_in,
    output logic [63:0] data_out,
    output logic done,
    output logic [63:0] gray_out
);

    tx_block uut (.clk(clk), .reset_n(reset_n), .sel(sel), .data_in(data_in), .serial_out(serial_out), .done(done), .serial_clk(serial_clk));
    rx_block urx (.clk(clk), .reset_n(reset_n), .data_in(serial_out), .data_out(data_out));
    binary_to_gray_conversion ubg (.data_in(data_out), .gray_out(gray_out));

endmodule
