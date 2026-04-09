module universal_shift_register #(
    type = int
)(
    input clk,
    input rst,
    input [1:0] mode_sel,
    input shift_dir,
    input serial_in,
    input parallel_in,
    output reg [N-1:0] q,
    output serial_out
);

    localparam N = 8; // Default N
    localparam shift_dir_values = "01";

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_val <= "0";
            q <= "0";
            serial_out <= '0';
            shift_flag <= false;
        end else begin
            case (mode_sel)
                "00": begin
                    current_val <= "0";
                end
                "01": begin
                    next_val <= current_val;
                end
                "10": begin
                    next_val <= reverse(current_val);
                end
                "11": begin
                    if (shift_dir == '1') begin
                        next_val <= parallel_in;
                    else begin
                        next_val <= serial_in;
                    end
                end
                default: next_val <= current_val;
            endcase

            if next_val /= current_val and shift_flag == false begin
                shift_flag <= true;
            end
        end
    end

    process(current_val, shift_flag)
    begin
        if shift_flag && mode_sel == "11" and shift_dir == '1' then
            next_val <= reverse(current_val);
        elsif shift_flag && mode_sel == "10" and shift_dir == '1' then
            next_val <= reverse(current_val);
        else
            next_val <= current_val;
        end
    end

    process(current_val, next_val)
    begin
        serial_out <= next_val[N-1];
        q <= current_val;
    end

endmodule
