module Bitstream(
    input  logic clk, rst_n, enb, rempty_in, rinc_in,
    input  logic [7:0] i_byte,
    output logic o_bit,
    output logic rempty_out,
    output logic rinc_out
);

    // Define FSM states using 3-bit values
    parameter IDLE  = 3'b000,
              WaitR = 3'b001,
              Ready = 3'b010;

    // Use 3-bit state registers to match the state parameters
    logic [2:0] curr_state, next_state;

    // Correct bit order for the byte buffer (MSB first)
    logic [7:0] byte_buf;

    // Use a 3-bit counter for the bit position (0 to 7)
    logic [2:0] bp;

    // Flag to indicate that all 8 bits have been output
    logic rde;

    // FSM sequential block
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end

    // Combinational logic for next state and output signals
    always_comb begin
        unique case (curr_state)
            IDLE: begin
                // In IDLE, wait for enable signal to load the next byte
                if (enb) begin
                    next_state = WaitR;
                    rempty_out = 1'b1;
                    rinc_out   = 1'b0;
                end
                else begin
                    next_state = IDLE;
                    rempty_out = 1'b1;
                    rinc_out   = 1'b0;
                end
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
                // When all bits have been output, check if receiver is ready
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

            default: begin
                next_state = IDLE;
                rempty_out = 1'b1;
                rinc_out   = 1'b0;
            end
        endcase
    end

    // Load the full incoming byte when rinc_out is asserted
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            byte_buf <= 8'b0;
        else if (rinc_out)
            byte_buf <= i_byte;
    end

    // Increment the bit position counter when appropriate
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            bp <= 3'b0;
        else if (rinc_out)
            bp <= 3'b0;
        else if (rinc_in && ~rempty_out)
            bp <= bp + 1;
    end

    // rde is true when bp reaches 7 (all 8 bits have been output)
    assign rde = (bp == 3'b111);

    // Output the current bit from the byte buffer
    assign o_bit = byte_buf[bp];

endmodule