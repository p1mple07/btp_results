module Bitstream(input  logic clk,rst_n,
                 input  logic enb,
                 input  logic rempty_in,
                 input  logic rinc_in,
                 input  logic [7:0] i_byte,
                 output logic o_bit,
                 output logic rempty_out,
                 output logic rinc_out);

    parameter IDLE  = 3'b000;
    parameter WAITR  = 3'b001;
    parameter READY  = 3'b010;
    logic [1:0] curr_state,next_state;

    logic [8:0] byte_buf; // Changed width to 8-bit for proper bit range
    logic [3:0] bp;
    logic rde;

    //FSM block

    always_ff @(posedge clk) begin
        if(!rst_n) curr_state <= IDLE;
        else curr_state <= next_state;
    end

    always_comb begin
        case(curr_state)
            IDLE: next_state = READY;
            IDLE:begin
                if(enb)begin
                    next_state = WAITR;
                    rempty_out = 1'b1;
                    rinc_out   = 1'b0;
                end
                else begin
                    next_state = IDLE;
                    rempty_out = 1'b1;
                    rinc_out   = 1'b0;
                end
            end
            WAITR:begin
                if(rempty_in)begin
                    next_state = WAITR;
                    rempty_out = 1'b1;
                    rinc_out   = 1'b0;
                end
                else begin
                    next_state = READY;
                    rempty_out = 1'b1;
                    rinc_out   = 1'b1;
                end
            end
            READY:begin
                if(rde)begin
                    if(rempty_in)begin
                        next_state = WAITR;
                        rempty_out = 1'b1;
                        rinc_out   = 1'b0;
                    end
                    else begin
                        next_state = READY;
                        rempty_out = 1'b1;
                        rinc_out   = 1'b1;
                    end
                end
                else begin
                    next_state = READY;
                    rempty_out = 1'b0;
                    rinc_out   = 1'b0;
                end
            end
            default:begin
                next_state = IDLE;
                rempty_out = 1'b1;
                rinc_out   = 1'b0;
            end
        endcase
    end

    always @(posedge clk) begin
        if(rinc_out) 
           byte_buf <= i_byte; // Removed truncation
    end

    always @(posedge clk) begin
        if(rinc_out) 
            bp <= 4'b0;
        else 
            if(rinc_in & ~rempty_out) 
               bp <= bp + 1'b1;
    end

    //Other comb logic

    assign rde = bp[3];
    assign o_bit = byte_buf[bp];

endmodule
