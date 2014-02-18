import std.stdio, std.string, std.array, std.conv;
import search;


bool setupTest(ref Tree t, char[] line) {
    int i = 0;
    bool ok = true;

    while (i < 64) {   
        switch  (line[i]) {
            case '-' :
               break;
            case 'X' :
               t.pos.dropStone(t.pos.black, t.pos.sqs.name(i));
               break;
            case 'O' :
               t.pos.dropStone(t.pos.white, t.pos.sqs.name(i)); 
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
    return ok;
}

void performTest(ref Tree t) {
    int score;
    
    t.pos.printPosition();
    score = pvsSearch(t,t.neginf,t.posinf,32,t.pos.side_to_move,t.pos.passed); //iterate(t);
    writeln("score = ",score);
    writeln;
}

void outputTestResults(ref Tree t, char[] line) {
}