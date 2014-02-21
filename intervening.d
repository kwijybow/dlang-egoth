import std.string, std.stdio, std.array;
import squares;
import flips;
import bitboard;

class Intervening {
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
//            DisplayBitBoard(move);
//            writeln();
            for (int j=0; j<64; j++) {
                astones = sqs.square_list[j].mask;
//                DisplayBitBoard(astones);
//                writeln();
//                DisplayBitBoard(sqs.square_list[j].att_mask);
//                writeln;
                if (sqs.square_list[i].att_mask & astones) {
                    tstones = ~(move | astones);
                    rays[i][j] = getFlips(move, astones, tstones);
/*                    
                    writeln("j = ",j," i = ",i);
                    DisplayBitBoard(rays[j][i]);
                    writeln();
                    writeln("move");
                    DisplayBitBoard(move);
                    writeln();
                    writeln("astones");
                    DisplayBitBoard(astones);
                    writeln();
                    writeln("tstones");
                    DisplayBitBoard(tstones);
                    writeln();
*/                    
                }
            }
        } 
    }
    
    ulong getRays(int from, int to, ulong tstones) {
        ulong test = 0;
        ulong flips = 0;
        ulong ray = 0;
        
        ray = rays[from][to];
        test = ray & tstones;
/*        
        writeln("from = ",from," to = ",to);
        DisplayBitBoard(rays[from][to]);
        writeln();
        writeln("tstones");
        DisplayBitBoard(tstones);
        writeln();
        writeln("test");
        DisplayBitBoard(test);
        writeln();
*/
        test ^= ray;
//        writeln("test ^= rays");
//        DisplayBitBoard(test);
        if (test == 0)
            flips = ray;
//        writeln("flips");    
//        DisplayBitBoard(flips);
//        writeln();
        return flips;
    }
}