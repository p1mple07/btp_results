module one_hot_gen #(
    parameter NS_A = 'd8,
    parameter NS_B = 'd4
) (
    input  logic                 clk,
    input  logic                 rst_async_n,
    input  logic [1:0]           i_config,
    input  logic                 i_start,
    input  logic                 o_ready,
    output logic [NS_A+NS_B-1:0] o_address_one_hot
);

typedef enum logic [2:0] {IDLE = 2'b00, REGION_A = 2'b01, REGION_B = 2'b10} state_t;

// ----------------------------------------
// - Wires/Registers creation
// ----------------------------------------
state_t state_ff, state_nx;
logic [NS_A-1:0] region_A_ff, region_A_nx;
logic [NS_B-1:0] region_B_ff, region_B_nx;

// Input register
logic [2:0] config_ff;

// ----------------------------------------
// - Wire connections
// ----------------------------------------

// Region change flags
assign A_to_B = ( config_ff[1] & ~config_ff[0]);
assign B_to_A = ( config_ff[1] &  config_ff[0]);
assign only_A = (~config_ff[0] & ~config_ff[0]);
assign only_B = (~config_ff[0] &  config_ff[0]);

// Output assignment (Region A concatenated with Region B)
assign o_address_one_hot = {region_A_ff, region_B_ff};

// ----------------------------------------
// - Registers
// ----------------------------------------

always_ff @(posedge clk or negedge rst_async_n) begin : input_register
    if(~rst_async_n) begin
        config_ff <= 0;
    end else begin
        if(i_start && state_ff == IDLE) begin
            config_ff <= i_config;
        end
    end
end

always_ff @(posedge clk or negedge rst_async_n) begin : reset_regs
    if(~rst_async_n) begin
        o_ready <= 1;
        state_ff <= IDLE;
        region_A_ff <= {NS_A{1'b0}};
        region_B_ff <= {NS_B{1'b0}};
    end else begin
        o_ready <= (state_nx == IDLE);
        state_ff <= state_nx;
        region_A_ff <= region_A_nx;
        region_B_ff <= region_B_nx;
    end
end

// ----------------------------------------
// - One-hot address generation
// ----------------------------------------

always_comb begin : drive_regions
    case(state_ff)
        IDLE: begin
            if(i_start) begin
                region_A_nx[NS_A-1] = (~i_config[0]);
                region_B_nx[NS_B-1] = (i_config[0]);
            end else begin
                region_A_nx[NS_A-1] = 1'b0;
                region_B_nx[NS_B-1] = 1'b0;
            end

            region_A_nx[NS_A-2:0] = {(NS_A-1){1'b0}};
            region_B_nx[NS_B-2:0] = {(NS_B-1){1'b0}};
        end
        REGION_A: begin
            region_A_nx = region_A_ff >> 1;

            if(region_A_ff[0]) begin
                region_B_nx[NS_B-1] = A_to_B;
            end else begin
                region_B_nx[NS_B-1] = 1'b0;
            end
            region_B_nx[NS_B-2:0] = {(NS_B-1){1'b0}};
        end
        REGION_B: begin
            if(region_B_ff[0]) begin
                region_A_nx[NS_A-1] = B_to_A;
            end else begin
                region_A_nx[NS_A-1] = 1'b0;
            end
            region_A_nx[NS_A-2:0] = {(NS_A-1){1'b0}};

            region_B_nx = region_B_ff >> 1;
        end
        default: begin
            region_A_nx = {NS_A{1'b0}};
            region_B_nx = {NS_B{1'b0}};
        end
    endcase
end

// ----------------------------------------
// - FSM update
// ----------------------------------------

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

endmodule