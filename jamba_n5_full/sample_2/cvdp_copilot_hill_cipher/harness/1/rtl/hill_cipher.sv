module hill_cipher (
    input clk,
    input reset,
    input start,
    input [14:0] plaintext,
    input [44:0] key,
    output reg [14:0] ciphertext,
    output wire done
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        ciphertext <= 15'd0;
        done <= 1'b0;
    end else begin
        if (start) begin
            // FSM states: IDLE, ENCRYPT, DONE
            case (state)
                0: // IDLE -> ENCRYPT
                    state <= 1;
                    // Start processing
                ...
            endcase
        end
    end
end

// ... implement FSM states

endmodule
