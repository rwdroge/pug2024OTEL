DEFINE VARIABLE happ AS HANDLE.
DEFINE VARIABLE retok AS LOGICAL.

CREATE SERVER happ.

retok = happ:CONNECT("-URL http://localhost:8810/apsv", "" , "").

MESSAGE retok
    VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
                                              
RUN procinterne.
    
RUN pasoe_span2.p ON happ.

PROCEDURE procinterne:
PAUSE RANDOM(1, 3).

END.
