mtype = { CLIENTREQ, REPLREQ1, REPLREQ2, STORE1, STORE2, SYNC1, SYNC2, ACK };

chan server = [3] of { mtype };
chan client = [1] of { mtype };
chan node1  = [2] of { mtype };
chan node2  = [2] of { mtype };

byte RECVD1 = 0; byte RECVD2 = 0;
byte STORECOMPL1 = 0; byte STORECOMPL2 = 0;

proctype STORAGENODE1() {
    end_node1:
    do
    :: node1?REPLREQ1 -> node1!STORE1; 
    :: node1?STORE1   -> STORECOMPL1 = 1; 
    :: (STORECOMPL1 == 1)    -> server!SYNC1;
    od
}

proctype STORAGENODE2() {
    end_node2:
    do
    :: node2?REPLREQ2 -> node2!STORE2;
    :: node2?STORE2   -> STORECOMPL2 = 1;
    :: (STORECOMPL2 == 1)    -> server!SYNC2;
    od
}

proctype SERVER() {
    end_server:
    do
    :: server?CLIENTREQ -> 
        node1!REPLREQ1;
        node2!REPLREQ2;

    :: server?SYNC1 -> 
        if
        :: (RECVD1 == 0) -> 
            RECVD1 = 1;
            if
            :: (RECVD2 == 1) -> client!ACK;
            :: else -> skip;
            fi;
        :: else -> skip;
        fi;

    :: server?SYNC2 -> 
        if
        :: (RECVD2 == 0) -> 
            RECVD2 = 1;
            if
            :: (RECVD1 == 1) -> client!ACK;
            :: else -> skip;
            fi;
        :: else -> skip;
        fi;
    od
}

proctype CLIENT() {
    end_client:
    server!CLIENTREQ;
    client?ACK;
    
    assert(STORECOMPL1 == 1 && STORECOMPL2 == 1);
}

init {
    atomic {
        run STORAGENODE1();
        run STORAGENODE2();
        run SERVER();
        run CLIENT();
    }
}