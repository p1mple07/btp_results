module addressing the following lint issues:
   - Corrected state register width (from [1:0] to [2:0]) to match 3‐bit parameters.
   - Changed byte buffer declaration to [7:0] (natural order) and removed truncated assignments.
   - Removed overlapping case conditions in the FSM.
   - Eliminated unused signal “bp” by introducing a proper 3‐bit counter “bit_cnt” for 8 bits.
   - Ensured that all signals are assigned in sequential blocks to avoid latch inference.
*/

module Bitstream(
    input  logic         clk,
    input  logic         rst_n,
    input  logic         enb,
    input  logic         rempty_in,
    input  logic         rinc_in,
    input  logic [7:0]   i_byte,
    output logic         o_bit,
    output logic         rempty_out,
    output logic         rinc_out
);

    // Define FSM states with consistent 3-bit width
    parameter IDLE  = 3'b000;
    parameter WaitR = 3'b001;
    parameter Ready = 3'b010;

    // State registers now 3 bits wide to match parameters
    logic [2:0] curr_state, next_state;

    // Buffer to hold the byte. Use natural bit order [7:0]
    logic [7:0] byte_buf;

    // Counter to track bit extraction (0 to 7 for 8 bits)
    logic [2:0] bit_cnt;

    // FSM sequential block
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end

    // FSM combinational next state logic
    always_comb begin
        // Default assignments
        next_state   = curr_state;
        rempty_out   = 1'b1;
        rinc_out     = 1'b0;

        case (curr_state)
            IDLE: begin
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
                if (bit_cnt == 7) begin
                    // Last bit transmitted, move to WaitR for new byte
                    next_state = WaitR;
                    rempty_out = 1'b1;
                    rinc_out   = 1'b0;
                end
                else begin
                    next_state = Ready;
                    rempty_out = 1'b0;
                    rinc_out   = 1'b1;
                end
            end
            default: begin
                next_state = IDLE;
                rempty_out = 1'b1;
                rinc_out   = 1'b0;
            end
        endcase
    end

    // Sequential logic for byte buffering and shifting
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            byte_buf <= 8'b0;
            bit_cnt  <= 3'b0;
        end
        else if (rinc_out) begin
            // Load new byte and reset bit counter
            byte_buf <= i_byte;
            bit_cnt  <= 3'b0;
        end
        else if (rinc_in & ~rempty_out) begin
            // Shift out the next bit
            byte_buf <= byte_buf >> 1;
            bit_cnt  <= bit_cnt + 1;
        end
    end

    // Output the least significant bit of byte_buf
    assign o_bit = byte_buf[0];

endmodule