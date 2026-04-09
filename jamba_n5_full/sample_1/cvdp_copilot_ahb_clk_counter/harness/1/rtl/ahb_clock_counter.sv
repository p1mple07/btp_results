module ahb_clock_counter #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input wire HCLK,
    input wire HRESETn,
    input wire HSEL,
    input wire [ADDR_WIDTH-1:0] HADDR,
    input wire HWRITE,
    input wire [DATA_WIDTH-1:0] HWDATA,
    input wire HREADY,
    output reg [DATA_WIDTH-1:0] HRDATA,
    output reg HRESP,
    output reg [DATA_WIDTH-1:0] COUNTER
);

reg [DATA_WIDTH-1:0] counter_value;
reg is_running;
reg max_count_set;
reg overflow_flag;

always @(posedge HRESETn) begin
    counter_value <= 0;
    is_running <= 0;
    max_count_set <= 0;
    overflow_flag <= 0;
end

always_ff @(posedge HCLK) begin
    if (is_running) begin
        if (counter_value == max_count_set) begin
            overflow_flag <= 1;
        end else
            overflow_flag <= 0;
    end
end

always @(*) begin
    if (HADDR == 0x00) begin
        if (HWRITE) begin
            counter_value <= 0;
            is_running <= 1;
        end
    end
end

always @(*) begin
    if (HADDR == 0x04) begin
        if (HWRITE) begin
            is_running <= 0;
            counter_value <= 0;
        end
    end
end

always @(*) begin
    if (HADDR == 0x08) begin
        HRDATA <= counter_value;
    end
end

always @(*) begin
    if (HADDR == 0x0C) begin
        overflow_flag <= (counter_value == max_count_set);
    end
end

always @(*) begin
    if (HADDR == 0x10) begin
        max_count_set <= HWDATA;
        counter_value <= 0;
    end
end

assign HRESP = 1;

endmodule
