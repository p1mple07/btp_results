module Bitstream(
    input  logic clk,
    input  logic rst_n,
    input  logic enb,
    input  logic rempty_in,
    input  logic rinc_in,
    input  logic [7:0] i_byte,
    output logic o_bit,
    output logic rempty_out,
    output logic rinc_out
);

    parameter IDLE  = 3'b000;
    parameter WaitR = 3'b001;
    parameter Ready = 3'b010;

    logic [1:0] curr_state, next_state;
    logic [7:0] byte_buf, bp;
    logic rde;

    // FSM block
    always_ff @(posedge clk) begin
        if (!rst_n) curr_state <= IDLE;
        else curr_state <= next_state;
    end

    always_comb begin
        case (curr_state)
            IDLE: begin
                next_state = Ready;
                rempty_out = 1'b1;
                rinc_out   = 1'b0;
            end
            WaitR: begin
                if (rempty_in) begin
                    next_state = WaitR;
                    rempty_out = 1'b1;
                    rinc_out   = 1'b0;
                end
                else begin
                    next_state = Ready;
                    rempty_out = 1'b1;
                    rinc_out   = 1'b1;
                end
            end
            Ready: begin
                if (rde) begin
                    if (rempty_in) begin
                        next_state = WaitR;
                        rempty_out = 1'b1;
                        rinc_out   = 1'b0;
                    end
                    else begin
                        next_state = Ready;
                        rempty_out = 1'b1;
                        rinc_out   = 1'b1;
                    end
                end
                else begin
                    next_state = Ready;
                    rempty_out = 1'b0;
                    rinc_out   = 1'b0;
                end
            end
        endcase
    end

    always @(posedge clk) begin
        if (rinc_out) begin
            byte_buf <= i_byte[7:0];
        end

        if (rinc_out) begin
            bp <= 4'b0000; // Initialize bp to zero when rinc_out goes high
        end
        else begin
            if (rinc_in & ~rempty_out) begin
                bp <= bp + 1'b1;
            end
        end
    end

    assign rde = bp[3];
    assign o_bit = byte_buf[bp];

endmodule
