// Module universal_shift_register #(
    parameter N = 8                     // Width of the register
)#(
    input  wire [N-1:0] clock,           // Clock signal
    input  wire rst,                   // Synchronous reset
    input  wire en,                    // Enable control
    input  wire [1:0] bitwise_op,       // Bitwise operation selector
    input  wire [2:0] op_sel,           // Mode selector [3-bit]
    input  wire [N-1:0] parallel_in,     // Parallel input for load
    output reg [N-1:0] q,              // Register storage (for SIPO, PISO)
    output wire [N-1:0] siso_out,       // Serial output (for PISO)
    output wire [N-1:0] serial_out,      // Serial output for SIPO
    output reg [N-1:0] piso_out,        // Parallel output (for PIPO)
    output reg [N-1:0] sipo_out,        // Serial output for SIPO
    output wire overflow,               // Overflow indicator for shifts and rotates
    output wire parity_out,             // Parity check output
    output wire zero_flag,              // Zero flag
    output wire [N-1:0] expected_q,     // Expected output (for SIPO/SISO)
    output wire [N-1:0] expected_serial_out, // Expected output for PISO, SISO
    output wire serial_in,              // Serial input for SISO
    output wire shift_dir                  // 0 = Shift Right, 1 = Shift Left
);

    always_comb @(posedge clock or posedge rst) begin
        if (rst) begin
            q <= 0; 
            serial_out <= 0;
            serial_in  <= 0;
            expected_q         = 0;
            expected_overflow   = 0;
            expected_siso_out   = 0;
            expected_parity_out = 0;
            expected_zero_flag = 1;
        end else begin
            case (op_sel)
                000: begin
                    // Hold operation
                    q <= q;
                    serial_out = (shift_dir == 0) ? q[N-1] : q[0];
                end
                001: begin
                    // Logical Shift
                    case (shift_dir)
                        0: begin
                            // Right shift
                            if (N > 1) {
                                q <= {serial_in, q[N-1:1]};
                            } else {
                                q <= serial_in;
                            }
                            serial_out = q[0];
                        end
                        1: begin
                            // Left shift
                            if (N > 1) {
                                q <= {q[N-2:0], 0};
                            } else {
                                q <= q;
                            }
                            serial_out = q[N-1];
                        end
                    end
                    expected_overflow = (shift_dir == 0) ? q[0] : 0;
                end
                010: begin
                    // Rotate
                    case (shift_dir)
                        0: begin
                            // Right rotate
                            temp = q[N-1];
                            q <= {q[N-2:0], temp};
                            serial_out = q[0];
                        end
                        1: begin
                            // Left rotate
                            temp = q[0];
                            q <= {temp, q[N-1:1]};
                            serial_out = q[N-1];
                        end
                    end
                    expected_overflow = shift_dir ? q[0] : q[N-1];
                end
                011: begin
                    // Parallel Load
                    q <= parallel_in;
                    serial_out = shift_dir ? parallel_in[N-1] : parallel_in[0];
                end
                100: begin
                    // Arithmetic Shift
                    case (shift_dir)
                        0: begin
                            // Right shift with sign extension
                            q <= { serial_in, q[N-1:1] };
                            serial_out = q[0];
                            overflow = q[0];
                        end
                        1: begin
                            // Left shift with zero extension
                            q <= { q[N-2:0], 0 };
                            serial_out = q[N-1];
                            overflow = 0;
                        end
                    end
                end
                101: begin
                    // Bitwise Operations
                    case (bitwise_op)
                        0: begin // AND
                            q <= { (q[i] & parallel_in[i]) for i in 0:N-1 };
                            overflow = 1'b0;
                        end
                        1: begin // OR
                            q <= { (q[i] | parallel_in[i]) for i in 0:N-1 };
                            overflow = 1'b0;
                        end
                        2: begin // XOR
                            q <= { (q[i] ^ parallel_in[i]) for i in 0:N-1 };
                            overflow = 1'b0;
                        end
                        3: begin // XNOR
                            q <= { (~q[i] & ~parallel_in[i]) for i in 0:N-1 };
                            overflow = 1'b0;
                        end
                    end
                end
                110: begin
                    // Bit Reversal
                    q <= reverse_bits(parallel_in);
                    serial_out = shift_dir ? q[N-1] : q[0];
                end
                111: begin
                    // Bitwise Inversion
                    q <= {~q[i] for i in 0:N-1};
                    overflow = 1'b0;
                end
            end
        end

        // Update Expected Outputs
        expected_q = q;
        expected_serial_out = shift_dir ? q[N-1] : q[0];
        expected_parity_out = parity(q);
        expected_zero_flag = (q == 0);
    end

    assign parity_out = parity(q); // Parity calculation

    wire [N-1:0] expected_serial_out;
    assign expected_serial_out = shift_dir ? q[N-1] : q[0];

    wire [N-1:0] serial_out;
    wire [N-1:0] expected_q;
    wire [N-1:0] expected_serial_out;

    // Additional helper function declaration
    function [N-1:0] reverse_bits(input [N-1:0] val);
        integer j;
        begin
            for (j = 0; j < N; j = j + 1) begin
                reversed[j] = val[N-1-j];
            end
        end
    endfunction