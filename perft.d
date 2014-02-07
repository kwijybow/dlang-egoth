import std.stdio, std.string, std.array, std.conv, std.datetime;
import move;
import bitboard;
import square;
import squares;
import flips;
import position;
import search;

void main (char[][] args) {
    Position p = new Position();
    ulong nodes = 0;
    int score;
    int d;
    StopWatch timer;
    double runtime;
    Tree t;

    

    p.startBoard();
    if (args.length > 1)
        d = to!int(args[1]);
    else {
        writeln("usage is perft <depth>"); 
        return;
    }
      
    t = new Tree(p);
    
    d++;
    for (int n=1; n<d; n++) {
        t.nodes_searched = 0;
        t.leaves_searched = 0;
        writef("pvsSearch(%2d)", n);
        timer.start();
        score = pvsSearch(t,-128,128,n,t.pos.side_to_move,false);
//        writef("%4d",score);
        nodes = t.nodes_searched;
        t.pos.sortMoves();
        writef(" move %4s",t.pos.move_list[t.pos.position_index][0].sq_name);
        timer.stop();
        runtime = (timer.peek().msecs/1000.0);
        writefln("%5d score %12d nodes in %8.2f seconds for %12.0f nodes/sec",t.pos.move_list[t.pos.position_index][0].score, nodes, runtime, (nodes/runtime));
//        t.pos.printMoveList();
    }
}
    
    