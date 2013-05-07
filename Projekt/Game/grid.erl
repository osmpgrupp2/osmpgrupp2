-module(grid).

-export([matrix/1,find_elem/3, change_elem/4, move_elem_down/4, move_elem_up/4, move_elem_l/4, move_elem_r/4,check_elem/3]).

%% To use EUnit we must include this:
-include_lib("eunit/include/eunit.hrl").

matrix(Size) ->
 
    lists:map(
      fun(X) ->
	      lists:map(
		fun(Y) ->
			case Y of 
			    X ->{0};
			    _ ->{0}
			end
		end,
		lists:seq(0,Size-1))
      end,
      lists:seq(0,Size-1)).

find_elem(Row,Column,Matrix) ->
    Y = lists:nth(Row,Matrix),
    X = lists:nth(Column,Y),
    X.

change_elem(Elem, Row, Column, Matrix) ->
    B = lists:nth(Row, Matrix),
    C = setelement(Column, (list_to_tuple(B)),{Elem}),
    D = setelement(Row,(list_to_tuple(Matrix)),tuple_to_list(C)),
    E = tuple_to_list(D),
    E.
    
move_elem_down(Elem, Row, Column, Matrix ) ->
    Y = Row + 1,   
    A = change_elem(Elem, Y, Column, Matrix),
    B = change_elem(0, Row, Column, A),
    B.

move_elem_up(Elem, Row, Column, Matrix) ->
    Y = Row -1,
    A = change_elem(Elem, Y, Column, Matrix),
    B = change_elem(0, Row, Column, A),
    B.

move_elem_r(Elem, Row, Column, Matrix) ->
    X = Column +1,
    A = change_elem(Elem, Row, X,Matrix),
    B = change_elem(0, Row, Column, A),
    B.

move_elem_l(Elem, Row, Column, Matrix) ->
    X = Column -1,
    A = change_elem(Elem, Row, X,Matrix),
    B = change_elem(0, Row, Column, A),
    B.

check_elem(Row, Column, Matrix) ->
    S = find_elem(Row, Column, Matrix),
    if S == {0} ->
	    {true,0};
       S == {1} ->
	    {false,1};
       S == {2} ->
	    {false,2};
       S == {3} ->
	    {false,3};
       true -> {false,4}
    end.



