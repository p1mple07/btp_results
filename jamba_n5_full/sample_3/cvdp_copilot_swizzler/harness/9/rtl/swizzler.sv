(* Interface: operation_mode *)
(* 3‑bit operation mode: 000, 001, 010, 011, 100, 101, 110, 111 *)
(* 3’b000 → Swizzle Only | 3’b001 → Passthrough | 3’b010 → Reverse | 3’b011 → Swap Halves | 3’b100 → Invert | 3’b101 → Circular Left Shift | 3’b110 → Circular Right Shift | 3’b111 → Default / Same as Swizzle *)

module swizzler #(
    parameter int N = 8
)(
    input clk,
    input reset,
    input  logic [N-1:0] data_in,
    input  logic [N*$clog2(N)-1:0] mapping_in,
    input  logic config_in,
    output logic [N-1:0] data_out
);

    localparam int M = $clog2(N);
    reg [M-1:0] map_idx;
    reg temp_error_flag;
    reg [N-1:0] swizzle_reg;
    reg [N-1:0] operation_reg;
    reg [N-1:0] error_reg;
    reg error_flag;

    (* Interface: operation_mode *)
    interface operation_mode(input [2:0] mode);

    always_ff @(posedge clk) begin
        if (reset) begin
            data_out <= '0;
            error_flag <= 1;
            swizzle_reg <= '0;
            operation_reg <= '0;
            error_reg <= '0;
        end
        else begin
            if (error_flag) begin
                data_out <= '0;
                error_flag <= 0;
                swizzle_reg <= '0;
                operation_reg <= '0;
                error_reg <= '0;
            end

            // Compute mapping indices
            map_idx = mapping_in;
            if (map_idx[i] >= N) begin
                temp_error_flag <= 1;
                data_out <= '0;
                error_flag <= 1;
                swizzle_reg <= '0;
                operation_reg <= '0;
                error_reg <= '0;
            end

            // Swizzle data
            if (config_in)
                data_out[i] <= data_in[map_idx[i]];
            else
                data_out[N-1-i] <= data_in[map_idx[i]];

            // Apply operation mode
            case (operation_mode)
                3'b000: data_out <= swizzle_reg;
                3'b001: data_out <= swizzle_reg;
                3'b010: data_out <= ~swizzle_reg[N-1]; // Invert high bit
                3'b011: data_out <= ~swizzle_reg[0];
                3'b100: data_out <= ~swizzle_reg[M-1];
                3'b101: data_out <= ~swizzle_reg[M-2];
                3'b110: data_out <= ~swizzle_reg[M-1];
                3'b111: data_out <= swizzle_reg;
                default: data_out <= swizzle_reg;
            endcase
        end
    end

endmodule
