module hill_cipher (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [14:0] plaintext,
    input wire [44:0] key,
    output wire [14:0] ciphertext,
    output wire done
);

    reg clk_debounced;
    reg [6:0] counter;
    reg [2:0] state;

    always @(posedge clk) begin
        if (!reset) begin
            state <= 0;
            done <= 0;
            ciphertext <= "0000000000";
        end else begin
            case(state)
                0: begin // wait for start
                    if (start) begin
                        state <= 1;
                        done <= 0;
                    end
                end
                1: begin // prepare plaintext
                    if (ready_input) begin
                        state <= 2;
                    end else begin
                        state <= 0;
                    end
                end
                2: begin // compute ciphertext
                    state <= 3;
                end
                3: begin // output done
                    done <= 1;
                    state <= 0;
                end
            endcase
        end
    end

endmodule
