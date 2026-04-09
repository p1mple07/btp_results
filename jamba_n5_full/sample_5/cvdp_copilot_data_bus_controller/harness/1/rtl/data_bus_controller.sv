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

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        m0_ready <= 1'b0;
        m1_ready <= 1'b0;
        s_ready <= 1'b0;
        s_valid <= 1'b0;
        s_data <= 32'd0;
        m0_valid <= 0;
        m0_data <= 0;
        m1_valid <= 0;
        m1_data <= 0;
    end else begin
        if (m0_ready && s_ready) begin
            case (AFINITY)
                case (AFINITY == 0):
                    s_valid <= 1'b1;
                    s_data <= m0_data;
                case (AFINITY == 1):
                    s_valid <= 1'b1;
                    s_data <= m1_data;
            endcase
        else if (m1_ready && s_ready) begin
            case (AFINITY)
                case (AFINITY == 0):
                    s_valid <= 1'b0;
                    s_data <= m1_data;
                case (AFINITY == 1):
                    s_valid <= 1'b1;
                    s_data <= m0_data;
            endcase
        } else if (m0_ready && !m1_ready) begin
            s_valid <= 1'b1;
            s_data <= m0_data;
        } else if (m1_ready && !m0_ready) begin
            s_valid <= 1'b1;
            s_data <= m1_data;
        }
    end
end

always @(*) begin
    if (s_valid) begin
        s_data <= (s_read ? m0_data : m1_data);
    end
end

endmodule
