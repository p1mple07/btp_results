module universal_shift_register #(
    parameter N = 8
) (
    input clk,
    input rst,
    input [1:0] mode_sel,
    input shift_dir,
    input serial_in,
    input parallel_in [N-1:0],
    output reg [N-1:0] q,
    output serial_out
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        q <= 0;
        serial_out <= 0;
        return;
    end

    case (mode_sel)
        2'b00: // Hold
            q <= {parallel_in[N-1], q[N-1:0]};
            serial_out <= 0;
        break;

        2'b01: // Shift Left
            if (shift_dir == 0) begin
                for (int i = 0; i < N-1; i++) begin
                    q[i+1] <= q[i];
                end
                q[N-1] <= serial_in;
            end
            else begin
                for (int i = 0; i < N-1; i++) begin
                    q[i] <= q[i+1];
                end
                q[0] <= serial_in;
            end
            serial_out <= q[N-1];
        break;

        2'b10: // Shift Right
            if (shift_dir == 1) begin
                for (int i = 0; i < N-1; i++) begin
                    q[i] <= q[i+1];
                end
                q[N-1] <= serial_in;
            end
            else begin
                for (int i = 0; i < N-1; i++) begin
                    q[i+1] <= q[i];
                end
                q[0] <= serial_in;
            end
            serial_out <= q[0];
        break;

        2'b11: // Parallel Load
            q <= parallel_in;
            serial_out <= 0;
        break;

    default:
        $error("Unsupported mode_sel: %b", mode_sel);
    endcase
end

always @(*) begin
    serial_out = q[N-1];
end

endmodule
