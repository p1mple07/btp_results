module vending_machine(
    input logic clk,
    input logic rst,
    input logic [2:0] item_selected,
    input logic [3:0] coin_input,
    input logic cancel,
    output logic dispense_item,
    output logic return_change,
    output logic [2:0] item_price,
    output logic [4:0] change_amount,
    output logic [2:0] dispense_item_id,
    output logic error,
    output logic return_money
);

// Define your FSM here

always @(posedge clk) begin
    // Define your state machine logic here
end

endmodule