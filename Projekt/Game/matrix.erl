matrix(Size) ->
 
  lists:map(
    fun(X) ->
      lists:map(
          fun(Y) ->
              case Y of 
                 X -> 0;
                 _ -> 0
                 end
              end,
          lists:seq(0,Size-1))
      end,
    lists:seq(0,Size-1)).
