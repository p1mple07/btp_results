module binary_multiplier #(
    parameter WIDTH = 32
)(
    input  logic               clk,
    input  logic               rst_n,
    input  logic [WIDTH-1:0]   A,
    input  logic [WIDTH-1:0]   B,
    input  logic               valid_in,
    output logic [2*WIDTH-1:0] Product,
    output logic               valid_out
);

    integer i;
    logic [2*WIDTH-1:0] sum;
    logic [WIDTH-1:0]   cnt;
    logic               start, done;

    // Latching A and B to hold stable inputs
    logic [WIDTH-1:0]   A_latched, B_latched;

    assign valid_out = done;

    // Sequential logic to control the generation of partial products and summing
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sum        <= 0;
            cnt        <= 0;
            Product    <= 0;
            done       <= 0;
            start      <= 0;
            A_latched  <= 0;
            B_latched  <= 0;
        end else begin
            // Latch `valid_in` and input values at the start of the operation
            if (valid_in) begin
                start     <= 1;
                A_latched <= A;
                B_latched <= B;
            end

            // Perform operations only if `start` is active and `done` is not yet set
            if (start && !done) begin
                // Generate and sum partial products directly, one per cycle
                if (cnt < WIDTH) begin
                    if (A_latched[cnt]) begin
                        sum <= sum + (B_latched << cnt);  // Generate and add partial product directly to sum
                    end
                    cnt <= cnt + 1;
                end else begin
                    // Once all partial products have been summed, assign the result
                    Product <= sum;
                    done    <= 1;  // Mark operation complete
                end
            end

            // Reset the control flags and intermediate values for the next operation
            else if (done) begin
                done     <= 0;
                sum      <= 0;
                cnt      <= 0;
                start    <= 0;
            end
        end
    end
endmodule