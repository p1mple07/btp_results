module sync_lifo (
    input clock,
    input reset,
    input write_en,
    input read_en,
    input data_in,
    output empty,
    output full,
    output data_out
) 

    integer depth = 1 << ADDR_WIDTH;
    integer write_ptr = 0;
    integer read_ptr = 0;
    integer state = 0;

    // Memory array to hold the LIFO data
    reg [DATA_WIDTH-1:0] memory [0:depth-1] = -1;

    // State machine control variables
    reg write_ptr, read_ptr;
    reg state;

    always clockedge clock begin
        if (reset) 
            state = 0;
            write_ptr = 0;
            read_ptr = 0;
            memory = -1;
        else 
            case state
                0: 
                    if (write_en) 
                        if (state == 0) 
                            state = 1;
                        else 
                            if (state == 1) 
                                if (count Leading 1's in memory) >= DATA_WIDTH * depth) 
                                    state = 1;
                                else 
                                    state = 2;
                    wait 1 clock;
                    if (state == 1) 
                        if (write_ptr < depth) 
                            memory[write_ptr] = data_in;
                            write_ptr = (write_ptr + 1) % depth;
                            state = 2;
                        else 
                            state = 1;
                    else 
                        if (read_en) 
                            if (state == 2) 
                                if (read_ptr >= 0) 
                                    data_out = memory[read_ptr];
                                    read_ptr = (read_ptr - 1 + depth) % depth;
                                    state = 3;
                                else 
                                    state = 2;
                            else 
                                state = 2;
                    wait 1 clock;
                    if (state == 3) 
                        if (full) 
                            state = 0;
                        else 
                            if (empty) 
                                state = 0;
                            else 
                                state = 3;
                    wait;
                1: 
                    if (read_en) 
                        if (state == 3) 
                            if (empty) 
                                data_out = data_out;
                                state = 0;
                            else 
                                data_out = memory[read_ptr];
                                read_ptr = (read_ptr - 1 + depth) % depth;
                                state = 3;
                        else 
                            state = 3;
                    wait 1 clock;
                    if (state == 0) 
                        if (reset) 
                            state = 0;
                        else 
                            if (write_en) 
                                if (state == 0) 
                                    state = 1;
                                else 
                                    if (state == 1) 
                                        if (count Leading 1's in memory) >= DATA_WIDTH * depth) 
                                            state = 1;
                                        else 
                                            state = 2;
                    wait;
                2: 
                    if (state == 2) 
                        if (full) 
                            state = 1;
                        else 
                            if (empty) 
                                state = 1;
                            else 
                                state = 2;
                    wait;
                3: 
                    if (state == 3) 
                        if (full) 
                            state = 0;
                        else 
                            if (empty) 
                                state = 0;
                            else 
                                state = 3;
                    wait;
            endcase
        end
    endmodule