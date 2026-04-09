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

    reg [3:0] phase;
    reg [4:0] timeout_counter;
    reg [31:0] addr_out, data_out;

    // State machine
    always @(posedge clk or posedge reset_n) begin
        if (reset_n) begin
            phase <= 0;
            timeout_counter <= 0;
            addr_out <= 0;
            data_out <= 0;
        end else begin
            case (phase)
                0: begin
                    if (select_a_i) begin
                        addr_out = addr_a_i;
                        data_out = data_a_i;
                    end
                    if (select_b_i) begin
                        addr_out = addr_b_i;
                        data_out = data_b_i;
                    end
                    if (select_c_i) begin
                        addr_out = addr_c_i;
                        data_out = data_c_i;
                    end
                    apb_psel_o <= 1;
                    apb_penable_o <= 0;
                    apb_pwrite_o <= 1;
                    phase <= 1;
                    timeout_counter <= 0;
                    addr_out <= 0;
                    data_out <= 0;
                end
                1: begin
                    apb_psel_o <= 0;
                    apb_penable_o <= 1;
                    apb_pwrite_o <= 1;
                    addr_out <= apb_paddr_o;
                    data_out <= apb_pwdata_o;
                    phase <= 2;
                    timeout_counter <= 0;
                end
                2: begin
                    if (!apb_pready_i) begin
                        timeout_counter <= timeout_counter + 1;
                        if (timeout_counter >= 15) begin
                            phase <= 0;
                            timeout_counter <= 0;
                            apb_psel_o <= 0;
                            apb_penable_o <= 0;
                            addr_out <= 0;
                            data_out <= 0;
                        end
                    end else begin
                        phase <= 3;
                    end
                end
                3: begin
                    if (apb_pready_i) begin
                        phase <= 0;
                        addr_out <= 0;
                        data_out <= 0;
                    end
                end
            endcase
        end
    end

endmodule
