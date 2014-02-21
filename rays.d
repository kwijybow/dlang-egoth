import std.string, std.stdio, std.array;
import squares;
import flips;
import bitboard;

class Rays {
    ulong rays[64][64];
    Squares sqs;
    ulong one = 1;
    ulong astones;
    ulong tstones;
    ulong move;
    
    this() {
        sqs = new Squares();
        for (int i=0; i<64; i++) {
            move = sqs.square_list[i].mask;
            for (int j=0; j<64; j++) {
                astones = sqs.square_list[j].mask;
                if (sqs.square_list[i].att_mask & astones) {
                    tstones = ~(move | astones);
                    rays[i][j] = getFlips(move, astones, tstones);
                }
            }
        } 
    }
    
}