import std.stdio, std.string, std.array, std.conv, std.datetime, std.range;
//import std.algorithm;
import move;
import bitboard;
import square;
import squares;
import flips;
import position;
import search;
import hash;


bool processMove (ref Tree t, string move) {
    bool found = false;
    
    t.pos.generateRayMoves();
    for (int m=0; m<t.pos.num_moves[t.pos.position_index]; m++) {
        if (t.pos.move_list[t.pos.position_index][m].sq_name == move) {
            t.pos.makeMove(t.pos.move_list[t.pos.position_index][m]);
            if (t.pos.side_to_move == t.pos.black) 
                writefln("white (human) moves %s",move);
            else
                writefln("black (human) moves %s",move); 
            found = true;
            break;
            }
        }
        return (found);
}

void processComputerMove (ref Tree t) {
        int score;
        bool passed = false;

        t.timer.reset();
        t.timer.start();
        score = iterate(t);
        if (t.pos.num_moves[t.pos.position_index] > 0) 
            t.pos.makeMove(t.pos.move_list[t.pos.position_index][0]);
        else {
            if (!passed) {
                t.pos.makePass();
                passed = true;
            }
            else {
                t.pos.eog = true;
                return;
            }
        }
        if (t.pos.side_to_move == t.pos.black) 
            if (passed) 
                write("white (computer) passes ");
            else
                write("white (computer) moves ");
        else
            if (passed)
                write("black (computer) passes ");
            else
                write("black (computer) moves ");
        if (!passed)        
            writef(" %s, score %d ", t.pos.move_list[t.pos.position_index-1][0].sq_name, score);
        t.timer.stop();
        t.runtime = (t.timer.peek().msecs/1000.0);
        writefln("in %8.2f secs",t.runtime);
        t.game_time_used += t.runtime;
}

bool processCommand (ref Tree t, string command) {
    ulong nodes = 0;
    int score;
    int d;
    StopWatch timer;
    double runtime;
    bool found;
    string move;
    
    auto c = splitter(command);
    if (c.front == "quit") 
        return(true);
    if (c.front == "perft") {
        c.popFront();
        if (!c.empty) { 
            if (c.front[0] >= '0' && c.front[0] <= '9') {
                d = to!int(c.front);
                d++;
                for (int n=1; n<d; n++) {
                    t.nodes_searched = 0;
                    t.leaves_searched = 0;
                    writef("perft(%2d)", n);
                    timer.start();
                    nodes = t.pos.perft(n,false);
                    timer.stop();
                    runtime = (timer.peek().msecs/1000.0);
                    writefln("%12d nodes in %8.2f seconds for %12.0f nodes/sec", nodes, runtime, (nodes/runtime));
                    timer.reset();
                }
            }
            else
                writeln("usage is perft <depth>");
        }
        else 
            writeln("usage is perft <depth>");
        return(false);
    }
    if (c.front == "search") {
        score = iterate(t);
        return(false);
    }
    if (c.front == "go") {
        processComputerMove(t);
        return(false);
    }
    if (c.front == "play") {
        while (!t.pos.eog) {
            writeln("moves left = ", PopCnt(~(t.pos.white_stones | t.pos.black_stones)));
            processComputerMove(t);
            t.pos.printPosition();
        }
        return(false);
    }
    if (c.front == "time") {
        writefln("time remaining = %8.2f", t.time_for_game - t.game_time_used);
        writefln("time used      = %8.2f", t.game_time_used);
        return(false);
    }
    if (c.front == "show") {
        t.pos.printPosition();
        return (false);
    }
    if (c.front >= "a1" && c.front <= "h8") {
        found = processMove(t,c.front);
        if (!found)
            writeln("not a legal move");
        return (false);
    }
    if (c.front >= "A1" && c.front <= "H8") {
        move = toLower(c.front);
        found = processMove(t,move);
        if (!found)
            writeln("not a legal move");
        return (false);
    }
    writeln (command,"Command not understood");
    return(false);
}

void getCommand (ref Tree t) {
    string command, response;
    bool quit = false;
        
    while (quit != true) {
        writef("stinkbug=> ");
        command = readln();
        quit = processCommand(t,command);
    }

}

