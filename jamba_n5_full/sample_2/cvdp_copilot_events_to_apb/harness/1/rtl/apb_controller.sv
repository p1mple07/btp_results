module apb_controller #(
    parameter WIDTH = 32
)(
    input clk,
    input reset_n,
    input select_a_i,
    input select_b_i,
    input select_c_i,
    input [31:0] addr_a_i,
    input [31:0] data_a_i,
    input [31:0] addr_b_i,
    input [31:0] data_b_i,
    input [31:0] addr_c_i,
    input [31:0] data_c_i,
    output reg apb_psel_o,
    output reg apb_penable_o,
    output reg apb_pwrite_o,
    output reg apb_paddr_o [WIDTH-1:0],
    output reg apb_pwdata_o [WIDTH-1:0]
);

reg [3:0] state;
reg [2:0] current_event;
reg [31:0] pending_addr, pending_data;
reg apb_penable;
reg apb_pwrite;
reg apb_paddr;
reg apb_pwdata;
reg apb_psel;

always @(posedge clk or posedge reset_n) begin
    if (reset_n) begin
        apb_psel <= 0;
        apb_penable <= 0;
        apb_pwrite <= 0;
        apb_paddr <= 0;
        apb_pwdata <= 0;
        state <= 0;
        current_event <= 0;
    end else begin
        case (state)
            0: begin
                if (select_a_i) begin
                    apb_psel <= 1;
                    pending_addr <= addr_a_i;
                    pending_data <= data_a_i;
                    state <= 1;
                end
            end
            1: begin
                if (select_b_i) begin
                    apb_psel <= 2;
                    pending_addr <= addr_b_i;
                    pending_data <= data_b_i;
                    state <= 2;
                end
            end
            2: begin
                if (select_c_i) begin
                    apb_psel <= 3;
                    pending_addr <= addr_c_i;
                    pending_data <= data_c_i;
                    state <= 3;
                end
            end
            default: state <= 0;
        endcase
    end
end

always @(posedge clk) begin
    if (state == 1) begin
        apb_pwrite <= 1;
        apb_paddr <= pending_addr;
        apb_pwdata <= pending_data;
    end
end

always @(posedge clk) begin
    if (state == 2) begin
        apb_pready <= 0;
        apb_pwrite <= 0;
        apb_paddr <= 0;
        apb_pwdata <= 0;
    end
    if (state == 3) begin
        apb_pready <= 1;
        apb_pwrite <= 1;
        apb_paddr <= pending_addr;
        apb_pwdata <= pending_data;
        apb_penable <= 1;
    end
end

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        apb_psel <= 0;
        apb_penable <= 0;
        apb_pwrite <= 0;
        apb_paddr <= 0;
        apb_pwdata <= 0;
        state <= 0;
        current_event <= 0;
        apb_pready <= 0;
        apb_pwrite <= 0;
        apb_paddr <= 0;
        apb_pwdata <= 0;
    end else begin
        if (apb_pready != apb_pready_prev) begin
            if (apb_pready) begin
                apb_pready_prev <= 1;
                apb_pwrite <= 0;
                apb_paddr <= 0;
                apb_pwdata <= 0;
            end else begin
                apb_pready_prev <= 0;
                apb_pwrite <= 0;
                apb_paddr <= 0;
                apb_pwdata <= 0;
                apb_penable <= 0;
            end
        end
    end
end

always @(posedge clk) begin
    if (state == 3) begin
        state <= 0;
        apb_psel <= 0;
        apb_penable <= 0;
        apb_pwrite <= 0;
        apb_paddr <= 0;
        apb_pwdata <= 0;
    end
end

endmodule
