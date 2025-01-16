; Copyright 2025 Adam Freese
; See LICENSE file


; This instrument expects that the function table 1 is a sine wave.
; Include something like the following in the score file:
;   f1   0  4096  10   1


; Zeros (roots) of the Bessel functions
giBesseln1[] fillarray 2.4048255577, 3.83170597021, 5.13562230184, 6.38016189592, 7.5883424345, 8.77148381596, 9.93610952422, 11.0863700192, 12.225092264, 13.3543004774, 14.4755006866
giBesseln2[] fillarray 5.52007811029, 7.01558666982, 8.4172441404, 9.76102312998, 11.0647094885, 12.3386041975, 13.5892901705, 14.821268727, 16.0377741909, 17.2412203825, 18.433463667
giBesseln3[] fillarray 8.65372791291, 10.1734681351, 11.6198411721, 13.0152007217, 14.3725366716, 15.7001740797, 17.0038196678, 18.2875828325, 19.554536431, 20.8070477893, 22.0469853647
giBesseln4[] fillarray 11.791534439, 13.3236919363, 14.7959517824, 16.2234661603, 17.6159660498, 18.9801338752, 20.3207892136, 21.6415410198, 22.9451731319, 24.2338852578, 25.5094505542
giBesseln5[] fillarray 14.9309177085, 16.4706300509, 17.959819495, 19.4094152264, 20.826932957, 22.2177998966, 23.5860844356, 24.9349278877, 26.2668146412, 27.5837489636, 28.8873750635


opcode BesselRoot, i, ii
  ; This opcode gives the iMth root of the iNth Bessel function.
  ; Works only for 1 <= iN <= 5 and 0 <= iM <= 10
  iM, iN xin
  if(iN==1) ithen
    iRoot = giBesseln1[iM]
  elseif(iN==2) ithen
    iRoot = giBesseln2[iM]
  elseif(iN==3) ithen
    iRoot = giBesseln3[iM]
  elseif(iN==4) ithen
    iRoot = giBesseln4[iM]
  elseif(iN==5) ithen
    iRoot = giBesseln5[iM]
  endif
  xout iRoot
endop


gideg = 3.14159625358977/180.0
opcode pandeg, aa, ai
  ; An opcode to pan a monophonic signal by an angle, given in degrees.
  aMono, ideg xin
  iPY = cos(gideg*ideg/2)
  iPR = sin(gideg*ideg/2)
  iPL = -iPR
  aLeft = (iPY + iPL) * aMono / sqrt(2)
  aRight = (iPY + iPR) * aMono / sqrt(2)
  xout aLeft, aRight
endop


instr DrumMode
  ; Single mode of the drum

  iRandom gauss 1/53
  iFundFreq = p4

  ; Mode characteristics
  iM = p6
  iN = p7
  iAmp = p5
  iLife = 2 * (440/iFundFreq)^(1/2) / (iN^1.5+iM^1.5)
  iRoot BesselRoot iM, iN
  iFreq = iRoot*iFundFreq / giBesseln1[0] * (1+iRandom)

  ; Sustain all modes for their lifetime.
  if(p3<iLife) ithen
    p3 = iLife
  endif

  ; Frequency modulation parameters
  kModFreq = 0.6875 ; based on Chowning's wood drum
  kModIndex linseg 16/iRoot, (8/iFreq), 0

  ; Envelope
  kAtt linsegr 0, (1/1000), 1, (1/100), 0
  kExp expon 1.23*iAmp, iLife, iAmp/515
  kEnv = kAtt*kExp

  ; The signal
  aMono foscil kEnv, iFreq, 1, kModFreq, kModIndex, 1, 0

  iPan = p8
  aLeft, aRight pandeg aMono, iPan
  outs aLeft, aRight

  ; Use lines like these to have drum contribute to a global reverb
  ;gaReverbL += aLeft
  ;gaReverbR += aRight

endin



instr Drum
  ; A drum

  p3    = abs(p3) ; no tying
  iFreq = p4
  iAmp  = p5
  iPan  = p6

  ; Contingency for rests or error codes
  if(iFreq < 0) ithen
    iFreq = 30
    iAmp = 0
  endif

  ; Mode loop
  iMparts = 6
  iNparts = 3
  iM = 0
  loopM:
    iN = 1
    loopN:
      iModeAmp = iAmp / (iM^0.6 + iN^0.6)
      if( iModeAmp/(iAmp+0.00001) > 1/256 ) ithen
        event_i "i", "DrumMode", 0, p3, iFreq, iModeAmp, iM, iN, iPan
      endif
      loop_lt iN, 1, iNparts, loopN
    loop_lt iM, 1, iMparts, loopM

endin
