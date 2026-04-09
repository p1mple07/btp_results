module dual_port_memory #(
    parameter DATA_WIDTH = 4,
    parameter ADDR_WIDTH = 5
)(...){
    // ... existing code ...
}

always @(posedge clock or negedge clock) begin
    if (we_a) begin
        ram[addr_a] <= data_in_a;
        data_out_a <= ram[addr_a] >> 1;
    end else begin
        data_out_a <= ram[addr_a] << 1;
    end

    if (we_b) begin
        ram[addr_b] <= data_in_b;
        data_out_b <= ram[addr_b] + 1;
    end else begin
        data_out_b <= ram[addr_b] - 1;
    end
}
// ... rest of the code ...