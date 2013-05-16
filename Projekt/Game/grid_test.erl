-module(grid_test).

-include_lib("eunit/include/eunit.hrl"). 

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
