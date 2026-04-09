module queue(
    input clock,
    input rst_ni,
    input clr_i,
    input [DBITS] we_i,
    input [DBITS * DEPTH] d_i,
    output ready,
    output [DBITS * DEPTH] q_o,
    output empty_o,
    output full_o,
    output almost_empty_o,
    output almost_full_o
);

// Internal variables and arrays
reg [DBITS] queue_data[DEPTH];
reg queue_wadr;

// Initialization
always_ensured init() begin
    queue_wadr = 0;
end

// Main logic
always @posedge clock begin
    if (rst_ni) begin
        // Asynchronous reset
        queue_wadr = 0;
        $break;
    end else if (clr_i) begin
        // Synchronous clear
        queue_wadr = 0;
    end else if (we_i && !re_i) begin
        // Write-only operation
        if (queue_wadr < DEPTH - 1) begin
            queue_wadr++;
            queue_data[queue_wadr] = d_i;
        end
    end else if (!we_i && re_i) begin
        // Read-only operation
        if (queue_wadr > 0) begin
            queue_wadr--;
            q_o = queue_data[queue_wadr];
            re_i = 1;
        end
    end else begin
        // Simultaneous read/write operation
        if (we_i && re_i) begin
            if (queue_wadr == 0) begin
                // Handle empty case (first-word-fall-through)
                q_o = queue_data[0];
                re_i = 1;
            else begin
                // Normal operation
                if (queue_wadr > 0) begin
                    queue_wadr--;
                    q_o = queue_data[queue_wadr];
                    re_i = 1;
                end else begin
                    // Edge case handling
                    q_o = queue_data[0];
                    re_i = 1;
                end
            end
        end
    end
end

// Status signal updates
always_ensured sync_begin
    if (queue_wadr == 0) empty_o = 1;
    if (queue_wadr >= DEPTH) full_o = 1;
    almost_empty_o = 0;
    almost_full_o = 0;

    if (almost_empty_threshold <= queue_wadr && !almost_full_threshold <= queue_wadr) almost_empty_o = 1;
    if (almost_full_threshold <= queue_wadr) almost_full_o = 1;
sync_end

// Cleanup
always final cleanup begin
    // Cleanup resources
end

endmodule