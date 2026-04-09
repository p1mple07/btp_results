module Bitstream(input  logic clk,rst_n,
                 input  logic enb,
                 input  logic rempty_in,
                 input  logic rinc_in,
                 input  logic [7:0] i_byte,
                 output logic o_bit,
                 output logic rempty_out,
                 output logic rinc_out);
    
    parameter IDLE  = 3'b000;
    parameter WaitR  = 3'b001;
    parameter Ready = 3'b010;
    logic [1:0] curr_state,next_state;

    logic [0:7] byte_buf;
    logic [3:0] bp;
    logic rde;

    //FSM block

    always_ff @(posedge clk) begin
        if(!rst_n) curr_state <= IDLE;
        else curr_state <= next_state;
    end

    always_comb begin
        case(curr_state)
            IDLE: next_state = Ready;
            IDLE:begin
                if(enb)begin
                    next_state = WaitR;
                    rempty_out = 1'b1;
                    rinc_out   = 1'b0;
                else begin
                    next_state = IDLE;
                    rempty_out = 1'b1;
                    rinc_out   = 1'b0;
                end
            end
            WaitR:begin
                if(rempty_in)begin
                    next_state = WaitR;
                    rempty_out = 1'b1;
                    rinc_out   = 1'b0;
                else begin
                    next_state = Ready;
                    rempty_out = 1'b1;
                    rinc_out   = 1'b1;
                end
            end
            Ready:begin
                if(rde)begin
                    if(rempty_in)begin
                        next_state = WaitR;
                        rempty_out = 1'b1;
                        rinc_out   = 1'b0;
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
            default:begin
                next_state = IDLE;
                rempty_out = 1'b1;
                rinc_out   = 1'b0;
            end
        endcase
    end

    always @(posedge clk) begin
        if(rinc_out) 
            byte_buf <= i_byte[7:1];
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