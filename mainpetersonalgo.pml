chan UP[2]  = [1] of { bit };
chan ACK[2] = [1] of { bit };

int turn;
int ncrit;
int flag[2];

active proctype TURNLOCK()
{
    turn  = 0;
    ncrit = 0;
    do
    :: atomic { UP[0]?0; turn = 0; ACK[0]!0 }
    :: atomic { UP[1]?0; turn = 1; ACK[1]!0 }
    od
}

active [2] proctype user()
{
    int me    = _pid - 1;   /* _pid is 1,2 because TURNLOCK is 0; adjust to 0,1 */
    int other = 1 - me;
again:
    flag[me] = 1;
    UP[me]!0;
    ACK[me]?0;

    do
    :: (turn != me)        -> break
    :: (flag[other] == 0)  -> break
    od;

    ncrit++;
    assert(ncrit == 1);
    ncrit--;

    flag[me] = 0;
    goto again
}
