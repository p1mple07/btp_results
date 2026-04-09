module moving_average (
    input clock,
    input reset,
    input [11:0] data_in,
    output [11:0] data_out
);

    // FIFO buffer to store last 8 samples
    reg [11:0] buffer [7:0];
    // Sum register
    reg sum;
    // State to control buffer and sum operations
    reg state;

    // Initialize state
    always @* begin
        state = 0;
    end

    // State transitions
    case(state)
        0: 
            // On reset, clear buffer, sum, and output
            if (reset) begin
                buffer = 0;
                sum = 0;
                data_out = 0;
                state = 1;
            end else begin
                // Start collecting samples
                buffer[0] = data_in;
                sum = data_in;
                state = 2;
            end
        1: 
            // If buffer has less than 8 samples, update buffer and sum
            if (state < 8) begin
                buffer[state] = data_in;
                sum = sum + data_in;
                state = state + 1;
            end else begin
                // If buffer is full, shift out oldest sample and update sum
                sum = sum + data_in - buffer[0];
                buffer = buffer[1:7] + (data_in << 8);
                state = 2;
            end
        2: 
            // Calculate average
            data_out = sum >> 3;
    endcase

    // Output the average on the next clock cycle
    always @posedge clock begin
        if (reset) begin
            data_out = 0;
        else
            data_out = sum >> 3;
        end
    end
endmodule