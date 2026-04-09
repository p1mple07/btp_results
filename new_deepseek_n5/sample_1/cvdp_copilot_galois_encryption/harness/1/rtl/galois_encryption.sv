localparameter LATENCY  = 'd3;
localparameter NBW_WORD  = 'd8;
localparameter MOD_POLY = 8'h1B;
localparameter LINES    = 'd4;
localparameter COLUMNS  = 'd4;

// Initialize registers
logic [LATENCY:0]    valid_ff;
logic [NBW_WORD-1:0]  key_ff;
logic [NBW_WORD-1:0] [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_in_ff      [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_xtimes2_nx [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_xtimes3_nx [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_xtimes9_nx [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_out_nx     [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_out_ff     [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_out      [NBW_WORD-1:0] data_out ff [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_out -ff    [LINES][COLUMNS];
logic [NBW_WORD-1:0] data_out -nx    [LINES][COLUMNS];

// Initialize validff2 to 0 instead of 'd'
validff2 = 0;