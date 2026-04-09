
            DONE: begin
                if (!start) begin
                    next_state = IDLE;
                end else begin
                    next_state = DONE;
                end
            end
