interface ListExtra exposes [
    chunk
] imports []

chunk : List a, Nat -> List (List a)
chunk = \list, n ->
    chunkRecurse (List.split list n) n

chunkRecurse : {before: List a, others: List a}, Nat -> List (List a)
chunkRecurse = \{before, others}, n ->
    if List.len others > n then
        List.concat [before] (chunkRecurse (List.split others n) n)
    else
        [before, others]