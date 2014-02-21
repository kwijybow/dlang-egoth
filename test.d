import std.stdio, std.string, std.array, std.conv;
import search;
import bitboard;
import hash;


struct test_result {
    char[] test_position;
    double solve_time;
    string move;
    int    score;
    double leaves;
    double nodes;
    
    this (char[] line, double rt, string mv, int sc, double n, double l) {
        test_position = line;
        solve_time = rt;
        move = mv;
        score = sc;
        nodes = n;
        leaves = l;
    }    
}

class TestResults {
    test_result[int] results;
    
     void add(char[] line, double rt, string mv, int sc, double n, double l) {
         int next;
         
         next = to!int(results.length);
         results[next] = test_result(line,rt,mv,sc,n,l) ;
     }
    
}


bool setupTest(ref Tree t, char[] line) {
    int i = 0;
    bool ok = true;
    int row, col;
    
    while (i < 64) {
        switch  (line[i]) {
            case '-' :
               break;
            case 'X' :
               t.pos.dropStone(t.pos.black, t.pos.sqs.name(63-i));
               break;
            case 'O' :
               t.pos.dropStone(t.pos.white, t.pos.sqs.name(63-i)); 
               break;
            default:
               ok = false;
               break;
        }
        i++;
    }
    switch (line[65]) {
        case 'O':
            t.pos.side_to_move = t.pos.white;
            break;
        case 'X':
            t.pos.side_to_move = t.pos.black;
            break;
        default:
            ok = false;
            break;
    }
    col = line[68] - 'A';
    row = line[69] - '1';
    t.expected_move = 63 - ((row * 8) + col);
    return ok;
}

void performTest(ref Tree t) {
    int score;
    int depth;
    string sq_name;
    string pvline;
    bool ok = true;
    int alpha, beta;
    
    depth = PopCnt(~(t.pos.black_stones | t.pos.white_stones));
    t.timer.start();
    score = searchRoot(t); 
    t.pos.sortMoves();
    t.timer.stop();
    t.runtime = (t.timer.peek().msecs/1000.0);
    sq_name = t.pos.sqs.name(t.pos.move_list[0][0].sq_num);
//    for (int i=0; i<t.pv.cmove; i++) {
//        sq_name = t.pos.sqs.name(t.pv.argmove[i]);
    if (t.pos.side_to_move == t.pos.black)
        sq_name = toUpper(sq_name);
//        pvline = pvline ~ sq_name;
//        pvline = pvline ~ " ";
//        if (i > 7) 
//            break;
//    }
    writefln("| %3d | %2s | %3s | %8.2f | %12d | %6.0f |", depth, sq_name, t.pos.move_list[0][0].score, t.runtime,t.nodes_searched, (t.nodes_searched/1000)/t.runtime);
}

void outputTestResults(ref TestResults ts) {
    double total_time = 0.0;
    double total_nodes = 0.0;
    double total_leaves = 0.0;
    
    for(int i=0; i<ts.results.length; i++) {
        total_time += ts.results[i].solve_time;
        total_nodes += ts.results[i].nodes;
        total_leaves += ts.results[i].leaves;
    }
    writeln;
    writefln("Summary for %5d Test Results", ts.results.length);
    writeln("======================================");
    writefln("total time seconds      = %12.2f",total_time);
    writefln("total nodes searched    = %12.0f",total_nodes);
    writefln("total leaves searched   = %12.0f",total_leaves);
    writefln("overall Knps            = %12.2f",(total_nodes/1000)/total_time);
    writefln("overall Klps            = %12.2f",(total_leaves/1000)/total_time);
    
}