module one_hot_gen #(
    parameter NS_A = 'd8, // Number of bits in Region A
    parameter NS_B = 'd4  // Number of bits in Region B
) (
    input  logic                 clk,       // Clock
    input  logic                 rst_async_n, // Asynchronous reset active low
    input  logic [1:0]           i_config, // Configuration input
    input  logic                 i_start,  // Start input
    output logic [NS_A+NS_B-1:0] o_address_one_hot // One-hot encoded address output
);

typedef enum logic [2:0] {IDLE = 2'b00, REGION_A = 2'b01, REGION_B = 2'b10} state_t;

// Regions flags
logic [NS_A-1:0] region_A_ff, region_A_nx;
logic [NS_B-1:0] region_B_ff, region_B_nx;

// Address concatenation flag
logic only_A, only_B;

// One-hot address representation
logic [NS_A+NS_B-1:0] address_one_hot_ff, address_one_hot_nx;

// Signals for next-state logic
state_t state_ff, state_nx;

// Register initialization
initial begin
    region_A_ff <= {NS_A{1'b0}};
    region_B_ff <= {NS_B{1'b0}};
    state_ff    <= IDLE;
end

// Register updates
always_ff @(posedge clk or negedge rst_async_n) begin : register_updates
    if(~rst_async_n) begin
        address_one_hot_ff <= '0;
    end else begin
        address_one_hot_ff <= address_one_hot_nx;
        region_A_ff      <= region_A_nx;
        region_B_ff      <= region_B_nx;
        state_ff         <= state_nx;
    end
end

// Address generation
always_comb begin : address_generation
    case(state_ff)
        IDLE: begin
            address_one_hot_nx = '0;
            region_A_nx = {'0};
            region_B_nx = {'0};
            if(i_start) begin
                region_A_nx[NS_A] = i_config[0];
                region_B_nx[NS_B] = i_config[1];
            end else begin
                region_A_nx[NS_A-1:0] = {(NS_A-1){1'b0}};
                region_B_nx[NS_B-1:0] = {(NS_B-1){1'b0}};
            end
        end
        REGION_A: begin
            region_A_nx = region_A_ff >> 1;

            if(region_A_ff[0]) begin
                region_B_nx[0] = A_to_B;
            end else begin
                region_B_nx[0] = 1'b0;
            end
            region_B_nx[NS_B-2:0] = {(NS_B-1){1'b0}};
        end
        REGION_B: begin
            if(region_B_ff[0]) begin
                region_A_nx[NS_A-2:0] = {(NS_A-1){1'b0}};
                region_B_nx[0] = B_to_A;
            end else begin
                region_A_nx[NS_A-2:0] = {(NS_A-1){1'b0}};
                region_B_nx[0] = 1'b0;
            end
            region_B_nx[NS_B-2:0] ={(NS_B-1){1'b0}};
        end
        default: begin
            region_A_nx = {NS_A{1'b0}};
            region_B_nx = {NS_B{1'b0}};
        end
    endswitch
    
    always_comb begin : drive regions
        CASEXPRESSION_A_TO_B_TO_A
            A_TO_B_ff = {(NS_A-1:0){1'b0}};
        
        default: begin
            A_TO_B_ff = {(NS_A-1:0){1'b0}};
            B_TO_A_ff = {(NS_B-1:0){1'b0}};
        end
    endcasexpression_a_to_b_ff = {(NS_A-1:0){1'b0}};
    end
    
    always_comb begin : update_state_ff = {(NS_A{1'b0}{1'b0}};
    
        case(state_ff)
            IDLE: begin : update_state_ff
                IDLE: begin
                    state_nx = IDLE;
                end
...
endmodule