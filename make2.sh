gdc -m64 -c -Wall -pipe -fbranch-probabilities -fomit-frame-pointer -O3 -march=k8 perft.d move.d square.d squares.d flips.d position.d bitboard.d rays.d
gdc perft.o move.o square.o squares.o flips.o position.o bitboard.o rays.o -o perft
