Example file for using drum
Copyright 2025 Adam Freese
<CsoundSynthesizer>

<CsOptions>
-odac -b 341 -B 3763
</CsOptions>

<CsInstruments>
sr = 44100
kr = 4410
ksmps = 10
nchnls = 2
0dbfs = 1

#include "drum.orc"
</CsInstruments>

<CsScore>
f1   0  4096  10   1

t 0 120

i"Drum"   0          [1/4]      128      0.05     0
i.        +          .          .
i.        +          [1/2]      64
i.        +          [1/2]      .
i.        +          .          .
i.        +          [1/2]      .
i.        +          [1]        .
i.        +          [1/4]      128
i.        +          .          .
i.        +          .          64
i.        +          .          .
i.        +          [1/4]      128
i.        +          .          .
i.        +          .          64
i.        +          .          .
i.        +          [0.5]      128
i.        +          [4]        64

i.        +          [4]        32


</CsScore>

</CsoundSynthesizer>
