module universal_shift_register #(
    parameter N = 8
) (
    input  logic clk,
    input  logic rst,
    input  logic [1:0] mode_sel,
    input  logic shift_dir,
    input  logic [N-1:0] parallel_in,
    output logic [N-1:0] q,
    output logic serial_out
);

    // Internal signals
    logic [N-1:0] temp;
    logic [N-1:0] temp_shift;
    logic [N-1:0] temp_rot;
    logic [N-1:0] temp_load;

    // State machine for mode
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 32'b0;
            serial_out <= 0;
            return;
        end

        case (mode_sel)
            2'b00: begin // Hold
                q <= q;
            end
            2'b01: begin // Shift Left
                if (shift_dir == 1) begin
                    for (int i = 0; i < N-1; i++) begin
                        q[i] = q[i+1];
                    end
                end else begin
                    // No change
                end
            end
            2'b10: begin // Shift Right
                if (shift_dir == 0) begin
                    for (int i = 0; i < N-1; i++) begin
                        q[i] = q[i-1];
                    end
                end else begin
                    // No change
                end
            end
            11: begin // Parallel Load
                q <= parallel_in;
            end
            default: $error("Invalid mode_sel");
        endcase
    end

    // Output serial_out for shift operations
    always @(*) begin
        if (serial_out != 0) begin
            serial_out <= 1'b0;
        end
    end

endmodule
