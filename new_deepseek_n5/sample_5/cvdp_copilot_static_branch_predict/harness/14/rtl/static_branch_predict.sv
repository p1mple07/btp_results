module static_branch_predict(
  // Instruction from fetch stage
  input  logic [31:0] fetch_rdata_i,
  input  logic [31:0] fetch_pc_i,
  input  logic [31:0] register_addr_i,
  input  logic        fetch_valid_i,

  // Prediction for supplied instruction
  output logic        predict_branch_taken_o,
  output logic [31:0] predict_branch_pc_o,

  // Additional outputs
  output logic [7:0]  predict_confidence_o,   // Confidence level in prediction
  output logic        predict_exception_o,    // Exception/misalignment detection
  output logic [2:0]  predict_branch_type_o,  // Type of branch
  output logic [31:0] predict_branch_offset_o // Calculated branch offset
);

  logic [31:0] reg_addr;
  logic [31:0] imm_jal_type;
  logic [31:0] imm_jalr_type;
  logic [31:0] imm_b_type;
  logic [31:0] imm_cj_type;
  logic [31:0] imm_cb_type;
  logic [31:0] instr;

  logic instr_jal;
  logic instr_jalr;
  logic instr_b;
  logic instr_cj;
  logic instr_cb;

  logic instr_b_taken;

  // Assign instruction to instr
  instr = fetch_rdata_i;

  // Determine instruction type and calculate imms
  case(instr[6:0])
    7'h6F: instr_jal = 1;
    7'h67: instr_jalr = 1;
    7'h63: instr_b = 1;
    7'h62: instr_cj = 1;
    7'h61: instr_cb = 1;
    default: instr_jal = instr_jalr = instr_b = instr_cj = instr_cb = 0;
  endcase

  // Calculate imms based on instruction type
  if(instr_jal)
    imm_jal_type = { {12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0 };
  else if(instr_jalr)
    imm_jalr_type = {{20{instr[31]}}, instr[31:20]} + reg_addr;
  else if(instr_b)
    imm_b_type = { {19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 };
  else if(instr_cj)
    imm_cj_type = { {20{instr[12]}}, instr[12], instr[8], instr[10:9], instr[6], instr[7], instr[2], instr[11], instr[5:3], 1'b0 };
  else if(instr_cb)
    imm_cb_type = { {23{instr[12]}}, instr[12], instr[6:5], instr[2], instr[11:10], instr[4:3], 1'b0 };
  else
    imm_jal_type = imm_jalr_type = imm_b_type = imm_cj_type = imm_cb_type = 0;

  // Set confidence levels
  if(instr_jal || instr_jalr)
    predict_confidence_o = 100;
  else if(instr_b)
    predict_confidence_o = (imm_b_type[31] == 1) ? 90 : 50;
  else if(instr_cj || instr_cb)
    predict_confidence_o = (imm_cj_type[31] == 1) ? 90 : 50;
  else
    predict_confidence_o = 0;

  // Set branch taken flag
  predict_branch_taken_o = predict_confidence_o > 50;

  // Calculate branch target address
  case(instr_jal)
    predict_branch_offset_o = imm_jal_type;
    break;
  case(instr_jalr)
    predict_branch_offset_o = imm_jalr_type;
    break;
  case(instr_b)
    predict_branch_offset_o = imm_b_type;
    break;
  case(instr_cj)
    predict_branch_offset_o = imm_cj_type;
    break;
  case(instr_cb)
    predict_branch_offset_o = imm_cb_type;
    break;
  default
    predict_branch_offset_o = 0;
  endcase

  // Exception detection
  if(!fetch_valid_i || (instr_b_taken && imm_b_type[31] == 0))
    predict_exception_o = 1;
  else
    predict_exception_o = 0;