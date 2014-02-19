import std.stdio, std.string, std.array, std.conv;
import search;


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
    
    t.pos.printPosition();
    writeln;
    t.timer.start();
    score = MTDf(t,0); //Scout(t, t.neginf, t.posinf);        //pvsSearch(t,t.neginf,t.posinf,32,t.pos.side_to_move,t.pos.passed); //iterate(t);
    t.pos.sortMoves();
    t.timer.stop();
    t.runtime = (t.timer.peek().msecs/1000.0);
    writefln("expecting = %s", t.pos.sqs.name(t.expected_move));
    writefln("best move = %s, score = %s in %8.2f secs for %12.0f Knodes/sec", t.pos.sqs.name(t.pos.move_list[0][0].sq_num), t.pos.move_list[0][0].score, t.runtime, (t.nodes_searched/1000)/t.runtime);
    writeln;
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
    writefln("Summary for %5d Test Results", ts.results.length);
    writeln("======================================");
    writefln("total time seconds      = %12.2f",total_time);
    writefln("total nodes searched    = %12.0f",total_nodes);
    writefln("total leaves searched   = %12.0f",total_leaves);
    writefln("overall Knps            = %12.2f",(total_nodes/1000)/total_time);
    writefln("overall Klps            = %12.2f",(total_leaves/1000)/total_time);
    
}