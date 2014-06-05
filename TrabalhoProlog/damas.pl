playO(B) :-
      init(B).
      
min_to_move(x/_).
max_to_move(o/_).
      

play(_, _, Board,NewBoard,_) :-
           goal(Board, Sign),
           NewBoard=b(Sign),!.


play(human, Sign, Board, NewBoard,Move) :-
     process(Sign, Move, Board,NewBoard),!.



play(human, Sign, Board,NewBoard,Move) :-
     NewBoard=b(i).
     


play(comp, Sign, Board,NewBoard,Depth) :-
     alphabeta(Sign/Board, -100, 100, Next/NewBoard, _, Depth).


process(Sign, FromL/FromC-ToL/ToC, Board,NewBoard) :-
              move(Board, FromL, FromC, ToL, ToC, NewBoard).


sign( x, x).
sign( c, 'X').
sign( o, o).
sign( p, 'O').
sign( e, ' ').
sign( n, '-').


getPos( Board, Line, Col, Sign) :-
        Num is ((Line - 1) * 8) + Col,
        myArg2(Num, Board, Sign).

getSign( Board, Line, Col, Sign) :-
         getPos(Board, Line, Col, S),
         sign(S, Sign).




turn_to_sign(x, x).
turn_to_sign(x, c).
turn_to_sign(o, o).
turn_to_sign(o, p).

prox_player(x, o).
prox_player(o, x).

king_sign(x, c).
king_sign(o, p).


enemy(o, x).
enemy(o, c).
enemy(x, o).
enemy(x, p).
enemy(p, x).
enemy(p, c).
enemy(c, o).
enemy(c, p).


init( Board) :-
      Board = b(n,x,n,x,n,x,n,x,x,n,x,n,x,n,x,n,n,x,n,x,n,x,n,x,e,n,e,n,e,n,e,n,n,e,n,e,n,e,n,e,o,n,o,n,o,n,o,n,n,o,n,o,n,o,n,o,o,n,o,n,o,n,o,n).

putSign( Board, 8, Col, x, NewBoard) :-
         putSign(Board, 8, Col, c, NewBoard),!.

putSign( Board, 1, Col, o, NewBoard) :-
         putSign(Board, 1, Col, p, NewBoard),!.

putSign( Board, Line, Col, Sign, NewBoard) :-
         Place is ((Line - 1) * 8) + Col,
         Board =.. [b|List],
         replace(List, Place, Sign, NewList),
         NewBoard =.. [b|NewList].

replace( List, Place, Val, NewList) :-
         replace(List, Place, Val, NewList, 1).
replace( [], _, _, [], _).
replace( [_|Xs], Place, Val, [Val|Ys], Place) :-
         NewCounter is Place + 1, !,
         replace(Xs, Place, Val, Ys, NewCounter).

replace( [X|Xs], Place, Val, [X|Ys], Counter) :-
         NewCounter is Counter + 1,
         replace(Xs, Place, Val, Ys, NewCounter).

getPawn( Board, Line, Col, P) :-
         getPos( Board, Line, Col, P),
         (P = x ; P = c ; P = o ; P = p).


count( Board, Sign, Res) :-
       Board =.. [b|List],
       countL(List, Sign, Res, 0).

countL( [], _, Res, Res) :- !.
countL( [Sign|Xs], Sign, Res, Counter) :-
        !, Counter1 is Counter + 1,
        countL(Xs, Sign, Res, Counter1).
countL( [_|Xs], Sign, Res, Counter) :-
        countL(Xs, Sign, Res, Counter).



goal( Board, Winner) :-
      prox_player(Winner, Looser),
      findall(NewBoard, (turn_to_sign(Looser,Sign),validMove(Board, Sign, NewBoard)), []),!.



move( Board, FromL, FromC, ToL, ToC, NewBoard) :-
      getPawn(Board, FromL, FromC, P),
      turn_to_sign(T, P),!,
      validMove(Board, T, NewBoard),
      (movePawnEatRec(Board, P, FromL, FromC, ToL, ToC, NewBoard) ;
      movePawn(Board, P, FromL, FromC, ToL, ToC, NewBoard)).


movePawn( Board, Pawn, FromL, FromC, ToL, ToC, NewBoard) :-
          validateMove(Board, Pawn, FromL, FromC, ToL, ToC),
          putSign(Board, FromL, FromC, e, TB),
          putSign(TB, ToL, ToC, Pawn, NewBoard).


movePawnEatRec( Board, Pawn, FromL, FromC, ToL, ToC, NewBoard) :-
          movePawnEat( Board, Pawn, FromL, FromC, ToL, ToC, NewBoard).

movePawnEatRec( Board, Pawn, FromL, FromC, ToL, ToC, NewBoard) :-
          ((Pawn = x ; Pawn = c ; Pawn = p),
          FromL1 is FromL + 2 ;
          (Pawn = o ; Pawn = c ; Pawn = p),
          FromL1 is FromL - 2),
          FromC1 is FromC + 2,
          FromC2 is FromC - 2,
          (movePawnEat( Board, Pawn, FromL, FromC, FromL1, FromC1, TempBoard),
          movePawnEatRec( TempBoard, Pawn, FromL1, FromC1, ToL, ToC, NewBoard) ;
          movePawnEat( Board, Pawn, FromL, FromC, FromL1, FromC2, TempBoard),
          movePawnEatRec( TempBoard, Pawn, FromL1, FromC2, ToL, ToC, NewBoard)).


movePawnEat( Board, Pawn, FromL, FromC, ToL, ToC, NewBoard) :-
          validateEat(Board, Pawn, FromL, FromC, ToL, ToC),
          getPos(Board, ToL, ToC, e),
          EC1 is (FromC + ToC) / 2,
          EL1 is (FromL + ToL) / 2,
          myAbs(EC1, EC), myAbs(EL1, EL),
          putSign(Board, FromL, FromC, e, TB1),
          putSign(TB1, EL, EC, e, TB2),
          putSign(TB2, ToL, ToC, Pawn, NewBoard).


validateEat( Board, King, FromL, FromC, ToL, ToC) :-
             (King = c ; King = p),
             ToL >= 1, ToC >= 1,
             FromL =< 8, FromL =< 8,
             (ToL is FromL - 2 ;
              ToL is FromL + 2),
             (ToC is FromC + 2 ;
              ToC is FromC - 2),
             EL is (ToL + FromL) / 2,
             EC is (ToC + FromC) / 2,
             enemy(King, Enemy),
             getPawn(Board, EL, EC, Enemy).

validateEat( Board, x, FromL, FromC, ToL, ToC) :-
             ToL >= 1, ToC >= 1,
             FromL =< 8, FromL =< 8,
             ToL is FromL + 2,
             (ToC is FromC + 2 ;
              ToC is FromC - 2),
              EL is (ToL + FromL) / 2,
              EC is (ToC + FromC) / 2,
              enemy(x, Enemy),
              getPawn(Board, EL, EC, Enemy).

validateEat( Board, o, FromL, FromC, ToL, ToC) :-
             ToL >= 1, ToC >= 1,
             FromL =< 8, FromL =< 8,
             ToL is FromL - 2,
             (ToC is FromC + 2 ;
              ToC is FromC - 2),
              EL is (ToL + FromL) / 2,
              EC is (ToC + FromC) / 2,
              enemy(o, Enemy),
              getPawn(Board, EL, EC, Enemy).


validateMove( Board, King, FromL, FromC, ToL, ToC) :-
              (King = c ; King = p),
              ToL >= 1, ToC >= 1,
              FromL =< 8, FromL =< 8,
              (ToL is FromL + 1 ;
               ToL is FromL - 1),
              (ToC is FromC + 1 ;
               ToC is FromC - 1),
               getPos(Board, ToL, ToC, e).

validateMove( Board, x, FromL, FromC, ToL, ToC) :-
              ToL >= 1, ToC >= 1,
              FromL =< 8, FromL =< 8,
              ToL is FromL + 1,
              (ToC is FromC + 1 ;
               ToC is FromC - 1),
               getPos(Board, ToL, ToC, e).

validateMove( Board, o, FromL, FromC, ToL, ToC) :-
              ToL >= 1, ToC >= 1,
              FromL =< 8, FromL =< 8,
              ToL is FromL - 1,
              (ToC is FromC + 1 ;
               ToC is FromC - 1),
               getPos(Board, ToL, ToC, e).

findPawn( Board, S, Line, Col) :-
          myArg(Num,Board,S),
          Temp is Num / 8,
          myCeiling(Temp, Line),
          Col is Num - ((Line - 1) * 8).


validEatMove( Board, Sign, NewBoard) :-
           findPawn(Board, Sign, L, C),findPawn(Board, e, Tl, Tc),
           movePawnEatRec(Board, Sign, L, C, Tl, Tc, NewBoard).


validStdMove( Board, Sign, NewBoard) :-
              findPawn(Board, Sign, L, C),findPawn(Board, e, Tl, Tc),
              movePawn(Board, Sign, L, C, Tl, Tc, NewBoard).


validMove( Board, Turn, NewBoard) :-
           turn_to_sign(Turn, Sign),
           validEatMove(Board, Sign, NewBoard).


validMove( Board, Turn, NewBoard) :-
           not((turn_to_sign(Turn, Sign),
           validEatMove(Board, Sign, NewBoard))),
           turn_to_sign(Turn, Sign1),
           validStdMove(Board, Sign1, NewBoard).



alphabeta( Pos, Alpha, Beta, GoodPos, Val, Depth) :-
           Depth > 0, moves( Pos, PosList), !,
           boundedbest( PosList, Alpha, Beta, GoodPos, Val, Depth);
           staticval( Pos, Val).        % Static value of Pos

boundedbest( [Pos|PosList], Alpha, Beta, GoodPos, GoodVal, Depth) :-
             Depth1 is Depth - 1,
             alphabeta( Pos, Alpha, Beta, _, Val, Depth1),
             goodenough( PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal, Depth).

goodenough( [], _, _, Pos, Val, Pos, Val, _) :- !.    

goodenough( _, Alpha, Beta, Pos, Val, Pos, Val, _) :-
            min_to_move( Pos), Val > Beta, !;       
            max_to_move( Pos), Val < Alpha, !.     

goodenough( PosList, Alpha, Beta, Pos, Val, GoodPos, GoodVal, Depth) :-
            newbounds( Alpha, Beta, Pos, Val, NewAlpha, NewBeta),       
            boundedbest( PosList, NewAlpha, NewBeta, Pos1, Val1, Depth),
            betterof( Pos, Val, Pos1, Val1, GoodPos, GoodVal).

newbounds( Alpha, Beta, Pos, Val, Val, Beta) :-
           min_to_move( Pos), Val > Alpha, !.        

newbounds( Alpha, Beta, Pos, Val, Alpha, Val) :-
           max_to_move( Pos), Val < Beta, !.         

newbounds( Alpha, Beta, _, _, Alpha, Beta).          

betterof( Pos, Val, _, Val1, Pos, Val) :-         
          min_to_move( Pos), Val > Val1, !;
          max_to_move( Pos), Val < Val1, !.

betterof( _, _, Pos1, Val1, Pos1, Val1).             



moves( Turn/Board, [X|Xs]) :-
       prox_player(Turn, NextTurn),
       findall(NextTurn/NewBoard, validMove(Board, Turn, NewBoard), [X|Xs]).

staticval( _/Board, Res) :-
           max_to_move(Comp/_),
           min_to_move(Human/_),
           count( Board, Comp, Res1),
           count( Board, Human, Res2),
           king_sign(Comp, CompK),
           king_sign(Human, HumanK),
           count(Board, CompK, Res1k),
           count(Board, HumanK, Res2k),
           king_bonus(Board, CompK, Bonus),
           Res is (Res1 + (Res1k * 1.4)) - (Res2 + (Res2k * 1.4)) + Bonus.

king_bonus( Board, Sign, Bonus) :-
            findall(L/C, findPawn(Board, Sign, L, C), List),!,
            king_bonusL( List, Bonus, 0).

king_bonusL( [], Bonus, Bonus).
king_bonusL( [L/C|Xs], Bonus, Agg) :-
             ((L > 2, L < 7, B1 is 0.4,!) ;
             B1 is 0),
             ((C > 2, C < 7, B2 is 0.2,!) ;
             B2 is 0),
             Agg1 is Agg + B1 + B2,
             king_bonusL(Xs, Bonus, Agg1).

                         

isElem([H|C],H).
isElem([_|C],H):-isElem(C,H).


myArg(Num,Board,S):-
      isElem([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64],Num),
      arg(Num,Board,S).


myArg2(Num, Board, S):- arg(Num, Board, o), S=o.
myArg2(Num, Board, S):- arg(Num, Board, x), S=x.
myArg2(Num, Board, S):- arg(Num, Board, c), S=c.
myArg2(Num, Board, S):- arg(Num, Board, p), S=p.
myArg2(Num, Board, S):- arg(Num, Board, n), S=n.
myArg2(Num, Board, S):- arg(Num, Board, e), S=e.

myCeiling(X,L):-L is ceiling(X).

myAbs(X,L):-L is abs(X).