mtype = { 
    CLIENTREQ, ACK, 
    REPLREQ1, REPLREQ2, REPLREQ3, REPLREQ4, 
    STORE1, STORE2, STORE3, STORE4, 
    SYNC1, SYNC2, SYNC3, SYNC4 
};

/* Isolated mailboxes for the Actor Model */
chan server = [5] of { mtype };
chan client = [1] of { mtype };
chan node1  = [2] of { mtype };
chan node2  = [2] of { mtype };
chan node3  = [2] of { mtype };
chan node4  = [2] of { mtype };

byte RECVD1 = 0; byte RECVD2 = 0; byte RECVD3 = 0; byte RECVD4 = 0;
byte STORECOMPL1 = 0; byte STORECOMPL2 = 0; byte STORECOMPL3 = 0; byte STORECOMPL4 = 0;

proctype STORAGENODE1() {
    end_node1:
    do
    :: node1?REPLREQ1 -> node1!STORE1; 
    :: node1?STORE1   -> STORECOMPL1 = 1; 
    :: (STORECOMPL1 == 1) -> server!SYNC1;
    od
}

proctype STORAGENODE2() {
    end_node2:
    do
    :: node2?REPLREQ2 -> node2!STORE2;
    :: node2?STORE2   -> STORECOMPL2 = 1;
    :: (STORECOMPL2 == 1) -> server!SYNC2;
    od
}

proctype STORAGENODE3() {
    end_node3:
    do
    :: node3?REPLREQ3 -> node3!STORE3;
    :: node3?STORE3   -> STORECOMPL3 = 1;
    :: (STORECOMPL3 == 1) -> server!SYNC3;
    od
}

proctype STORAGENODE4() {
    end_node4:
    do
    :: node4?REPLREQ4 -> node4!STORE4;
    :: node4?STORE4   -> STORECOMPL4 = 1;
    :: (STORECOMPL4 == 1) -> server!SYNC4;
    od
}

proctype SERVER() {
    end_server:
    do
    :: server?CLIENTREQ -> 
        node1!REPLREQ1;
        node2!REPLREQ2;
        node3!REPLREQ3;
        node4!REPLREQ4;

    :: server?SYNC1 -> 
        if
        :: (RECVD1 == 0) -> 
            RECVD1 = 1;
            if
            :: (RECVD2 == 1 && RECVD3 == 1 && RECVD4 == 1) -> client!ACK;
            :: else -> skip;
            fi;
        :: else -> skip;
        fi;

    :: server?SYNC2 -> 
        if
        :: (RECVD2 == 0) -> 
            RECVD2 = 1;
            if
            :: (RECVD1 == 1 && RECVD3 == 1 && RECVD4 == 1) -> client!ACK;
            :: else -> skip;
            fi;
        :: else -> skip;
        fi;

    :: server?SYNC3 -> 
        if
        :: (RECVD3 == 0) -> 
            RECVD3 = 1;
            if
            :: (RECVD1 == 1 && RECVD2 == 1 && RECVD4 == 1) -> client!ACK;
            :: else -> skip;
            fi;
        :: else -> skip;
        fi;

    :: server?SYNC4 -> 
        if
        :: (RECVD4 == 0) -> 
            RECVD4 = 1;
            if
            :: (RECVD1 == 1 && RECVD2 == 1 && RECVD3 == 1) -> client!ACK;
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
    
    assert(STORECOMPL1 == 1 && STORECOMPL2 == 1 && STORECOMPL3 == 1 && STORECOMPL4 == 1);
}

init {
    atomic {
        run STORAGENODE1();
        run STORAGENODE2();
        run STORAGENODE3();
        run STORAGENODE4();
        run SERVER();
        run CLIENT();
    }
}