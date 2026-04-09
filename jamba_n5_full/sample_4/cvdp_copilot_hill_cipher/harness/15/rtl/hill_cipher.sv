always_ff @(posedge clk or posedge reset) begin
    if (reset)
        current_state <= IDLE;
    else
        current_state <= next_state;
end

always_comb begin
    next_state = current_state;
    done = 1'b0;

    case (current_state)
        IDLE: begin
            if (start)
                next_state = COMPUTE;
        end
        COMPUTE: begin
            next_state = COMPUTE_MOD;
        end
        COMPUTE_MOD: begin
            next_state = DONE;
        end
        DONE: begin
            done = 1'b1;
            next_state = IDLE;
        end
        default: next_state = IDLE;
    endcase
end

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        temp0 <= 12'b0;
        temp1 <= 12'b0;
        temp2 <= 12'b0;
        C0_reg <= 5'b0;
        C1_reg <= 5'b0;
        C2_reg <= 5'b0;
    end
    else begin
        case (current_state)
            COMPUTE: begin
                temp0 <= (K00 * P0)%26 + (K01 * P1)%26 + (K02 * P2)%26;
                temp1 <= (K10 * P0)%26 + (K11 * P1)%26 + (K12 * P2)%26;
                temp2 <= (K20 * P0)%26 + (K21 * P1)%26 + (K22 * P2)%26;
            end
            COMPUTE_MOD: begin
                C0_reg <= temp0%26;
                C1_reg <= temp1%26;
                C2_reg <= temp2%26;
            end
            default: begin
                temp0 <= 12'b0;
                temp1 <= 12'b0;
                temp2 <= 12'b0;
                C0_reg <= 5'b0;
                C1_reg <= 5'b0;
                C2_reg <= 5'b0;
            end
        end
    end

    assign ciphertext = {C0_reg, C1_reg, C2_reg};
endmodule
