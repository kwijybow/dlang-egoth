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
    int test_number = 1;
    
    InitializeRandomHash();
    InitializeHashTables();
    hash_maska=(1<<log_hash)-1;
    

    writeln("  #|depth|move|score|   time   |     nodes    | Kn/sec |"); 
    writeln("--------------------------------------------------------");
    foreach (line; File("test.obf").byLine()) {
        p = new Position();
        t = new Tree(p);
        transposition_id=(transposition_id+1)&7;
        if (!transposition_id) transposition_id++;
        
        writef("%3s",test_number);
        test_number++;
        if (setupTest(t,line)) {
            performTest(t);
            ts.add(line,t.runtime, t.pos.sqs.name(t.pos.move_list[0][0].sq_num), t.pos.move_list[0][0].score, t.nodes_searched, t.leaves_searched);
        }
    }
    outputTestResults(ts);
}
    
    