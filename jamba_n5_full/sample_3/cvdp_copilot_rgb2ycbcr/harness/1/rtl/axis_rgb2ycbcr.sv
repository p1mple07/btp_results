
always @(posedge aclk) begin
    if (!aresetn) begin
        r <= 0; g <= 0; b <= 0;
    end else if (fifo_write) begin
        r <= {s_axis_tdata[15:11], 3'b0}; // 5-bit to 8-bit
        g <= {s_axis_tdata[10:5],  2'b0}; // 6-bit to 8-bit
        b <= {s_axis_tdata[4:0],   3'b0}; // 5-bit to 8-bit
    end
end
