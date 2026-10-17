#define N 3 /* Number of processes */

byte flag[N];    /* flag[i] is the level process i is currently in */
byte turn[N];    /* turn[L] is the victim process at level L */
byte ncrit;      /* counter to check mutual exclusion */

active [N] proctype user()
{
    byte level, k;

    do
    :: /* Entry Protocol */
       for (level : 1 .. (N - 1)) {
           flag[_pid] = level;
           turn[level] = _pid;

           /* The Generalized Guard Condition */
           for (k : 0 .. (N - 1)) {
               if
               :: (k != _pid) ->
                  /* Wait if there's another process at a higher level 
                     AND we are still the 'turn' process for this level */
                  (flag[k] < level || turn[level] != _pid);
               :: else -> skip
               fi
           }
       }

       /* Critical Section */
       ncrit++;
       assert(ncrit == 1); 
       ncrit--;

       /* Exit Protocol */
       flag[_pid] = 0;
    od
}