-module(list).
-export([max/1, split/2, pmax/2]).

%% To use EUnit we must include this:
-include_lib("eunit/include/eunit.hrl").


%% @doc Find the max value in a list using a sequential, recursive
%% solution.
-spec max(List) -> integer() when List::list().

max([]) ->
    {undefined, empty_list};
max([N]) ->
    N;
max([H|T]) ->
    rmax(T, H).

%% A recursive helper function. 

rmax([], Max) ->
    Max; %% Recursive base case
rmax([H|T], Max) when H > Max ->
    rmax(T, H);
rmax([_H|T], Max) ->
    rmax(T, Max).


%% @doc Find the max value in List by spliting up List in sub lists of
%% size N and use concurrent procces to process each sublists.
-spec pmax(List, N) -> integer() when List::list(),
				      N::integer().

pmax(List, N) ->
    process_flag(trap_exit, true),
    Death = death:start(60),
    pmax(List, N, Death).

%% @doc Split a list L into lists of lengt N. 
-spec split(List, N) -> [list()] when List::list(),
				      N::integer().

%% NOTE: This may result in one list having fewer than N elemnts. 
%%
%% Example: When splitting a list of length 5 into list of length 2 we
%% get two lists of lenght 2 and one list of length 1.

%% Can we stop splitting?
split(L, N) when length(L) < N ->
    L;

%% Do the splitting
split(L, N) ->
    split(L, N, []).

%% An auxiliary recursive split function
split(L, N, Lists) ->
    {L1, L2} = lists:split(N, L),
    if length(L2) > N ->
	    split(L2, N, [L1|Lists]);
       true ->
	    [L1, L2|Lists]
    end.


pmax(List, N, Death) when length(List) > N ->
    Lists = split(List, N),
    CollectPID = self(),
    [spawn_link(fun() -> worker(L, CollectPID, Death) end) || L <- Lists],
    Maxes = collect(length(Lists), []),
    pmax(Maxes, N, Death);
pmax(List, _, _) ->
    list:max(List). 
    
%% Find the max value in List and send result to Collect. 

worker(List, Collect, Death) ->
    death:gamble(Death),
    Collect!list:max(List).

%% Wait for results from all workers. 

collect(N, Maxes) when length(Maxes) < N ->
    receive 
	{'EXIT', _PID, random_death} ->
	    collect(N, [-666|Maxes]);
	{'EXIT', _PID, normal} ->
	    collect(N, Maxes);
	Max -> 
	    collect(N, [Max|Maxes]) 
    end;

collect(_N, Maxes) ->
    io:format("Collected Maxes = ~w~n", [Maxes]),
    Maxes.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%			   EUnit Test Cases                                  %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% All functions with names ending wiht _test() or _test_() will be
%% called automatically by list:test()



split_test_() ->
    List = lists:seq(1,10), 
    
    [?_assertEqual(List, split(List, length(List)+1)),
     ?_assertEqual(5, length(split(List, 2))),
     ?_assertEqual(4, length(split(List, 3))),
     ?_assertEqual([1,3,3,3], lists:sort([length(L) || L <- split(List, 3)])),
     ?_assertEqual([2,4,4], lists:sort([length(L) || L <- split(List, 4)]))
    ].
    
split_merge_test_() ->
    List = lists:seq(1, 100),
    [?_assertMatch(List, lists:merge(split(List, N))) || N <- lists:seq(2, 23)].
    

max_empty_list_test() ->
    ?assertEqual({undefined, empty_list}, max([])).

max_test() ->
    ?assertEqual(42, max([3, 7,-9, 42, 11, 7])).

random_list(N) ->
    [random:uniform(N) || _ <- lists:seq(1, N)].

max_random_lists_test_() ->
    %% A list [1, 10, 100, .... ]
    Lengths = [trunc(math:pow(10, N)) || N <- lists:seq(0, 5)],
    
    %% A list of random lists of increasing lengths
    RandomLists = [random_list(Length) || Length <- Lengths],
    
    [?_assertEqual(lists:max(L), max(L)) || L <- RandomLists].

pmax_random_plist_test() ->
    N = 10000,
    L = random_list(N),
    ?assertEqual(lists:max(L), pmax(L, 10)).
    
