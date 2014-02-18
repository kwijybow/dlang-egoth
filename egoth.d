import std.stdio, std.string, std.array, std.conv, std.datetime, core.memory, std.file;
import move;
import bitboard;
import square;
import squares;
import flips;
import position;
import search;
import hash;
import masks;
import test;

void main (char[][] args) {
    Tree t;
    Position p;

    foreach (line; File("test.obf").byLine()) {
        p = new Position();
        InitializeRandomHash();
        InitializeHashTables();
        hash_maska=(1<<log_hash)-1;
        t = new Tree(p);
        if (setupTest(t,line)) {
            performTest(t);
            outputTestResults(t,line);
        }
    }
}
    
    