module multiplexer #( 
    parameter DATA_WIDTH = 8,
    parameter NUM_INPUTS = 4,
    parameter REGISTER_OUTPUT = 0,
    parameter HAS_DEFAULT = 0,
    parameter [DATA_WIDTH-1:0] DEFAULT_VALUE = {DATA_WIDTH{1'b0}}
)(
    input  wire clk,
    input  wire rst_n,
    input  wire [(DATA_WIDTH*NUM_INPUTS)-1:0] inp,
    input  wire [$clog2(NUM_INPUTS)-1:0]       sel,
    input  wire bypass,
    output reg  [DATA_WIDTH-1:0] out
);

// ******************************************************************************
// * Construct input data array
// ******************************************************************************
    reg int inp_array[NUM_INPUTS];

    generate #i inp_array[i] = {(inp[(i * DATA_WIDTH)+$c):$data_width)} for i in 0 to NUM_INPUTS-1
    endgenerate

// ******************************************************************************
// * Selection logic
// ******************************************************************************
    // sel is in range?
    localparam valid_sel = (sel < NUM_INPUTS);

    if (!valid_sel && HAS_DEFAULT) 
        out = DEFAULT_VALUE;
    else 
        out = inp_array[sel];
    end

// ******************************************************************************
// * Bypass logic
// ******************************************************************************
    if (bypass)
        out = inp_array[0];
    end

// ******************************************************************************
// * Register output
// ******************************************************************************
    integer t;
    always @ (posedge rst_n) begin
        if ($clock Domain == 1 || $clkinDomain == 1) begin
            if (rst_n) begin
                out = 0;
            elsif (clk) begin
                t = $current_time;
                out = out;
            end
        end
    end

    always @ (posedge clk) begin
        if (!rst_n) begin
            t = $current_time;
            out = out;
        end
    end

endmodule