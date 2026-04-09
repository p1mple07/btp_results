reg [7:0] buffer; // hold last 8 samples
integer count;
integer total;
initial $random_value;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        count = 0;
        total = 0;
        data_out = 0;
    end else {
        data_out = total / count;
        if (data_in != 0) begin
            buffer = {buffer[7:0], data_in};
            total = total + data_in;
            count = count + 1;
        end
    }
end
