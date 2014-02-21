import std.string, std.stdio;
import bitboard;

class Move {
    int sq_num;
    string sq_name;
    ulong mask;
    ulong flips;
    int score;
    
    this() {
        sq_num = 0;
        sq_name = "";
        mask = 0;
        flips = 0;
        score = 0;
    }
    
    this(int sq, string name, ulong m, ulong f) {
        sq_num = sq;
        sq_name = name;
        mask = m;
        flips = f;
        score = 0;
    }
    
    void printMove() {
        writeln("MOVE");
        writeln("move as follows");
        writeln("sq_num ", sq_num, " name ", sq_name);
        writeln("mask");
        DisplayBitBoard(mask);
        writeln("flips");
        DisplayBitBoard(flips);
        writeln();
    }
}    
