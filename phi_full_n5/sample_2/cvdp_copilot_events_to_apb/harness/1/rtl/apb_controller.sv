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

    output apb_psel_o,
    output apb_penable_o,
    output apb_pwrite_o,
    output [31:0] apb_paddr_o,
    output [31:0] apb_pwdata_o
);

    reg [1:0] state_reg, state_next;
    reg [3:0] timeout_counter;

    // State and transition logic
    always @(posedge clk or posedge reset_n) begin
        if (reset_n) begin
            state_reg <= 2'b00; // IDLE
            timeout_counter <= 4'd0;
            apb_psel_o <= 1'b0;
            apb_penable_o <= 1'b0;
            apb_pwrite_o <= 1'b0;
            apb_paddr_o <= 0;
            apb_pwdata_o <= 0;
        end else begin
            state_next = state_reg;
            if (select_a_i) state_next = 3'b01;
            else if (select_b_i) state_next = 3'b10;
            else if (select_c_i) state_next = 3'b11;
            else state_next = 2'b00; // IDLE

            if (state_next != state_reg) begin
                state_reg <= state_next;
                case (state_next)
                    3'b01: begin
                        apb_psel_o <= 1'b1;
                        apb_pwrite_o <= 1'b1;
                        apb_paddr_o <= addr_a_i;
                        apb_pwdata_o <= data_a_i;
                    end
                    3'b10: begin
                        apb_psel_o <= 1'b1;
                        apb_pwrite_o <= 1'b1;
                        apb_paddr_o <= addr_b_i;
                        apb_pwdata_o <= data_b_i;
                    end
                    3'b11: begin
                        apb_psel_o <= 1'b1;
                        apb_pwrite_o <= 1'b1;
                        apb_paddr_o <= addr_c_i;
                        apb_pwdata_o <= data_c_i;
                    end
                    2'b00: begin
                        apb_psel_o <= 1'b0;
                        apb_penable_o <= 1'b0;
                        apb_pwrite_o <= 1'b0;
                        apb_paddr_o <= 0;
                        apb_pwdata_o <= 0;
                    end
                endcase
            end
        end
    end

    // ACCESS Phase logic
    always @(posedge clk) begin
        if (state_reg == 3'b11) begin
            if (!apb_penable_o) begin
                apb_penable_o <= 1'b1;
                timeout_counter <= 4'd0;
            end else if (apb_penable_o && !apb_pready_i) begin
                timeout_counter <= timeout_counter + 1'b1;
                if (timeout_counter >= 4'd15) begin
                    apb_penable_o <= 1'b0;
                    apb_paddr_o <= 0;
                    apb_pwdata_o <= 0;
                    timeout_counter <= 4'd0;
                    state_reg <= 2'b00; // IDLE
                end
            end
        end
    end

endmodule
