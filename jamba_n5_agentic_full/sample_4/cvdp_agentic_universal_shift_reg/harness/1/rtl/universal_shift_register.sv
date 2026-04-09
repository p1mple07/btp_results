`timescale 1ns / 1ps

module universal_shift_register #(
    parameter N = 8
) (
    input  logic clk,
    input  logic rst,
    input  logic [1:0] mode_sel,
    input  logic shift_dir,
    input  logic [N-1:0] serial_in,
    input  logic [N-1:0] parallel_in,
    output reg [N-1:0] q,
    output logic serial_out
);

    // Reset on clock edge
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 0;
            serial_out <= 1'b0;
        end else begin
            if (mode_sel == 2'b11) begin // Parallel Load
                q <= serial_in;
                serial_out <= 1'b0;
            end else if (mode_sel == 2'b10) begin // Shift Right
                q <= {q[N-1], serial_in};
                serial_out <= q[N-1];
            end else if (mode_sel == 2'b01) begin // Shift Left
                q <= {serial_in, q[N-1]};
                serial_out <= q[0];
            end else if (mode_sel == 2'b00) begin // Hold
                q <= serial_in;
                serial_out <= serial_out;
            end
        end
    end

endmodule
