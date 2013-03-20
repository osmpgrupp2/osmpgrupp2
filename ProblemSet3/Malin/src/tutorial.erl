%% @author Karl Marklund <karl.marklund@it.uu.se>
-module(tutorial).

-export([hello/0, hello/1, 
	 fac/1, fib/1,
	 fac_tr/1, fib_tr/1,
	 right_triangles/1,
	 simpsons/0, simpsons/1, 
	 char_to_upper/1, char_to_lower/1, 
	 str_to_upper/1, str_to_lower/1, 
	 max/1, count/2, 
	 odd_and_even/1
	]).


%% @doc Prints "Hello!" to the terminal. 
-spec hello() -> ok.

hello() ->
    io:format("Hello!~n").

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  Recursive functions %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% @doc hello (n) prints Hello! n-1 times after each Hello! i a countdown from n to 1. n >= 0.
-spec hello(N::integer()) -> ok.

hello(0) ->
    ok;
hello(N) -> 
    io:format("~p Hello!~n", [N]),
    hello(N-1).

%% @doc The factorial function.
%% === Example ===
%% <div class="example">```
%% 25> [{N,tutorial:fac(N)} || N <- lists:seq(0,10)].                              
%% [{0,1},
%%  {1,1},
%%  {2,2},
%%  {3,6},
%%  {4,24},
%%  {5,120},
%%  {6,720},
%%  {7,5040},
%%  {8,40320},
%%  {9,362880},
%%  {10,3628800}]'''
%% </div>
-spec fac(N::integer()) -> integer().

fac(0) -> 1;
fac(N) -> N*fac(N-1).



%% @doc Calcultates the Nth Fibonnacci number. 
%% === Example ===
%% <div class="example">```
%% > [tutorial:fib(N) || N <- lists:seq(0,10)].
%% [0,1,1,2,3,5,8,13,21,34,55]'''
%% </div>
-spec fib(N::integer()) -> integer().

fib(0) -> 
    0;
fib(1) -> 
    1;
fib(N) when N > 0 -> 
    fib(N-1) + fib(N-2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  Tail Recursive functions %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% @doc The factorial function, implemented using tail recursion.
-spec fac_tr(N::integer()) -> integer().

fac_tr(N) ->
    fac_tr(N,1).

fac_tr(0, Acc) -> 
    Acc;
fac_tr(N, Acc) ->
    fac_tr(N-1, N*Acc).

%% @doc Calculates the Nth fibonacci number, implemented using tail
%% recursion.
-spec fib_tr(N::integer()) -> integer().

fib_tr(N) ->
    fib_tr(N, 0,1).

fib_tr(0, Xi, Xii) -> 
    Xi;
fib_tr(Iter, Xi, Xii) -> 
    fib_tr(Iter -1, Xii, Xi+Xii).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  List Comprehensions %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% @doc Generates a list of tuples {A,B,C} such that A and B are sides
%% in a right triangle with hypotenuse C, where `A,B,C <= N'.
%% === Example ===
%% <div class="example">```
%% > tutorial:right_triangles(10).
%% [{3,4,5},{4,3,5},{6,8,10},{8,6,10}]'''
%% </div>
-spec right_triangles(N) -> [{A,B,C}] when
      N::integer(),
      A::integer(),
      B::integer(),
      C::integer().

right_triangles(N) ->
    L = lists:seq(1, N),
    [{A,B,C} || A <- L, B <- L, C <- L, math:pow(A,2) + math:pow(B,2) =:= math:pow(C,2)].

%% @doc Returns a list of tuples, where each tuple describes a caracter in the Simposon family.
%%
%% === Example ===
%% <div class="example">```
%% > tutorial:simpsons().
%% [{person,male,"Bart"},
%%  {cat,female,"Snowball II"},
%%  {person,male,"Homer"},
%%  {person,female,"Lisa"},
%%  {dog,male,"Santa's Little Helper"},
%%  {person,female,"Marge"},
%%  {pig,male,"Spider Pig"}]'''
%% </div>
-spec simpsons() -> [{Type, Gender, Name}] when
      Type::person|cat|dog|pig,
      Gender::male|female,
      Name::string().

simpsons() ->
    [
     {person, male, "Bart"}, 
     {cat, female, "Snowball II"},
     {person, male, "Homer"}, 
     {person, female, "Lisa"},
     {dog, male, "Santa's Little Helper"},
     {person, female, "Marge"},
     {pig, male, "Spider Pig"}
    ].

%% @doc Returns a filtered list of names of characters in the Simpson family. 
%% === Example ===
%% <div class="example">```
%% > tutorial:simpsons(names).
%% ["Bart","Snowball II","Homer","Lisa",
%%  "Santa's Little Helper","Marge","Spider Pig"]
%% > tutorial:simpsons(females).
%% ["Snowball II","Lisa","Marge"]
%% > tutorial:simpsons(males).  
%% ["Bart","Homer","Santa's Little Helper","Spider Pig"]
%% > tutorial:simpsons(pets). 
%% ["Snowball II","Santa's Little Helper","Spider Pig"]'''
%% </div>

-spec simpsons(Filter) -> [Name] when
      Filter::names|males|females|pets,
      Name::string().

simpsons(names) ->
    [X || {_,_,X} <- simpsons()];
simpsons(males) ->
    [X || {_,male,X} <- simpsons()];
simpsons(females) ->
    [X || {_,female,X} <- simpsons()];
simpsons(pets) ->
    [X || {A,_,X} <- simpsons(), A =/= person].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  Guarded Functions  %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% @doc Convert a character to upper case.
%% === Example ===
%% <div class="example">```
%% > tutorial:char_to_upper($a). 
%% 65
%% > tutorial:char_to_upper($@). 
%% 64'''
%% </div>
-spec char_to_upper(char()) -> char().

char_to_upper(Char) when Char >= 97 andalso Char =< 122 -> Char-32;

char_to_upper(Char) -> Char.

%% @doc Convert a character to lower case.
%% === Example ===
%% <div class="example">```
%% > tutorial:char_to_lower($A).
%% 97
%% > tutorial:char_to_lower($@).                                                 
%% 64'''
%% </div>
-spec char_to_lower(char()) -> char().

char_to_lower(Char) when Char >= 65 andalso Char =< 90 -> Char+32;

char_to_lower(Char) ->Char.

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  Map  %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% HINT: Use the char_to_upper() and char_to_lower().

%% @doc Convert a string to upper case. 
%% === Example ===
%% <div class="example">```
%% > tutorial:str_to_upper("Erlang").
%% "ERLANG"'''
%% </div>
-spec str_to_upper(string()) -> string().

str_to_upper(String) ->
lists:map(fun char_to_upper/1, String).


%% @doc Convert a string to lower case. 
%% === Example ===
%% <div class="example">```
%% 7> tutorial:str_to_lower("Upper + Lower").   
%% "upper + lower"'''
%% </div>
-spec str_to_lower(string()) -> string().

str_to_lower(String) ->
    lists:map(fun char_to_lower/1, String).

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%  Fold %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% @doc Returns the max value M in a list L.
%% === Example ===
%% <div class="example">```
%% 8> tutorial:max([4,-1,8, 0, 3]).
%% 8'''
%% </div>
-spec max(L) -> M when
      L::[integer()],
      M::integer().

max([H | T]) ->
    F = fun(H,A) -> if (H > A) -> H;
      		    true -> A end end,
   		     lists:foldl(F, H, T).
		       

%% @doc Returns the number of times Char occurs in String.
%% === Example ===
%% <div class="example">```
%% > tutorial:count("Operating systems and multicore programming", $m). 
%% 4'''
%% </div>
-spec count(String, Char) -> integer() when
      String::string(),
      Char::char().
      
count(String, Char) ->

    F = fun(H,A) -> if (H =:= Char) -> A+1;
      		    true -> A end end,
    lists:foldl(F, 0, String).


%% @doc Returns a tuple {{odd, Odd}, {even, Even}} where Odd and Even
%% are lists with all the odd and even numbers in List.
%% === Example ===
%% <div class="example">```
%% > tutorial:odd_and_even(lists:seq(1,10)).
%% {{odd,[9,7,5,3,1]},{even,[10,8,6,4,2]}}'''
%% </div>
-spec odd_and_even(List) -> {{odd, Odd},{even, Even}} when
      List::[integer()],
      Odd::[integer()],
      Even::[integer()].

odd_and_even(List) ->
    F = fun(hd, {{odd,Odd},{even,Even}}) -> if hd rem 2 == 0 -> {{odd, Odd},{even,[hd | Even]}};
				       true -> {{odd, [hd | Odd]},{even,Even}} end end,
   lists:foldl(F, {{odd, []}, {even, []}}, List).
    


