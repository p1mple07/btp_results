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
    output reg [31:0] apb_paddr_o,
    output reg [31:0] apb_pwdata_o
);

    // Internal signals
    reg [3:0] transaction_state;
    reg [4:0] timeout_counter;
    reg [31:0] current_address;
    reg [31:0] current_data;

    // Internal registers
    reg [31:0] addr_reg;
    reg [31:0] data_reg;

    // State machine
    always @(posedge clk or posedge reset_n) begin
        if (reset_n) begin
            transaction_state <= IDLE;
            timeout_counter <= 0;
            addr_reg <= 0;
            data_reg <= 0;
        end else begin
            case (transaction_state)
                IDLE: begin
                    if (select_a_i) begin
                        addr_reg <= addr_a_i;
                        data_reg <= data_a_i;
                        transaction_state <= SETUP;
                    end
                    if (select_b_i) begin
                        addr_reg <= addr_b_i;
                        data_reg <= data_b_i;
                        transaction_state <= SETUP;
                    end
                    if (select_c_i) begin
                        addr_reg <= addr_c_i;
                        data_reg <= data_c_i;
                        transaction_state <= SETUP;
                    end
                end
                SETUP: begin
                    apb_psel_o = 1;
                    apb_pwrite_o = 1;
                    apb_paddr_o = addr_reg;
                    apb_pwdata_o = data_reg;
                    timeout_counter <= 0;
                    transaction_state <= ACCESS;
                end
                ACCESS: begin
                    apb_penable_o = 1;
                    if (!apb_pready_i) begin
                        timeout_counter <= timeout_counter + 1;
                        if (timeout_counter >= 16) begin
                            transaction_state <= IDLE;
                            apb_psel_o <= 0;
                            apb_penable_o <= 0;
                            apb_pwrite_o <= 0;
                            apb_paddr_o <= 0;
                            apb_pwdata_o <= 0;
                        end
                    end else begin
                        // Wait for apb_pready_i
                    end
                end
                IDLE: begin
                    apb_psel_o <= 0;
                    apb_penable_o <= 0;
                    apb_pwrite_o <= 0;
                    apb_paddr_o <= 0;
                    apb_pwdata_o <= 0;
                    timeout_counter <= 0;
                end
            endcase
        end
    end

endmodule
