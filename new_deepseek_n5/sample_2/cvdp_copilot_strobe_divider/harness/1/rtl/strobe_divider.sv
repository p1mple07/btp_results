module strobe_divider #(
    parameter MaxRatio_g = 10,
    parameter Latency_g  = 1
)(
    input  wire Clk,
    input  wire Rst,
    input  wire [log2ceil(MaxRatio_g)-1:0] In_Ratio,
    input  wire In_Valid,
    output reg Out_Valid,
    input  wire Out_Ready
);

    function integer log2ceil;
        input integer value;
        integer i;
        begin
            log2ceil = 1;
            for (i = 0; (2 ** i) < value; i = i + 1)
                log2ceil = i + 1;
        end
    endfunction

    reg [log2ceil(MaxRatio_g)-1:0] r_Count, r_next_Count;
    reg r_OutValid, r_next_OutValid;
    reg OutValid_v;

    always @* begin
        r_next_Count = r_Count;
        r_next_OutValid = r_OutValid;

        if (In_Ratio == 0) begin
            r_next_OutValid = 1;
        else begin
            if (In_Valid) begin
                r_next_Count = r_Count + 1;
            end else begin
                r_next_Count = 0;
            end
            if (r_Count == In_Ratio) begin
                r_next_Count = 0;
            end
        end

        if (Latency_g == 1) begin
            OutValid_v = r_next_OutValid;
        else begin
            OutValid_v = r_OutValid;
        end
    end

    always @(posedge Clk) begin
        if (Rst) begin
            r_Count = 0;
            r_OutValid = 0;
        end else begin
            r_Count = r_next_Count;
            r_OutValid = r_next_OutValid;
        end
    end

    Out_Valid = OutValid_v;
endmodule