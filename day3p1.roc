app "day2p2"
    packages { pf: "basic-cli/src/main.roc" }
    imports [pf.Stdout, pf.File, pf.Task, pf.Path, Json]
    provides [main] to pf

yolo : Result ok err -> ok
yolo = \r ->
    when r is
        Ok value -> value
        Err _ -> crash "yolo"

getRepeatChar : {before: List Str, others: List Str} -> Str
getRepeatChar = \{before, others} ->
    repeat = List.walkUntil before NotFound \_state, elem ->
                when List.findFirst others (\x -> x == elem) is
                    Ok _ -> Break (Found elem)
                    Err _ -> Continue (NotFound)
    when repeat is
        Found elem -> elem
        NotFound ->
            b = Str.joinWith before ""
            o = Str.joinWith others ""
            crash "no repeats in \(b)\(o)"

utf8char : Str -> U32
utf8char = \x -> x |> Str.toUtf8 |> List.first |> yolo |> Num.toU32

rank = \x ->
    n = utf8char x
    if n >= (utf8char "a") && n <= (utf8char "z") then n - (utf8char "a") + 1
    else if n >= (utf8char "A") && n <= (utf8char "Z") then n - (utf8char "A") + 27
    else crash "not a letter: \(x)"


main =
    content <- "./aoc22/day3.txt"
        |> Path.fromStr
        |> File.readUtf8
        |> Task.onFail (\err ->
            when err is
                FileReadUtf8Err _path _fileErr -> crash "FileReadUtf8Err"
                FileReadErr _ _ -> crash "FileReadErr: asd"
        )
        |> Task.await

    result = content
        |> Str.split "\n"
        |> List.keepIf (\x -> x != "")
        |> List.map Str.graphemes
        |> List.map \list -> List.split list (Num.divTrunc (List.len list) 2)
        |> List.map getRepeatChar
        |> List.map rank
        |> List.sum

    result
        |> Encode.toBytes Json.toUtf8
        |> Str.fromUtf8
        |> Result.withDefault "err"
        |> Stdout.line

