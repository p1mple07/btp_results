module cdc_pulse_synchronizer #(parameter NUM_CHANNELS = 4)(
    input  logic src_clock,       // Source Clock Domain
    input  logic des_clock,       // Destination Clock Domain
    input  logic rst_in,          // Asynchronous Active-High Reset
    input  logic src_pulse[NUM_CHANNELS-1:0],       // Source Pulse
    output logic des_pulse[NUM_CHANNELS-1:0]        // Destination Pulse
);

    logic pls_toggle[NUM_CHANNELS-1:0];      
    logic pls_toggle_synca[NUM_CHANNELS-1:0], pls_toggle_syncb[NUM_CHANNELS-1:0], pls_toggle_syncc[NUM_CHANNELS-1:0];
    logic rst_src_sync[NUM_CHANNELS-1:0], rst_des_sync[NUM_CHANNELS-1:0];
    logic rst_src_synca[NUM_CHANNELS-1:0], rst_src_syncb[NUM_CHANNELS-1:0];
    logic rst_des_synca[NUM_CHANNELS-1:0], rst_des_syncb[NUM_CHANNELS-1:0];

    always_ff @(posedge src_clock or posedge rst_in) begin
        if (rst_in) begin
            rst_src_synca <= 1'b1;
            rst_src_syncb <= 1'b1;
        end else begin
            rst_src_synca <= 1'b0;
            rst_src_syncb <= rst_src_synca;
        end
    end

    assign rst_src_sync = rst_src_syncb;

    always_ff @(posedge des_clock or posedge rst_in) begin
        if (rst_in) begin
            rst_des_synca <= 1'b1;
            rst_des_syncb <= 1'b1;
        end else begin
            rst_des_synca <= 1'b0;
            rst_des_syncb <= rst_des_synca;
        end
    end

    assign rst_des_sync = rst_des_syncb;

    always_ff @(posedge src_clock or posedge rst_src_sync) begin
        if (rst_src_sync) begin
            pls_toggle <= 1'b0;
        end else if (src_pulse[0]) begin
            pls_toggle <= ~pls_toggle;
        end
    end

    always_ff @(posedge des_clock or posedge rst_des_sync) begin
        if (rst_des_sync) begin
            pls_toggle_synca <= 1'b0;
            pls_toggle_syncb <= 1'b0;
        end else begin
            pls_toggle_synca <= pls_toggle;
            pls_toggle_syncb <= pls_toggle_synca;
        end
    end

    always_ff @(posedge des_clock or posedge rst_des_sync) begin
        if (rst_des_sync) begin
            pls_toggle_syncc <= 1'b0;
        end else begin
            pls_toggle_syncc <= pls_toggle_syncb;
        end
    end

    assign des_pulse[0] = pls_toggle_syncc | pls_toggle_syncb;
    assign des_pulse[1] = pls_toggle_syncc;
    assign des_pulse[2] = pls_toggle_syncc;
    assign des_pulse[3] = pls_toggle_syncc;
    
endmodule

// Create a new logic files for the design.
module create_logic_files(input string path, input integer num_files);
    logic_files = $fopen("rtl/logic_files/" + path);
    logic_files_open = $fopen(path, "r");
    logic logic_files_close = $fclose(logic_files_open);
    
    // Generate the logic files for the design.
    //  for (int i=0; i < num_files;
    for (int i = 0; i <= num_files; i >= num_files;
        logic_files_open = $fopen(path, "w");

    // Write the logic files for the design.
    // Use a for loop to write the logic files for the design.
    // in a loop for writing the logic files for the design.
    for (int i=0; i <= num_files;
    end

endmodule