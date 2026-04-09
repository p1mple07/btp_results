module pipelined_skid_buffer (
    input wire clock,
    input wire rst,

    input wire [3:0] data_i,
    input wire valid_i,
    output wire ready_o,
    output wire valid_o,
    output wire [3:0] data_o,
    input wire ready_i
    );
    
    // Define registers and signals
    reg [3:0] mem;
    reg data_present;
    reg ready_to_accept;
    
    // Implement handshake protocol
    always @(posedge clock) begin
        if (!rst) begin
            // Reset logic
            mem <= 4'b0;
            data_present <= 1'b0;
            ready_to_accept <= 1'b0;
        end else begin
            // Data storage and forwarding
            if (valid_i &&!ready_to_accept) begin
                mem <= data_i;
                data_present <= 1'b1;
                ready_to_accept <= 1'b1;
            end else if (ready_to_accept && ready_i) begin
                // Reset ready_to_accept to prevent data loss
                ready_to_accept <= 1'b0;
                // Deliver output data
                data_o <= mem;
                valid_o <= data_present;
                ready_o <= 1'b1;
            end else begin
                // Data remains in buffer
                data_o <= mem;
                valid_o <= data_present;
                ready_o <= 1'b0;
            end
        end
    end
    
    // Assign outputs
    assign ready_i = valid_o;
endmodule

module register (
    input clk,
    input rst,

    input [3:0] data_in,
    input valid_in,
    output ready_out,
    output valid_out,
    output [3:0] data_out,
    input  ready_in    
    );
    
    // Define registers and signals
    reg [3:0] mem;
    reg data_present;
    reg ready_to_accept;
    
    // Implement handshake protocol
    always @(posedge clock) begin
        if (!rst) begin
            // Reset logic
            mem <= 4'b0;
            data_present <= 1'b0;
            ready_to_accept <= 1'b0;
        end else begin
            // Data storage and forwarding
            if (valid_in &&!ready_to_accept) begin
                mem <= data_in;
                data_present <= 1'b1;
                ready_to_accept <= 1'b1;
            end else if (ready_to_accept && ready_in) begin
                // Reset ready_to_accept to prevent data loss
                ready_to_accept <= 1'b0;
                // Deliver output data
                data_out <= mem;
                valid_out <= data_present;
                ready_out <= 1'b1;
            end else begin
                // Data remains in buffer
                data_out <= mem;
                valid_out <= data_present;
                ready_out <= 1'b0;
            end
        end
    end
    
    // Assign outputs
    assign ready_in = valid_out;
endmodule

module skid_buffer (

input  clk,
input  reset,

input  [3:0]i_data,
input  i_valid,
output o_ready,

output [3:0]o_data,
output o_valid,
input  i_ready

);
    
    // Define registers and signals
    reg [3:0]mem;
    reg data_present;
    reg ready_to_accept;
    reg  skid_buffer_full;

    // Implement handshake protocol
    always @ (posedge clock) begin
        if (!rst) begin
            // Reset logic
            mem <= 4'b0;
            data_present <= 1'b0;
            ready_to_accept <= 1'b0;
        end else begin
            // Data storage and forwarding
            if (valid_i &&!ready_to_accept) begin
                mem <= data_i;
                data_present <= 1'b1;
                ready_to_accept <= 1'b1;
            end else if (ready_to_accept && ready_i) begin
                // Deliver output data
                data_o <= mem;
                valid_o <= data_present;
                ready_o <= 1'b1;
            end else begin
                // Reset ready_o to prevent data loss.
                data_o <= mem;
                valid_o and ready_i
    endmodule