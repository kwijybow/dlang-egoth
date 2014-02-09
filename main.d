import std.stdio, std.string, std.array, std.conv, std.datetime, core.memory;
import move;
import bitboard;
import square;
import squares;
import flips;
import position;
import search;
import hash;

void main (char[][] args) {
    Position p = new Position();
    ulong nodes = 0;
    int score;
    int d;
    StopWatch timer;
    double runtime;
    Tree t;
    
    
    
    InitializeRandomHash();
    InitializeHashTables();
    hash_maska=(1<<log_hash)-1;

    p.startBoard();
    if (args.length > 1)
        d = to!int(args[1]);
    else {
        writeln("usage is perft <depth>"); 
        return;
    }
      
    t = new Tree(p);
    
    d++;
    score = iterate(t,d);
}
    
    