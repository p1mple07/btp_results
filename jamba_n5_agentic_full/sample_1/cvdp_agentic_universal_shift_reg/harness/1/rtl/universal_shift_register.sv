module universal_shift_register #(
    parameter N = 8
)(
    input logic clk,
    input logic rst,
    input logic [1:0] mode_sel,
    input logic shift_dir,
    input logic serial_in,
    input logic [N-1:0] parallel_in,
    output logic [N-1:0] q,
    output logic serial_out
);

    localparam shift_count = N;
    logic [N-1:0] data;
    logic [N-1:0] temp;
    logic shifted;
    always @(posedge clk or posedge rst) begin
        if (rst)
            q <= {shift_count{1'b0}};
            serial_out <= 1'b0;
            return;
        end

        if (mode_sel == 2'b00) begin
            // Hold
            q <= data;
            serial_out <= serial_out;
        end
        else if (mode_sel == 2'b01) begin
            // Shift Left
            if (shift_dir == 1'b0) begin
                // Left shift: shift in from serial_in, shift out from MSB
                for (int i = 0; i < shift_count; i++) begin
                    temp[i] <= data[(i+1) mod shift_count];
                end
                data[0] <= serial_in;
                q <= temp;
            end
            else begin
                // Left shift: shift out from LSB
                for (int i = 0; i < shift_count; i++) begin
                    data[(i+1) mod shift_count] <= data[i];
                end
                data[0] <= serial_in;
                q <= data;
            end
            serial_out <= serial_out;
        end
        else if (mode_sel == 2'b10) begin
            // Shift Right
            if (shift_dir == 1'b1) begin
                // Right shift: shift in from serial_in, shift out from LSB
                for (int i = 0; i < shift_count; i++) begin
                    data[(i+1) mod shift_count] <= data[i];
                end
                data[shift_count-1] <= serial_in;
                q <= data;
            end
            else begin
                // Right shift: shift out from MSB
                for (int i = 0; i < shift_count; i++) begin
                    data[(i+1) mod shift_count] <= data[i];
                end
                data[shift_count-1] <= serial_in;
                q <= data;
            end
            serial_out <= serial_out;
        end
        else if (mode_sel == 2'b11) begin
            // Parallel Load
            q <= parallel_in;
            serial_out <= serial_out;
        end
    end

endmodule
