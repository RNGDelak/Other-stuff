# Transfinite PrSS (TPrSS)

This based off PrSS, so you should know thier definition first

1) Sequence division 

Each sequence in TPrSS is a sequence of Ordinal, where each terms can be a TPrSS term itself

for all seq in TPrSS, we have

seq = G + B + Last

Where

G is seq with B and Last truncated 

B is the bad root

Last is the final terms

2) Bad root finding

the bad root (B) is part from the rightmost element that is strictly smaller than Last, up to the element before the Last

If there none, B = [empty]

eg: seq = 0,1,2,3,4,3

B = 2,3,4

eg: seq = 0,1,2,3,4,1

B = 0,1,2,3,4

eg: seq = 0,1,2,3,4,5

B = 4

eg: seq = 0,1,2,3,0

B = [empty]

the same work for ordinals, as comparing ordinals altogether

3) Sequence comparison 

to make section 2 clearer, Sequence comparison is **Iteratively Lexicographic**

eg: 0,1,2 < 0,1,2,3

eg: 0,1,2,3 > 0,1,2,2,2,2

eg: 0,1,[0,1] > 0,1,99999 

since 0,1 > [0,0,0,0,0,0,...(99999 zeros)] = 99999

4) Sequence Expansion 