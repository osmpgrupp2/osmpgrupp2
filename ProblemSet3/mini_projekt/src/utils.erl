%% @author Karl Marklund <karl.marklund@it.uu.se>

%% @doc A small collection of utility functions. 


-module(utils). 

-export([seqs/1, filter/2, split/2]).

%% To use EUnit we must include this.
-include_lib("eunit/include/eunit.hrl").

-compile(export_all). 


%% @doc Generates a list of lists of increasing sequences of integers
%% starting with the empty list and ending with [1,2, ..., N].
%% === Example ===
%% <div class="example">```
%% > utils:seqs(5).
%% [[],[1],[1,2],[1,2,3],[1,2,3,4],[1,2,3,4,5]]'''
%% </div>
-spec seqs(N::integer()) -> [[integer()]].

seqs(N) ->
    %% NOTE: Simply using a list comprehension such as [[]] ++
    %% [lists:seq(1,M) || M <- lists:seq(1,N)] will be quite slow
    %% since each sequence is generated from scratch. Hence, lets
    %% re-use the last sequnece and add a new element when
    %% constructing the next sequence.
    
    F = fun(X,[H|T]) -> [[X|H],H|T] end,
    lists:foldl(F, [[]], lists:seq(1,N)),
    lists:reverse([lists:reverse(L) || L <- lists:foldl(F, [[]], lists:seq(1,N))]).

		
%% @doc Each list in List2 contains the elements Elem in List1 for
%% which one of the Pred(Elem) returns true. The order of the lists in
%% List2 is the same as the order of the predicates. In each list in
%% List2, the relative order of the elements are the same as in the
%% original List1. 
%% 
%% === Example ===
%% <div class="example">```
%% 1> L = [1,2,3,4,5,6,7,8,9,10].
%% [1,2,3,4,5,6,7,8,9,10]
%% 2> P1 = fun(X) -> X rem 2 == 1 end.
%% #Fun<erl_eval.6.111823515>  
%% 3> P2 = fun(X) -> not P1(X) end. 
%% #Fun<erl_eval.6.111823515>
%% 4> P3 = fun(X) -> X > 3 andalso X < 7 end. 
%% #Fun<erl_eval.6.111823515>
%% 5> utils:filter([P1,P2,P3], L).
%% [[1,3,5,7,9],[2,4,6,8,10],[4,5,6]]'''
%% </div>
-spec filter(Preds, List1) -> List2 when
      Preds :: [Pred],
      Pred :: fun((Elem :: T) -> boolean()),
      List1 :: [T],
      List2 :: [[T]],
      T :: term().

filter(Predicates, List) ->
    Collect = self(),
    [spawn(fun() -> Collect!{I,lists:filter(P,List)} end) ||
	{I, P} <- lists:zip(lists:seq(1, length(Predicates)), Predicates)],
    
    filter_collect(length(Predicates), []).

filter_collect(0,R) ->
    [L || {_,L} <- lists:sort(R)];
filter_collect(N,R) ->
    receive
	{I, L} -> filter_collect(N-1, [{I,L}|R])
    end.



lqr(L, N) ->
    Len = length(L),

    %% Quotient
    Q = Len div N, 
    
    %% Reminder
    R = Len rem N, 
    
    {Len, Q, R}. 

%% @doc Split List into N Lists such that all Lists have approximately the same number of elements. 
%% 
%% Let Len = length(List), Q = Len div N and R = Len rem N. 
%% 
%% If R = 0, then all of the lists in Lists will be of length Q. 
%% 
%% If R =/= 0, then R of the lists in Lists will have
%% lenght Q + 1. 
%% 
%% === Example ===
%% 
%% <div class="example">```
%% 1> L = [1,2,3,4,5,6,7,8,9,10].
%% [1,2,3,4,5,6,7,8,9,10]
%% 2> utils:split(L, 4).
%% [[1,2],[3,4],[5,6,7],[8,9,10]]
%% 3> lists:concat(utils:split(L,3)).
%% [1,2,3,4,5,6,7,8,9,10]'''
%% </div>
-spec split(List, N) -> Lists when
      List :: [T],
      Lists :: [List],
      T :: term(),
      N :: integer().


korta([L|LS], Len, Listan, Count) ->
    if 	Len =:= Count ->
	    {[L|LS], Listan};
	true ->
	    korta(LS, Len, [L]++Listan, Count+1)
    end;
korta([], _, Listan, _) ->
    {[], Listan}.
    


dela([], _, T) ->
    T;
dela(L, Len, T) ->
    Tuppler = korta(L, Len, [],0),
    Listan = element(1, Tuppler),
    Bit = element(2, Tuppler),
    dela(Listan, Len, [Bit]++T).


split(L, N) ->
    Len = length(L) div N,
    dela(L, Len, []).


%% @doc converts an integer to a list with the numbers in that base
%% example: listigt(1234, 10, []) = [1,2,3,4].
listigt(0, _, List) ->
List;
listigt(N, Bas, List) ->
listigt((N div Bas),Bas, [(N rem Bas)] ++ List).

%% @doc adds zeros to list A and B so they are both the same length
%% and their length is evenly dividable with N
nolligt(A,B,N) ->
if
((length(A)) =:= length(B)) ->
{add_zero(A,N),add_zero(B,N)};
((length(A)) < (length(B))) ->
B2 = add_zero(B,N),
A2 = add_even(A,B2),
{A2,B2};
true ->
A2 = add_zero(A,N),
B2 = add_even(B,A2),
{A2,B2}
end.


%% @doc Adds zeros to the beginning of X until X:s length is 
%% evenly divisible by N
add_zero(X,N)->
if((length(X) rem N) =:= 0) ->
X;
true ->
add_zero(([0]++X), N)
end.

%% @doc Adds zeros to the beginning of A until A has the same 
%% length as B.
add_even(A,B)->
if
((length(A)) =:= (length(B)))->
A;
true ->
add_even(([0] ++ A),B)

end.


%%DAVIDS
%%adder(A,B,CarryIn, Base) ->

  %%  (AI = list_to_integer(A,Base)),
    %%(BI = list_to_integer(B,Base)),
    %%if
%%	(AI + BI + CarryIn) >= 10->
%%	    {1,(AI + BI + CarryIn) rem 10};
%%	true ->
%%	    {0,AI + BI + CarryIn}
  %%  end.



%% adder(A,B, CarryIn, Base) -> {carryOut, result}
adder(A,B,CarryIn, Base) ->
    if
	(A + B + CarryIn) >= Base->
	    {1,(A + B + CarryIn) rem Base};
	true ->
	    {0,A + B + CarryIn}
    end.

%% listAdderHelp
listAdderHelp([],[],_, Result) ->
    Result;
listAdderHelp([A | Atl],[B | Btl],Base,{CarryIn,Result}) ->
    {CarryOut, Sum} = adder(A,B,CarryIn,Base),
   listAdderHelp(Atl, Btl, Base, {CarryOut,[Sum] ++ Result}).
    

%% listAdder
listAdder(A,B,Base) ->
    listAdderHelp(lists:reverse(A), lists:reverse(B), Base, {0, []}).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                                                          %%
%%			   EUnit Test Cases                                 %%
%%                                                                          %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%ATT TESTA: listigt, Nolligt, split, adder

%%enkelt test listigt
listigt_test() ->
    ?_assertEqual(listigt(1234, 10, []), [1,2,3,4]).


%%enkelt test för listAdder
listAdder_test() ->
    ?_assertEqual(listAdder([1,2],[3,4], 10), {0, [4,6]}).
%%enkelt test för listAdder
listAdder2_test() ->
    ?_assertEqual(listAdder([1,2],[1,1], 3), {0, [1,0,0]}).
%%enkelt test för listAdder
listAdder3_test() ->
    ?_assertEqual(listAdder([5,2],[5,9], 11), {1, [0,0]}).
listAdder4_test() ->
    ?_assertEqual(listAdder([1,10,8,13],[14,6,0,3],16), {1, [0,0,9,0]}).
listAdder5_test() ->
    ?_assertEqual(listAdder([0,1,2,3,4,5],[6,7,8,9,0,1],10), {0, [6,9,1,2,4,6]}).


%%creates a list, of random integer elements, of length N
random_list(N) ->
    [random:uniform() || _ <- lists:seq(1, N)].

%%returns true if A and B have the same length, false otherwise
compareLength({A,B}) -> if ((length(A)) =:= length(B)) ->
				    true;
			   true -> false end.

%%returns a list of zeros with length N ^ L
nollListaHelp(0,L) ->
    L;
nollListaHelp(N,L) ->
    nollListaHelp(N-1, [0] ++ L).

%%returns a list of zeros with length N
nollLista(N) ->
    nollListaHelp(N,[]).
    

%%checks that both lists are the same length
nolligt_length_test_() -> 
    TupleList = [{N1,N2,L} || N1 <- lists:seq(1,20), N2 <- lists:seq(1,20), L <- lists:seq(1,4)],
    [?_assertEqual(compareLength(nolligt(random_list(N1), random_list(N2), L)), true)  || {N1,N2,L} <- TupleList].


%%checks that zeros are concatinated correctly
%%when list A is shorter than list B
nolligt_zero_test() ->
    ListA = [1,2,3],
    ListB = [1,2,3,4,5,6],
    ?_assertEqual(nolligt(ListA, ListB, 4), {[0,0,0,0,0,0,1,2,3], [0,0,1,2,3,4,5,6]}).
nolligt_zero2_test() ->
    ListA = [1,2,3],
    ListB = [1,2,3,4,5,6],
    ?_assertEqual(nolligt(ListA, ListB, 2), {[0,1,2,3], [1,2,3,4,5,6]}).
nolligt_zero3_test() ->
    ListA = [1,2],
    ListB = [1,2,3,4,5,6],
    ?_assertEqual(nolligt(ListA, ListB, 3), {[0,0,0,1,2,3], [1,2,3,4,5,6]}).
  

seqs_length_test_() ->
    %% The list [[], [1], [1,2], ..., [1,2, ..., N]] will allways have
    %% length N+1.

    [?_assertEqual(N+1, length(seqs(N))) || N <- lists:seq(1, 55)].

seqs_test_() ->
    %% A small collection of expected results {N, seqs(N)}.
    
    Data = [{0, [[]]}, {1, [[], [1]]}, {2, [[], [1], [1,2]]}, 
	    {7, [[],
		 [1],
		 [1,2],
		 [1,2,3],
		 [1,2,3,4],
		 [1,2,3,4,5],
		 [1,2,3,4,5,6],
		 [1,2,3,4,5,6,7]]}
	   ],
    
    [?_assertEqual(L, seqs(N)) || {N, L} <- Data].
    
filter_test_() ->
    [?_assertEqual([], filter([], L)) || L <- seqs(10)].
    
filter_true_false_test_() ->
    P1 = fun(_) -> false end,
    P2 = fun(_) -> true end,
    P3 = fun(X) -> X rem 2 == 0 end,
    
    Expected = fun(L) -> [lists:filter(P,L) || P <- [P1,P2,P3]] end,

    [?_assertEqual(Expected(L), filter([P1,P2,P3], L) ) || L <- seqs(10) ].
				       
filter_test() ->
    L = lists:seq(1,10),

    P1 = fun(X) -> X rem 2 == 0 end,
    P2 = fun(X) -> X rem 2 == 1 end,
    P3 = fun(X) -> X > 3 end,

    %%E = [[2,4,6,8,10],[1,3,5,7,9],[4,5,6,7,8,9,10]],
    E = [lists:filter(P,L) || P <- [P1,P2,P3]],
    
    ?assertEqual(E, filter([P1,P2,P3], L)).
    
%split_concat_test_() ->
    %% Make sure the result of concatenating the sublists equals the
    %% original list.
    
%    L = lists:seq(1,99),
%   [?_assertEqual(L, lists:concat(split(L,N))) || N <- lists:seq(1,133)].

%split_n_test_() ->
    %% Make sure the correct number of sublists are generated. 
    
 %   M = 99,
 %   L = lists:seq(1,M),
 %   Num_of_lists = fun(List, N) when N =< length(List) ->
%			   N;
%		      (List, _) ->
%			   length(List)
%		   end,
 %   [?_assertEqual(Num_of_lists(L,N), length(split(L,N))) || N <- L].    


expected_stat(L, N) when N =< length(L) ->
    %% When spliting a list L into N sublists, we know there will only by two possible
    %% lengths of the sublists.

    
    %% Quotient and reminder when dividing length of L with N. 
    {_, Q, R} = lqr(L, N),

    %% There will allways be R sublists of length Q+1 and N-R sublists
    %% of length Q.
    
    {{R, Q+1}, {N-R, Q}};

expected_stat(L, _N) ->
    %% N greater than the length of L, hence all sublists will have
    %% length 1.

    {{length(L), 1}, {0,0}}.

stat(N, M, LL) ->
    %% Return a tuple {{Num_N, N}, {Num_M, M}} where Num_N is the
    %% number of lists of length N in LL and Num_M is the number of
    %% lists of length M in LL.
    
    S = filter([fun(X) -> X == N end, fun(X) -> X == M end], [length(L) || L <- LL]),

    [Num_N, Num_M] = [length(L) || L <- S],
    
    {{Num_N, N}, {Num_M, M}}.

%split_stat_test_() ->
    %% Assure the list of sublists contains the correct number of
    %% lists of the two expected lengths.
	
%    Assert = fun(L,N) ->
%		     {_, Q, _} = lqr(L,N), 
%		     ?_assertEqual(expected_stat(L,N), stat(Q+1, Q, split(L,N))) 
%	     end,
	
    %% Generators can depend on other generator expressions, here N
    %% depends on the length of L.
    
%    [Assert(L,N) ||  L <- seqs(33), N <- lists:seq(1,length(L)+5)].
    
