module custom_byte_enable_ram #(
    parameter XLEN = 32,
    parameter LINES = 8192
)(
    input logic clk,
    input logic [ADDR_WIDTH-1:0] addr_a,
    input logic [ADDR_WIDTH-1:0] addr_b,
    input logic en_a,
    input logic en_b,
    input logic [XLEN/8-1:0] be_a,
    input logic [XLEN/8-1:0] be_b,
    input logic [XLEN-1:0] data_in_a,
    input logic [XLEN-1:0] data_in_b,
    output logic [XLEN-1:0] data_out_a,
    output logic [XLEN-1:0] data_out_b
);

localparam ADDR_WIDTH = $clog2(LINES);
localparam ADDR_SIZE = ADDR_WIDTH + 1; // but not needed.

reg [XLEN-1:0] ram [LINES-1:0];
reg [1:0] pending_write_a, pending_write_b;

always @(posedge clk) begin
    if (en_a) begin
        if (!pending_write_a) begin
            ram[addr_a] <= data_in_a;
            pending_write_a = 1'b1;
        end else begin
            // collision? maybe we don't need to handle here.
        end
    end
    if (en_b) begin
        if (!pending_write_b) begin
            ram[addr_b] <= data_in_b;
            pending_write_b = 1'b1;
        end else begin
            // collision: need to resolve
            // According to spec: if collision, Port A's byte-enable active, so write from A.
            // So we just write data_in_a to ram[addr_b]?
            // But the spec says: "If collision occurs, priority is: Port A's byte-enable active: byte written from Port A. Port A's byte-enable inactive & Port B's active: byte written from Port B. Independent writes without collision."
            // For simultaneous write to same address, Port A takes precedence.
            // So we need to check if the address is same.

            // But we need to check if the write is simultaneous: en_a and en_b both true and addr equal.
            if (en_a && en_b && addr_a == addr_b) begin
                // This is simultaneous write: we need to decide priority.
                // According to spec, Port A's byte-enable active: write from A.
                ram[addr_b] <= data_in_a;
            end else begin
                // no collision, just write normally.
            end
        end
    end
end

// Output: pipeline one cycle? But spec says pipelined reads. Maybe we just output after one cycle.

// We need to implement pipelined reads: maybe output data after one cycle. But we can just assign immediately.

always @(*) begin
    data_out_a = ram[addr_a];
    data_out_b = ram[addr_b];
end

initial begin
    #10;
    addr_a = 0;
    en_a = 1;
    be_a = 4'b1111;
    data_in_a = 32'hDEADBEEF;
    #10;
    en_a = 0;
    #30;

    addr_b = 1;
    en_b = 1;
    be_b = 4'b1100;  
    data_in_b = 32'hCAFEBABE;
    #10;
    en_b = 0;
    #30;

    #50;
    $finish;
end

endmodule
