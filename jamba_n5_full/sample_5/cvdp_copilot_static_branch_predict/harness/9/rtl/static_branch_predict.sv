module static_branch_predict (
    // ... same inputs
    output logic [7:0] predict_confidence_o,
    output logic predict_exception_o,
    output logic [2:0] predict_branch_type_o,
    // ... other outputs
);

  // ... existing assignments

  // New outputs
  assign predict_confidence_o = ...;
  assign predict_exception_o = ...;
  assign predict_branch_type_o = ...;

endmodule
