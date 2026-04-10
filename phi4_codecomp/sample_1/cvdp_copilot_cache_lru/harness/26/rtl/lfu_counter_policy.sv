module lfu_counter_policy #(
    parameter NWAYS = 4,
    parameter NINDEXES = 32,
    parameter COUNTERW = 2
)(
    input clock,
    input reset,
    input [$clog2(NINDEXES)-1:0] index,
    input [$clog2(NWAYS)-1:0] way_select,
    input access,
    input hit,
    output [$clog2(NWAYS)-1:0] way_replace
);

    localparam int unsigned MAX_FREQUENCY = $pow(2, COUNTERW) - 1;

    // Frequency array to track next way to be replaced
    reg [(NWAYS * COUNTERW)-1:0] frequency [NINDEXES-1:0];

    integer i, n;

    // Sequential logic for reset and frequency updates
    always_ff @ (posedge clock or posedge reset) begin
        if (reset) begin
            for (i = 0; i < NINDEXES; i = i + 1) begin
                for (n = 0; n < NWAYS; n = n + 1) begin
                    frequency[i][(n * COUNTERW) +: COUNTERW] <= COUNTERW'(0);
                end
            end
        end else begin
            if (access) begin
                if (hit) begin
                    // Set the frequency counter of the accessed way
                    if (frequency[index][(way_select * COUNTERW) +: COUNTERW] < COUNTERW'(MAX_FREQUENCY)) begin
                        frequency[index][(way_select * COUNTERW) +: COUNTERW] <= frequency[index][(way_select * COUNTERW) +: COUNTERW] + COUNTERW'(1);
                    end else begin
                        for (n = 0; n < NWAYS; n = n + 1) begin
                            if (n != way_select && frequency[index][(n * COUNTERW) +: COUNTERW] > COUNTERW'(2)) begin
                                frequency[index][(n * COUNTERW) +: COUNTERW] <= frequency[index][(n * COUNTERW) +: COUNTERW] - COUNTERW'(1);
                            end
                        end
                    end
                end else begin
                    // Set the frequency counter of the replaced way
                    frequency[index][(way_replace * COUNTERW) +: COUNTERW] <= COUNTERW'(1);
                end
            end
        end
    end

    // Select the LFU slot
    slot_select_lfu_counter #(
        .NWAYS (NWAYS),
        .COUNTERW (COUNTERW)
    ) slot_select_unit (
        .array (frequency[index]),
        .index (way_replace)
    );

endmodule : lfu_counter_policy

module slot_select_lfu_counter #(
    parameter NWAYS = 4,
    parameter COUNTERW = $clog2(NWAYS)
)(
    input logic [(NWAYS * COUNTERW)-1:0] array,
    output logic [$clog2(NWAYS)-1:0] index
);

    integer i;

    always_comb begin
        // Default outputs
        index = $clog2(NWAYS)'(0);

        // Find the index of the first counter with minimum frequency
        for (i = 0; i < NWAYS; i++) begin
            if (array[(i * COUNTERW) +: COUNTERW] < array[(index * COUNTERW) +: COUNTERW]) begin
                index = $clog2(NWAYS)'(i);
            end
        end
    end

endmodule : slot_select_lfu_counter