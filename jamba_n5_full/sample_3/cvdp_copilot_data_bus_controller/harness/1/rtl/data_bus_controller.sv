module data_bus_controller #(
    parameter AFINITY = 0
) (
    input         clk      ,
    input         rst_n    ,

    output        m0_read  ,
    input         m0_valid ,
    input [31:0]  m0_data  ,

    output        m1_read  ,
    input         m1_valid ,
    input [31:0]  m1_data  ,

    input         s_read   ,
    output        s_valid  ,
    output [31:0] s_data 
);

// Internal handshake signals
reg m0_ready, m1_ready, s_ready;

always @(posedge clk or posedge rst_n) begin
    if (!rst_n) begin
        m0_ready <= 0;
        m1_ready <= 0;
        s_ready <= 0;
    end else begin
        if (s_ready) begin
            m0_ready <= 1;
            m1_ready <= 1;
        end else begin
            m0_ready <= 0;
            m1_ready <= 0;
        end
    end
end

always @(posedge clk or posedge rst_n) begin
    if (!rst_n) begin
        m0_valid <= 0;
        m1_valid <= 0;
        s_valid <= 0;
    end else begin
        m0_valid <= m0_ready;
        m1_valid <= m1_ready;
        s_valid <= s_ready;
    end
end

always @(posedge clk or posedge rst_n) begin
    if (!rst_n) begin
        m0_data  <= 32'd0;
        m1_data  <= 32'd0;
        s_data    <= 32'd0;
    end else begin
        m0_data  <= m0_data;
        m1_data  <= m1_data;
        s_data    <= s_data;
    end
end

// Output registers
assign m0_read   = s_valid;
assign m1_read   = s_valid;
assign s_valid   = s_ready;
assign s_data    = m0_data[31] ? m1_data[31] : 
                     (m0_data[31] && !m1_valid ? m0_data[31] : 
                      (m1_data[31] && !m0_valid ? m1_data[31] : 
                       32'd0));

endmodule
