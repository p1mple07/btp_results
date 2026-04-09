Module declaration
module rtl/queue(

    // Parameters
    parameter DEPTH,
    parameter DBITS,

    // Inputs
    input wire [DBITS-1:0] we_i,
    input wire [DBITS-1:0] d_i,
    input clockclk_i,
    input rst_ni,
    input clr_i,

    // Outputs
    output reg [DBITS-1:0] q_o,
    output reg re_i,

    // Status signals
    output reg empty_o,
    output reg full_o,
    output reg almost_empty_o,
    output reg almost_full_o

);

    // Internal variables
    reg [DBITS-1:0] queue_data[DEPTH-1:0];
    reg queue_wadr;

    // Initialize queue pointer
    integer i;
    initial begin
        i = 0;
    end

    // Event listeners (asynchronous)
    always_comb begin
        if (!rst_ni) begin
            // Synchronous clear
            if (clr_i) begin
                queue_wadr = 0;
                $ clock_next(clk_i);
            end
        end
    end

    // Write-only operation
    always edge sensitive+begin
        when WE(we_i) begin
            if (i < DEPTH - 1) begin
                queue_data[queue_wadr] = d_i;
                queue_wadr = i + 1;
                $ clock_next(clk_i);
            end else 
                $ clock_next(clk_i); // Wrap around?
            end
        end
    end

    // Read-only operation
    always edge sensitive+begin
        when RE(re_i) begin
            if (queue_wadr > 0) begin
                q_o = queue_data[queue_wadr - 1];
                queue_wadr = queue_wadr - 1;
            end else 
                // Queue is empty, no data available yet
                q_o = 0;
            end
        end
    end

    // Simultaneous read/write operation
    always edge sensitive+begin
        when WE(we_i) & RE(re_i) begin
            if (queue_wadr > 0) begin
                q_o = queue_data[queue_wadr - 1];
                queue_wadr = queue_wadr - 1;
            else 
                // Queue is empty, write data to index 0
                q_o = d_i;
                queue_wadr = 0;
            end
        end
    end

    // Update status signals
    always comb begin
        empty_o = (queue_wadr == 0);
        full_o = (queue_wadr >= DEPTH);
        almost_empty_o = (queue_wadr <= ALMOST_EMPTY_THRESHOLD);
        almost_full_o = (queue_wadr >= ALMOST_FULL_THRESHOLD);
    end

endmodule