    case (state)
        IDLE: begin
            // ...
            if (i < N) begin
                key <= array[i];
                j <= i - 1;
                insert_phase <= 0;
            end
        end
        // ...
    endcase
    