module apb_controller (
    input wire clk,
    input wire reset_n,
    input wire select_a_i,
    input wire select_b_i,
    input wire select_c_i,
    input wire addr_a_i [31:0],
    input wire data_a_i [31:0],
    input wire addr_b_i [31:0],
    input wire data_b_i [31:0],
    input wire addr_c_i [31:0],
    input wire data_c_i [31:0],
    output reg apb_psel_o,
    output reg apb_penable_o,
    output reg apb_pwrite_o,
    output reg apb_paddr_o [31:0],
    output wire apb_pready_i
);

reg [3:0] current_event;
reg [3:0] state;
reg [3:0] timeout_counter;

always @(posedge clk) begin
    if (!reset_n) begin
        current_event <= 0;
        state <= 0;
        apb_psel_o <= 1'b0;
        apb_penable_o <= 1'b0;
        apb_pwrite_o <= 1'b0;
        apb_paddr_o <= 0;
        apb_pwdata_o <= 0;
        apb_pready_i <= 1'b0;
        timeout_counter <= 0;
    end else begin
        case (current_event)
            0: begin
                if (select_a_i) begin
                    current_event <= 1;
                end else if (select_b_i) begin
                    current_event <= 2;
                end else if (select_c_i) begin
                    current_event <= 3;
                end else begin
                    current_event <= 0;
                end
            end
            1: begin // Event A
                apb_psel_o = 1'b1;
                apb_pwrite_o = 1'b1;
                apb_paddr_o = addr_a_i;
                apb_pwdata_o = data_a_i;
            end
            2: begin // Event B
                apb_psel_o = 1'b1;
                apb_pwrite_o = 1'b0;
                apb_paddr_o = addr_b_i;
                apb_pwdata_o = data_b_i;
            end
            3: begin // Event C
                apb_psel_o = 1'b1;
                apb_pwrite_o = 1'b0;
                apb_paddr_o = addr_c_i;
                apb_pwdata_o = data_c_i;
            end
        endcase
    end
end

always @(posedge clk) begin
    if (state == 0 && current_event == 0) begin
        apb_penable_o <= 1'b0;
        apb_pwrite_o <= 1'b0;
        apb_paddr_o <= 0;
        apb_pwdata_o <= 0;
    end else if (state == 1 && current_event == 1) begin
        apb_penable_o <= 1'b1;
        apb_pwrite_o <= 1'b0;
        apb_paddr_o <= 0;
    end else if (state == 2 && current_event == 2) begin
        apb_penable_o <= 1'b0;
        apb_pwrite_o <= 1'b0;
    end
end

always @(*) begin
    apb_pready_i <= apb_pwrite_o;
end

always @(posedge clk) begin
    if (apb_pready_i) begin
        timeout_counter <= 0;
    end else begin
        timeout_counter <= timeout_counter + 1;
        if (timeout_counter > 15) begin
            apb_penable_o <= 1'b0;
            apb_pwrite_o <= 1'b0;
            apb_paddr_o <= 0;
            apb_pwdata_o <= 0;
            apb_pready_i <= 1'b0;
        end
    end
end

endmodule
