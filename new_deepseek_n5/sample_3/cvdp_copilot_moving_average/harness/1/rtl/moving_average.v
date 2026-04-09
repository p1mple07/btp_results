module moving_average (
    input clock,
    input reset,
    input [11:0] data_in,
    output [11:0] data_out
);

    // FIFO buffer to store last 8 samples
    FIFO FIFO Buff8 (
        input [11:0] data_in,
        output [11:0] data_out,
        input clock,
        input reset,
        output enable FIFO Valid
    );

    // Sum register to hold sum of last 8 samples
    reg sum Buff8 SumReg (
        input [11:0] data_in,
        output reg [14:0] sum
    );

    // Counter to track number of valid samples
    reg count Buff8 CountReg;

    // Output buffer for data_out
    FIFO FIFO OutBuff (
        input [11:0] data_out,
        output [11:0] data_out,
        input clock,
        input reset,
        output enable FIFO Valid
    );

    // Logic to compute the average
    always_posedge clock begin
        if (reset) begin
            Buff8 Valid = 0;
            SumReg = 0;
            OutBuff Valid = 0;
            count Buff8 CountReg = 0;
        end else begin
            if (!Buff8 Valid) begin
                SumReg = Buff8 Valid ? SumReg + data_in : 0;
                Buff8 Valid = 1;
                OutBuff Valid = 1;
            end else if (count Buff8 CountReg < 8) begin
                SumReg = SumReg + data_in;
                count Buff8 CountReg = count Buff8 CountReg + 1;
                OutBuff Valid = 1;
            end else begin
                SumReg = SumReg + data_in;
                Buff8 Valid = 0;
                OutBuff Valid = 0;
                count Buff8 CountReg = 0;
            end

            if (count Buff8 CountReg >= 8) begin
                data_out = SumReg >> 3; // Equivalent to dividing by 8
            else begin
                data_out = 0;
            end
        end
    end
endmodule