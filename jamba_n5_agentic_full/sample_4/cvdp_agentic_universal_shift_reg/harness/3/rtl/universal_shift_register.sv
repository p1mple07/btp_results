`timescale 1ns / 1ps

module universal_shift_register #(
    parameter N = 8
)(
    input wire clk,
    input wire rst,
    input wire [1:0] mode_sel,
    input wire shift_dir,
    input wire serial_in,
    input wire [N-1:0] parallel_in,
    output reg [N-1:0] q,
    output wire serial_out,
    output wire msb_out,
    output wire lsb_out,
    output wire overflow,
    output wire parity_out,
    output wire zero_flag
);

    // Reset testbench
    task reset_register();
        begin
            rst = 1;
            en  = 1;   // Keep enable high unless we want to test disabled behavior
            expected_q         = {N{1'b0}};
            expected_overflow  = 1'b0;
            expected_serial_out= 1'b0;
            expected_msb_out   = 1'b0;
            expected_lsb_out   = 1'b0;
            expected_parity    = 1'b0;
            expected_zero_flag = 1'b1;
            op_sel = 3'd0;
            shift_dir = 1'b0;    
            bitwise_op =2'd0;   
            serial_in = 1'b0;
            parallel_in = {N{1'b0}};
            @(posedge clk);
            rst = 0;
            @(posedge clk);
            $display("[RESET] DUT has been reset.");
        end
    endtask

    // Clock generation
    always #5 clk = ~clk;

    // DUT core
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 0;
        end else begin
            case (mode_sel)
                2'b00: begin
                    q <= q;
                end
                2'b01: begin
                    if (shift_dir == 0) begin
                        q <= {serial_in, q[N-1:1]};
                    end else begin
                        q <= {q[N-2:0], serial_in};
                    end
                end
                2'b10: begin
                    if (shift_dir == 0) begin
                        q <= {q[0], q[N-1:1]};
                    end else begin
                        q <= {q[N-2:0], q[N-1]};
                    end
                end
                2'b11: begin
                    q <= parallel_in;
                end
                2'b100: begin  // Arithmetic shift right
                    if (shift_dir == 1) begin
                        q <= {q[0], q[N-1:1]};
                    end else begin
                        q <= {q[N-2:0], q[N-1]};
                    end
                end
                2'b101: begin  // Bitwise AND
                    q <= {parallel_in, q};
                end
                2'b110: begin  // Bit reversal
                    q <= reverse_bits(q);
                end
                2'b111: begin  // Bitwise inversion
                    q <= {~q[0], ~q[1], ..., ~q[N-1]};
                end
                default: q <= q;
            endcase
        end
    end

    assign serial_out = (shift_dir == 0) ? q[0] : q[N-1];

    // Compute auxiliary signals
    assign msb_out = (N > 0) && (q[N-1] == 1'b1);
    assign lsb_out = (N > 0) && (q[0] == 1'b0);
    assign overflow = (q[N-1] == 1'b1 && rst != 0);
    assign parity_out = (N == 0) ? 1'b0 : ~({{N{-1}ones} {N{-1}ones}}) & ({{N{-1}ones} {N{-1}ones}});
    assign zero_flag = (q == {N{1'b0}});

endmodule
