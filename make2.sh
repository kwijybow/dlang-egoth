gdc -m64 -c -Wall -pipe -fbranch-probabilities -fomit-frame-pointer -O3 -march=k8 egoth.d move.d square.d squares.d flips.d position.d bitboard.d rays.d search.d hash.d masks.d test.d
gdc egoth.o move.o square.o squares.o flips.o position.o bitboard.o rays.o search.o hash.o masks.o test.o -o egoth
