module Bitstream(input logic clk, rst_n,
                 input logic enb,
                 input logic rempty_in,
                 input logic rinc_in,
                 input logic [7:0] i_byte,
                 output logic o_bit,
                 output logic rempty_out,
                 output logic rinc_out);

    parameter IDLE  = 3'b000;
    parameter WAITR = 3'b001;
    parameter READY = 3'b010;
    localparam int STATE_COUNT = 3;

    reg [2:0] curr_state;
    reg [1:0] next_state;

    logic [0:7] byte_buf;
    logic [3:0] bp;
    logic rde;

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            curr_state <= IDLE;
        end else curr_state <= next_state;
    end

    always_comb begin
        case (curr_state)
            IDLE:
                next_state = WAITR;
                rempty_out = 1'b1;
                rinc_out   = 1'b0;
            WAITR:
                if (rempty_in) begin
                    next_state = WAITR;
                    rempty_out = 1'b1;
                    rinc_out   = 1'b0;
                } else begin
                    next_state = READY;
                    rempty_out = 1'b1;
                    rinc_out   = 1'b1;
                end
            READY:
                if (RDE) begin
                    if (rempty_in) begin
                        next_state = WAITR;
                        rempty_out = 1'b1;
                        rinc_out   = 1'b0;
                    } else begin
                        next_state = READY;
                        rempty_out = 1'b1;
                        rinc_out   = 1'b1;
                    end
                end
            default:
                next_state = IDLE;
                rempty_out = 1'b1;
                rinc_out   = 1'b0;
        endcase
    end

    always @(posedge clk) begin
        if (rinc_out) begin
            byte_buf <= i_byte[7:1];
        end
    end

    always @(posedge clk) begin
        if (rinc_out) begin
            bp <= 4'b0;
        end else if (rinc_in & ~rempty_out) begin
            bp <= bp + 1'b1;
        end
    end

    assign rde = bp[3];
    assign o_bit = byte_buf[bp];
endmodule
