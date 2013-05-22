%% @author Linkan

-module(grid).

-export([matrix/1,find_elem/3, change_elem/4, move_elem_down/4, move_elem_up/4, move_elem_l/4, move_elem_r/4,check_elem/3, check_boundry/1]).

%% To use EUnit we must include this:
-include_lib("eunit/include/eunit.hrl").

%% @doc Creates a matrix with size of Size*Size
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

%% @doc Finds the element given by Row and Column in Matrix.
find_elem(Row,Column,Matrix) ->
    Y = lists:nth(Row,Matrix),
    X = lists:nth(Column,Y),
    X.

%% @doc Change the element given by Row and Column in Matrix to Elem.
change_elem(Elem, Row, Column, Matrix) ->
    B = lists:nth(Row, Matrix),
    C = setelement(Column, (list_to_tuple(B)),{Elem}),
    D = setelement(Row,(list_to_tuple(Matrix)),tuple_to_list(C)),
    E = tuple_to_list(D),
    E.

%% @doc Move Elem in Matrix down one step.
move_elem_down(Elem, Row, Column, Matrix ) ->
    Y = Row + 1,  
    A = change_elem(Elem, Y, Column, Matrix),
    B = change_elem(0, Row, Column, A),
    B.
  
%% @doc Move Elem in Matrix up one step.
move_elem_up(Elem, Row, Column, Matrix) ->
    Y = Row -1,
    A = change_elem(Elem, Y, Column, Matrix),
    B = change_elem(0, Row, Column, A),
    B.

%% @doc Move Elem in Matrix one step to the right.
move_elem_r(Elem, Row, Column, Matrix) ->
    X = Column +1,
    A = change_elem(Elem, Row, X,Matrix),
    B = change_elem(0, Row, Column, A),
    B.

%% @doc Move Elem in Matrix to the left one step.
move_elem_l(Elem, Row, Column, Matrix) ->
    X = Column -1,
    A = change_elem(Elem, Row, X,Matrix),
    B = change_elem(0, Row, Column, A),
    B.

%% @doc Check the status of the given coordinates in the Matrix.
check_elem(Row, Column, Matrix) ->
    R = check_boundry(Row),
    C = check_boundry(Column),
    
    if (R == {true} andalso C == {true}) ->

	S = find_elem(Row, Column, Matrix),
	if S == {0} ->
		{true,0};
	   S == {1} ->
 		{false,1};
	   S == {2} ->
		{false,2};
	   S == {3} ->
		{false,3};
	   true -> {false,4} %% SKA VARA EN FYRA!
	end;
   true ->
	{false,boundry}
end.


%% @doc Check if Point is inside the boundry.
check_boundry(Point) ->
    if (Point < 52 andalso Point > 0) ->
	     {true};
	true ->
	     {false}
     end.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                         EUnit Test Cases                                  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% EUnit adds the grid:test() function to this module. 

%% All functions with names ending wiht _test() or _test_() will be
%% called automatically by grid:test()


matrix_new_test_() ->
    [?_assertEqual((grid:matrix(0)),[]),
     ?_assertEqual((grid:matrix(1)),[[{0}]]),
     ?_assertEqual((grid:matrix(5)),[[{0},{0},{0},{0},{0}],
				     [{0},{0},{0},{0},{0}],
				     [{0},{0},{0},{0},{0}],
				     [{0},{0},{0},{0},{0}],
				     [{0},{0},{0},{0},{0}]])].
find_elem_test_() ->
    Matrix = grid:matrix(5),
    Inserted  = grid:change_elem(1,2,2,Matrix),
    [?_assertEqual((grid:find_elem(2,2,Matrix)),{0}),
     ?_assertEqual((grid:find_elem(2,2,Inserted)),{1})].

change_elem_test_() ->
    Matrix = grid:matrix(2),
    [?_assertEqual((grid:change_elem(1,2,2,Matrix)),[[{0},{0}],
						     [{0},{1}]]),
     ?_assertEqual((grid:change_elem(3,1,1,Matrix)),[[{3},{0}],
						     [{0},{0}]])].

move_elem_down_test_() ->
    Matrix1 = grid:matrix(5),
    Matrix2 = grid:change_elem(2,2,2,Matrix1),
    [?_assertEqual((grid:move_elem_down(2,2,2,Matrix2)),[[{0},{0},{0},{0},{0}],
							 [{0},{0},{0},{0},{0}],
							 [{0},{2},{0},{0},{0}],
							 [{0},{0},{0},{0},{0}],
							 [{0},{0},{0},{0},{0}]])].
move_elem_up_test_() ->
    Matrix1 = grid:matrix(5),
    Matrix2 = grid:change_elem(1,2,2,Matrix1),
    [?_assertEqual((grid:move_elem_up(1,2,2,Matrix2)),[[{0},{1},{0},{0},{0}],
						       [{0},{0},{0},{0},{0}],
						       [{0},{0},{0},{0},{0}],
						       [{0},{0},{0},{0},{0}],
						       [{0},{0},{0},{0},{0}]])].
move_elem_l_test_() ->
    Matrix1 = grid:matrix(5),
    Matrix2 = grid:change_elem(3,5,3,Matrix1),
    [?_assertEqual((grid:move_elem_l(3,5,3,Matrix2)),[[{0},{0},{0},{0},{0}],
						      [{0},{0},{0},{0},{0}],
						      [{0},{0},{0},{0},{0}],
						      [{0},{0},{0},{0},{0}],
						      [{0},{3},{0},{0},{0}]])].
move_elem_r_test_() ->
    Matrix1 = grid:matrix(5),
    Matrix2 = grid:change_elem(3,5,3,Matrix1),
    [?_assertEqual((grid:move_elem_r(3,5,3,Matrix2)),[[{0},{0},{0},{0},{0}],
						      [{0},{0},{0},{0},{0}],
						      [{0},{0},{0},{0},{0}],
						      [{0},{0},{0},{0},{0}],
						      [{0},{0},{0},{3},{0}]])].
check_boundry_test_() ->
    [?_assertMatch({true}, grid:check_boundry(5)),
     ?_assertMatch({true}, grid:check_boundry(1)),
     ?_assertMatch({true}, grid:check_boundry(10)),
     ?_assertMatch({false},grid:check_boundry(11)),
     ?_assertMatch({false},grid:check_boundry(0))].

check_elem_test_() ->
    Matrix = grid:matrix(5),
    Matrix1 = grid:change_elem(1,2,2,Matrix),
    Matrix2 = grid:change_elem(2,3,5,Matrix),
    Matrix3 = grid:change_elem(3,5,3,Matrix),
    Matrix4 = grid:change_elem(5,3,3,Matrix),
    [?_assertMatch({true,0},grid:check_elem(2,2,Matrix)),
     ?_assertMatch({false,1},grid:check_elem(2,2,Matrix1)),
     ?_assertMatch({false,2},grid:check_elem(3,5,Matrix2)),
     ?_assertMatch({false,3},grid:check_elem(5,3,Matrix3)),
     ?_assertMatch({false,4},grid:check_elem(3,3,Matrix4))].
