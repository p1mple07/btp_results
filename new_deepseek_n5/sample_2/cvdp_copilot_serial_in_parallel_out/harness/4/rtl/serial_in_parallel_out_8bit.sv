module serial_in_parallel_out_8bit (
    input clock,
    input serial_in,
    output parallel_out
);

    parameter BIT_WIDTH = 8;

    reg [BIT_WIDTH-1:0] parallel_out;
    reg state = 0; // 0: initial state, 1: loaded state

    always clock_edge begin
        case (state)
            0: 
                parallel_out = (parallel_out) << 1;
                parallel_out[0] = serial_in;
                state = 1;
            1: 
                parallel_out = (parallel_out) << 1;
                parallel_out[0] = serial_in;
        endcase
    end

    initial begin
        state = 0;
    end
endmodule