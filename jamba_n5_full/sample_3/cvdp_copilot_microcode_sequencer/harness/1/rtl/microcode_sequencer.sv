(`instr_in` = 5'b00010).

The data from the auxiliary register (`aux_reg`) is selected by the multiplexer in the `microcode_arithmetic` module and output to the `d_out` port.

Instruction: Fetch Data (`instr_in` = 5'b00011).

The data from the data bus (`d_in`) is passed to the `microcode_sequencer` module through the multiplexers.

Instruction: Fetch R + D (`instr_in` = 5'b00100).

The data from the register (`register_data`) and data bus (`d_in`) is combined by the multiplexer in the `microcode_arithmetic` module and output to the `d_out` port.

Instruction: Push PC (already covered in above example)

Instruction: Pop PC (covered above)

Instruction: Fetch R (covered above)

Instruction: Push R (covered above)

Instruction: Push D (covered above)

Instruction: Push Auxiliary Register (covered above)

Instruction: Push Stack Pointer (covered above)

Instruction: Push Data Bus (covered above)

Instruction: Push Constant 0x00

Instruction: Push Constant 0x01

Instruction: Push 0x02

Instruction: Push 0x03

Instruction: Push 0x04

Instruction: Push 0x05

Instruction: Push 0x06

Instruction: Push 0x07

Instruction: Push 0x08

Instruction: Push 0x09

Instruction: Push 0x0A

Instruction: Push 0x0B

Instruction: Push 0x0C

Instruction: Push 0x0D

Instruction: Push 0x0E

Instruction: Push 0x0F

Instruction: Push 0x10

Instruction: Push 0x11

Instruction: Push 0x12

Instruction: Push 0x13

Instruction: Push 0x14

Instruction: Push 0x15

Instruction: Push 0x16

Instruction: Push 0x17

Instruction: Push 0x18

Instruction: Push 0x19

Instruction: Push 0x1A

Instruction: Push 0x1B

Instruction: Push 0x1C

Instruction: Push 0x1D

Instruction: Push 0x1E

Instruction: Push 0x1F

Instruction: Push 0x20

Instruction: Push 0x21

Instruction: Push 0x22

Instruction: Push 0x23

Instruction: Push 0x24

Instruction: Push 0x25

Instruction: Push 0x26

Instruction: Push 0x27

Instruction: Push 0x28

Instruction: Push 0x29

Instruction: Push 0x2A

Instruction: Push 0x2B

Instruction: Push 0x2C

Instruction: Push 0x2D

Instruction: Push 0x2E

Instruction: Push 0x2F

Instruction: Push 0x30

Instruction: Push 0x31

Instruction: Push 0x32

Instruction: Push 0x33

Instruction: Push 0x34

Instruction: Push 0x35

Instruction: Push 0x36

Instruction: Push 0x37

Instruction: Push 0x38

Instruction: Push 0x39

Instruction: Push 0x3A

Instruction: Push 0x3B

Instruction: Push 0x3C

Instruction: Push 0x3D

Instruction: Push 0x3E

Instruction: Push 0x3F

Instruction: Push 0x40

Instruction: Push 0x41

Instruction: Push 0x42

Instruction: Push 0x43

Instruction: Push 0x44

Instruction: Push 0x45

Instruction: Push 0x46

Instruction: Push 0x47

Instruction: Push 0x48

Instruction: Push 0x49

Instruction: Push 0x4A

Instruction: Push 0x4B

Instruction: Push 0x4C

Instruction: Push 0x4D

Instruction: Push 0x4E

Instruction: Push 0x4F

Instruction: Push 0x50

Instruction: Push 0x51

Instruction: Push 0x52

Instruction: Push 0x53

Instruction: Push 0x54

Instruction: Push 0x55

Instruction: Push 0x56

Instruction: Push 0x57

Instruction: Push 0x58

Instruction: Push 0x59

Instruction: Push 0x5A

Instruction: Push 0x5B

Instruction: Push 0x5C

Instruction: Push 0x5D

Instruction: Push 0x5E

Instruction: Push 0x5F

Instruction: Push 0x60

Instruction: Push 0x61

Instruction: Push 0x62

Instruction: Push 0x63

Instruction: Push 0x64

Instruction: Push 0x65

Instruction: Push 0x66

Instruction: Push 0x67

Instruction: Push 0x68

Instruction: Push 0x69

Instruction: Push 0x6A

Instruction: Push 0x6B

Instruction: Push 0x6C

Instruction: Push 0x6D

Instruction: Push 0x6E

Instruction: Push 0x6F

Instruction: Push 0x70

Instruction: Push 0x71

Instruction: Push 0x72

Instruction: Push 0x73

Instruction: Push 0x74

Instruction: Push 0x75

Instruction: Push 0x76

Instruction: Push 0x77

Instruction: Push 0x78

Instruction: Push 0x79

Instruction: Push 0x7A

Instruction: Push 0x7B

Instruction: Push 0x7C

Instruction: Push 0x7D

Instruction: Push 0x7E

Instruction: Push 0x7F

Instruction: Push 0x80

Instruction: Push 0x81

Instruction: Push 0x82

Instruction: Push 0x83

Instruction: Push 0x84

Instruction: Push 0x85

Instruction: Push 0x86

Instruction: Push 0x87

Instruction: Push 0x88

Instruction: Push 0x89

Instruction: Push 0x8A

Instruction: Push 0x8B

Instruction: Push 0x8C

Instruction: Push 0x8D

Instruction: Push 0x8E

Instruction: Push 0x8F

Instruction: Push 0x90

Instruction: Push 0x91

Instruction: Push 0x92

Instruction: Push 0x93

Instruction: Push 0x94

Instruction: Push 0x95

Instruction: Push 0x96

Instruction: Push 0x97

Instruction: Push 0x98

Instruction: Push 0x99

Instruction: Push 0x9A

Instruction: Push 0x9B

Instruction: Push 0x9C

Instruction: Push 0x9D

Instruction: Push 0x9E

Instruction: Push 0x9F

Instruction: Push 0xA0

Instruction: Push 0xA1

Instruction: Push 0xA2

Instruction: Push 0xA3

Instruction: Push 0xA4

Instruction: Push 0xA5

Instruction: Push 0xA6

Instruction: Push 0xA7

Instruction: Push 0xA8

Instruction: Push 0xA9

Instruction: Push 0xAA

Instruction: Push 0xAB

Instruction: Push 0xAC

Instruction: Push 0xAD

Instruction: Push 0xAE

Instruction: Push 0xAF

Instruction: Push 0xB0

Instruction: Push 0xB1

Instruction: Push 0xB2

Instruction: Push 0xB3

Instruction: Push 0xB4

Instruction: Push 0xB5

Instruction: Push 0xB6

Instruction: Push 0xB7

Instruction: Push 0xB8

Instruction: Push 0xB9

Instruction: Push 0xBA

Instruction: Push 0xBB

Instruction: Push 0xBC

Instruction: Push 0xBD

Instruction: Push 0xBE

Instruction: Push 0xBF

Instruction: Push 0xC0

Instruction: Push 0xC1

Instruction: Push 0xC2

Instruction: Push 0xC3

Instruction: Push 0xC4

Instruction: Push 0xC5

Instruction: Push 0xC6

Instruction: Push 0xC7

Instruction: Push 0xC8

Instruction: Push 0xC9

Instruction: Push 0xCA

Instruction: Push 0xCB

Instruction: Push 0xCC

Instruction: Push 0xCD

Instruction: Push 0xCE

Instruction: Push 0xCF

Instruction: Push 0xD0

Instruction: Push 0xD1

Instruction: Push 0xD2

Instruction: Push 0xD3

Instruction: Push 0xD4

Instruction: Push 0xD5

Instruction: Push 0xD6

Instruction: Push 0xD7

Instruction: Push 0xD8

Instruction: Push 0xD9

Instruction: Push 0xDA

Instruction: Push 0xDB

Instruction: Push 0xDC

Instruction: Push 0xDD

Instruction: Push 0xDE

Instruction: Push 0xDF

Instruction: Push 0xE0

Instruction: Push 0xE1

Instruction: Push 0xE2

Instruction: Push 0xE3

Instruction: Push 0xE4

Instruction: Push 0xE5

Instruction: Push 0xE6

Instruction: Push 0xE7

Instruction: Push 0xE8

Instruction: Push 0xE9

Instruction: Push 0xEA

Instruction: Push 0xEF

Instruction: Push 0xF0

Instruction: Push 0xF1

Instruction: Push 0xF2

Instruction: Push 0xF3

Instruction: Push 0xF4

Instruction: Push 0xF5

Instruction: Push 0xF6

Instruction: Push 0xF7

Instruction: Push 0xF8

Instruction: Push 0xF9

Instruction: Push 0xFA

Instruction: Push 0xFB

Instruction: Push 0xFC

Instruction: Push 0xFD

Instruction: Push 0xFE

Instruction: Push 0xFF

Instruction: Push 0x100

Instruction: Push 0x101

Instruction: Push 0x102

Instruction: Push 0x103

Instruction: Push 0x104

Instruction: Push 0x105

Instruction: Push 0x106

Instruction: Push 0x107

Instruction: Push 0x108

Instruction: Push 0x109

Instruction: Push 0x10A

Instruction: Push 0x10B

Instruction: Push 0x10C

Instruction: Push 0x10D

Instruction: Push 0x10E

Instruction: Push 0x10F

Instruction: Push 0x110

Instruction: Push 0x111

Instruction: Push 0x112

Instruction: Push 0x113

Instruction: Push 0x114

Instruction: Push 0x115

Instruction: Push 0x116

Instruction: Push 0x117

Instruction: Push 0x118

Instruction: Push 0x119

Instruction: Push 0x11A

Instruction: Push 0x11B

Instruction: Push 0x11C

Instruction: Push 0x11D

Instruction: Push 0x11E

Instruction: Push 0x11F

Instruction: Push 0x120

Instruction: Push 0x121

Instruction: Push 0x122

Instruction: Push 0x123

Instruction: Push 0x124

Instruction: Push 0x125

Instruction: Push 0x126

Instruction: Push 0x127

Instruction: Push 0x128

Instruction: Push 0x129

Instruction: Push 0x12A

Instruction: Push 0x12B

Instruction: Push 0x12C

Instruction: Push 0x12D

Instruction: Push 0x12E

Instruction: Push 0x12F

Instruction: Push 0x130

Instruction: Push 0x131

Instruction: Push 0x132

Instruction: Push 0x133

Instruction: Push 0x134

Instruction: Push 0x135

Instruction: Push 0x136

Instruction: Push 0x137

Instruction: Push 0x138

Instruction: Push 0x139

Instruction: Push 0x13A

Instruction: Push 0x13B

Instruction: Push 0x13C

Instruction: Push 0x13D

Instruction: Push 0x13E

Instruction: Push 0x13F

Instruction: Push 0x140

Instruction: Push 0x141

Instruction: Push 0x142

Instruction: Push 0x143

Instruction: Push 0x144

Instruction: Push 0x145

Instruction: Push 0x146

Instruction: Push 0x147

Instruction: Push 0x148

Instruction: Push 0x149

Instruction: Push 0x14A

Instruction: Push 0x14B

Instruction: Push 0x14C

Instruction: Push 0x14D

Instruction: Push 0x14E

Instruction: Push 0x14F

Instruction: Push 0x150

Instruction: Push 0x151

Instruction: Push 0x152

Instruction: Push 0x153

Instruction: Push 0x154

Instruction: Push 0x155

Instruction: Push 0x156

Instruction: Push 0x157

Instruction: Push 0x158

Instruction: Push 0x159

Instruction: Push 0x15A

Instruction: Push 0x15B

Instruction: Push 0x15C

Instruction: Push 0x15D

Instruction: Push 0x15E

Instruction: Push 0x15F

Instruction: Push 0x160

Instruction: Push 0x161

Instruction: Push 0x162