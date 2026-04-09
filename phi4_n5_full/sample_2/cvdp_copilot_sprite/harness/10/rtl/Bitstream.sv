module Bitstream(input  logic clk, rst_n,
                 input  logic enb,
                 input  logic rempty_in,
                 input  logic rinc_in,
                 input  logic [7:0] i_byte,
                 output logic o_bit,
                 output logic rempty_out,
                 output logic rinc_out);
    
    // Define states using a consistent 3-bit width
    parameter IDLE  = 3'b000;
    parameter WaitR = 3'b001;
    parameter Ready = 3'b010;
    
    // Use a 3-bit state register to match the parameter width
    logic [2:0] curr_state, next_state;
    
    // Correct the byte buffer declaration to use the proper bit order and full width
    logic [7:0] byte_buf;
    
    // Reduce bp width to 3 bits (indices 0 to 7) and update related logic
    logic [2:0] bp;
    logic rde;

    // FSM state register with asynchronous reset
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end

    // FSM next state logic with non-overlapping case conditions
    always_comb begin
        case (curr_state)
            IDLE: begin
                if (enb)
                    next_state = WaitR;
                else
                    next_state = IDLE;
                rempty_out = 1'b1;
                rinc_out   = 1'b0;
            end

            WaitR: begin
                if (rempty_in) begin
                    next_state = WaitR;
                    rempty_out = 1'b1;
                    rinc_out   = 1'b0;
                end else begin
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
                    end else begin
                        next_state = Ready;
                        rempty_out = 1'b1;
                        rinc_out   = 1'b1;
                    end
                end else begin
                    next_state = Ready;
                    rempty_out = 1'b0;
                    rinc_out   = 1'b0;
                end
            end

            default: begin
                next_state = IDLE;
                rempty_out = 1'b1;
                rinc_out   = 1'b0;
            end
        endcase
    end

    // Update the byte buffer with the full 8-bit value (avoiding truncation)
    always_ff @(posedge clk) begin
        if (rinc_out)
            byte_buf <= i_byte;
    end

    // Update the bit position counter. When rinc_out is high, reset bp; otherwise, increment bp if allowed.
    always_ff @(posedge clk) begin
        if (rinc_out)
            bp <= 3'b0;
        else if (rinc_in & ~rempty_out)
            bp <= bp + 1'b1;
    end

    // Generate the ready signal from the MSB of bp and extract the current bit from byte_buf
    assign rde = bp[2];
    assign o_bit = byte_buf[bp];

endmodule