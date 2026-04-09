module apb_controller (
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
    input apb_pready_i,
    output reg apb_psel_o,
    output reg apb_penable_o,
    output reg [31:0] apb_paddr_o,
    output reg [31:0] apb_pwdata_o
);

    // Internal signals
    reg [31:0] current_addr, current_data;
    reg [4:0] timeout_counter;
    reg [1:0] state = 2'b00; // IDLE

    // State machine
    always @(posedge clk or posedge reset_n) begin
        if (reset_n) begin
            state <= 2'b00;
            apb_psel_o <= 1'b0;
            apb_penable_o <= 1'b0;
            apb_paddr_o <= 0;
            apb_pwdata_o <= 0;
            timeout_counter <= 4'b0;
        end else if (state == 2'b00) begin
            if (select_a_i) begin
                current_addr <= addr_a_i;
                current_data <= data_a_i;
                state <= 2'b01;
            end
            if (select_b_i) begin
                current_addr <= addr_b_i;
                current_data <= data_b_i;
                state <= 2'b01;
            end
            if (select_c_i) begin
                current_addr <= addr_c_i;
                current_data <= data_c_i;
                state <= 2'b01;
            end
        end else if (state == 2'b01) begin
            apb_psel_o <= 1'b1;
            apb_paddr_o <= current_addr;
            apb_pwdata_o <= current_data;
            apb_penable_o <= 1'b1;
            state <= 2'b10;
        end else if (state == 2'b10) begin
            timeout_counter <= timeout_counter + 1;
            if (apb_pready_i == 1'b0) begin
                state <= 2'b00;
                apb_psel_o <= 1'b0;
                apb_penable_o <= 1'b0;
                apb_paddr_o <= 0;
                apb_pwdata_o <= 0;
                timeout_counter <= 4'b0;
            end
        end
    end

    // ACCESS phase with timeout
    always @(posedge clk) begin
        if (state == 2'b10 && apb_pready_i == 1'b0) begin
            timeout_counter <= 4'b0;
        end
    end

    // IDLE state
    always @(posedge clk or posedge reset_n) begin
        if (reset_n) begin
            state <= 2'b00;
            apb_psel_o <= 1'b0;
            apb_penable_o <= 1'b0;
            apb_paddr_o <= 0;
            apb_pwdata_o <= 0;
        end else if (state == 2'b00 && timeout_counter == 4'b15) begin
            timeout_counter <= 4'b0;
            state <= 2'b00;
        end
    end

endmodule
