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
    TestResults ts = new TestResults();
    

    foreach (line; File("test.obf").byLine()) {
        p = new Position();
        InitializeRandomHash();
        InitializeHashTables();
        hash_maska=(1<<log_hash)-1;
        t = new Tree(p);
        if (setupTest(t,line)) {
            performTest(t);
            ts.add(line,t.runtime, t.pos.sqs.name(t.pos.move_list[0][0].sq_num), t.pos.move_list[0][0].score, t.nodes_searched, t.leaves_searched);
        }
    }
    outputTestResults(ts);
}
    
    