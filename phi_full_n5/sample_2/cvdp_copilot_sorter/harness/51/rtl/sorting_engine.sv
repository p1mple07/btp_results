// Original redundant wire assignments
wire [WIDTH-1:0] val_j;
wire [WIDTH-1:0] val_j1;

// Optimized by directly using array elements
always @(*) begin
    if (i < N-1 && j < N-1) begin
        if (array[j] > array[j+1]) begin
            array[j]   <= array[j+1];
            array[j+1] <= array[j];
        end
    end
end
