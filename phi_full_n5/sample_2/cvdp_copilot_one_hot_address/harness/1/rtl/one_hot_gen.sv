module one_hot_gen #(
    parameter NS_A = 8,
    parameter NS_B = 4
) (
    input  logic                 clk,
    input  logic                 rst_async_n,
    input  logic [2:0]           i_config, // Corrected width to match `i_config` usage
    input  logic                 i_start,
    input  logic                 o_ready,
    output logic [NS_A+NS_B-1:0] o_address_one_hot // Corrected width to match declaration
);

typedef enum logic [2:0] {IDLE = 3'b000, REGION_A = 3'b001, REGION_B = 3'b010} state_t;

// ...

// Fix width mismatch for `region_A_nx` and `region_B_nx`
always_comb begin : drive_regions
    case(state_ff)
        IDLE: begin
            if(i_start) begin
                region_A_nx[NS_A-1:0] = {(NS_A-1){1'b0}};
                region_B_nx[NS_B-1:0] = {(NS_B-1){1'b0}};
            end else begin
                region_A_nx[NS_A-1:0] = 3'b0;
                region_B_nx[NS_B-1:0] = 3'b0;
            end
        end
        // ...
    endcase
end

// Fix selection index out of range
always_comb begin : update_state
    case(state_ff)
        IDLE: begin
            if(i_start) begin
                if(i_config[0]) begin
                    state_nx = REGION_B;
                end else begin
                    state_nx = REGION_A;
                end
            end else begin
                state_nx = IDLE;
            end
        end
        REGION_A: begin
            if(region_A_ff[0]) begin
                if(A_to_B) begin
                    state_nx = REGION_B;
                end else begin
                    state_nx = IDLE;
                end
            end else begin
                state_nx = REGION_A;
            end
        end
        REGION_B: begin
            if(region_B_ff[0]) begin
                if(B_to_A) begin
                    state_nx = REGION_A;
                end else begin
                    state_nx = IDLE;
                end
            end else begin
                state_nx = REGION_B;
            end
        end
        default: begin
            state_nx = IDLE;
        end
    endcase
end

// ...
