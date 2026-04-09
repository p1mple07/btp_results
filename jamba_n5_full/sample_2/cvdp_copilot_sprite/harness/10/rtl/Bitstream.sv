module Bitstream(input logic clk, rst_n,
                 input  logic enb,
                 input  logic rempty_in,
                 input  logic rinc_in,
                 input  logic [7:0] i_byte,
                 output logic o_bit,
                 output logic rempty_out,
                 output logic rinc_out);

    parameter IDLE  = 3'b000;
    parameter WaitR = 3'b001;
    parameter Ready = 3'b010;
    logic [1:0] curr_state, next_state;

    logic [0:7] byte_buf;
    logic [3:0] bp;
    logic rde;

    always_ff @(posedge clk) begin
        if (!rst_n) curr_state <= IDLE;
        else curr_state <= next_state;
    end

    always_comb begin
        case (curr_state)
            IDLE:   next_state = Ready;
            WAITR:  begin
                if (rempty_in) next_state = WaitR;
                else      next_state = Ready;
            end
            READY:  begin
                if (rde) begin
                    if (rempty_in) next_state = WaitR;
                    else      next_state = Ready;
                end
                default: next_state = IDLE;
            end
        endcase
    end

    always @(posedge clk) begin
        if (rinc_out)  o_bit = byte_buf[bp];
        else if (rinc_in & ~rempty_out) bp <= bp + 1'b1;
    end

    assign o_bit = byte_buf[bp];
endmodule
