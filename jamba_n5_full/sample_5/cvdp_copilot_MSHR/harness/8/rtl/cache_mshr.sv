graph LR;
    A1[MSHR Entry 1: index=1, addr=0x44, next_idx=3] --> B1[MSHR Entry 3: index=3, addr=0x44, next_idx=4]
    B1 --> B2[MSHR Entry 4: index=4, addr=0x44, next_idx=x]
