`timescale 1ps/1ps
module apb_controller(
    input  logic         clk,              // Clock signal
    input  logic         reset_n,          // Active low asynchronous reset signal
    input  logic         select_a_i,       // Select signal for event A
    input  logic         select_b_i,       // Select signal for event B
    input  logic         select_c_i,       // Select signal for event C
    input  logic [31:0]  addr_a_i,         // 32-bit address for event A transaction
    input  logic [31:0]  data_a_i,         // 32-bit data for event A transaction
    input  logic [31:0]  addr_b_i,         // 32-bit address for event B transaction
    input  logic [31:0]  data_b_i,         // 32-bit data for event B transaction
    input  logic [31:0]  addr_c_i,         // 32-bit address for event C transaction
    input  logic [31:0]  data_c_i,         // 32-bit data for event C transaction
    output logic         apb_psel_o,       // APB select signal
    output logic         apb_penable_o,    // APB enable signal
    output logic [31:0]  apb_paddr_o,      // 32-bit APB address output
    output logic         apb_pwrite_o,     // APB write signal
    output logic [31:0]  apb_pwdata_o,     // 32-bit APB write data output
    input  logic         apb_pready_i      // APB ready signal from the peripheral
);

    // State definitions
    typedef enum logic [1:0] {
       IDLE,   
       SETUP,  
       ACCESS
    } state_t; 

    // Internal signals
    logic [3:0]  count;
    state_t      current_state, next_state;
    logic [31:0] sel_addr_next, sel_data_next;  // Selected address and data (combinational logic)
    logic [31:0] sel_addr, sel_data;           // Latched address and data


    assign apb_psel_o    = (current_state == SETUP || current_state == ACCESS) ? 1'b1 : 1'b0;
    assign apb_penable_o = (current_state == ACCESS) ? 1'b1 : 1'b0;
    assign apb_pwrite_o  = (current_state == SETUP || current_state == ACCESS) ? 1'b1 : 1'b0;
    assign apb_paddr_o   = (current_state == SETUP || current_state == ACCESS) ? sel_addr : 32'b0;
    assign apb_pwdata_o  = (current_state == SETUP || current_state == ACCESS) ? sel_data : 32'b0;


    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        next_state = current_state;
        sel_addr_next = sel_addr;
        sel_data_next = sel_data;

        case (current_state)
            IDLE: begin
                if (select_a_i) begin
                    next_state = SETUP;
                    sel_addr_next = addr_a_i;
                    sel_data_next = data_a_i;
                end else if (select_b_i) begin
                    next_state = SETUP;
                    sel_addr_next = addr_b_i;
                    sel_data_next = data_b_i;
                end else if (select_c_i) begin
                    next_state = SETUP;
                    sel_addr_next = addr_c_i;
                    sel_data_next = data_c_i;
                end else begin
                    next_state = IDLE;
                    sel_addr_next = 32'b0;
                    sel_data_next = 32'b0;
                end
            end
            SETUP: begin
                next_state = ACCESS;
            end
            ACCESS: begin
                if (apb_pready_i || count == 15) begin
                    next_state = IDLE;
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            count <= 0;
        end else if (current_state == ACCESS && !apb_pready_i) begin
            count <= count + 1;
        end else begin
            count <= 0;
        end
    end

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sel_addr <= 32'b0;
            sel_data <= 32'b0;
        end else if (current_state == IDLE)begin
            sel_addr <= sel_addr_next;
            sel_data <= sel_data_next;
        end
    end


endmodule