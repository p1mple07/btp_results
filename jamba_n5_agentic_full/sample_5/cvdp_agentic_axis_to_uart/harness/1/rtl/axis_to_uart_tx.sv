
Inputs:
- aclk: System clock input that drives the module.
- aresetn: Active low asynchronous reset signal.
- tdata: AXI-Stream data input. Width is defined by BIT_PER_WORD (8 bits by default).
- tvalid: AXI-Stream valid signal, indicating that tdata is valid and ready for transmission.
