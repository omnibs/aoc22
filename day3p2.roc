app "day2p2"
    packages { pf: "basic-cli/src/main.roc" }
    imports [pf.Stdout, pf.File, pf.Task, pf.Path, Json, ListExtra]
    provides [main] to pf

yolo : Result ok err -> ok
yolo = \r ->
    when r is
        Ok value -> value
        Err _ -> crash "yolo"

getRepeatChar : List (List Str) -> Str
getRepeatChar = \lists ->
    { before, others } = List.split lists 1

    first = List.first before |> yolo |> Set.fromList
    rest = List.map others Set.fromList

    result = List.walkUntil rest first \curIntersect, list ->
        newIntersect = Set.intersection curIntersect list

        if Set.len newIntersect == 1 then
            Break newIntersect
        else
            Continue newIntersect

    when Set.toList result is
        [str] -> str
        other ->
            badResult = Str.joinWith other ","

            crash "found more than 1 char: \(badResult)"

utf8char : Str -> U32
utf8char = \x -> x |> Str.toUtf8 |> List.first |> yolo |> Num.toU32

rank = \x ->
    n = utf8char x

    if n >= utf8char "a" && n <= utf8char "z" then
        n - utf8char "a" + 1
    else if n >= utf8char "A" && n <= utf8char "Z" then
        n - utf8char "A" + 27
    else
        crash "not a letter: \(x)"

main =
    content <- "./aoc22/day3.txt"
        |> Path.fromStr
        |> File.readUtf8
        |> Task.onFail
            (\err ->
                when err is
                    FileReadUtf8Err _path _fileErr -> crash "FileReadUtf8Err"
                    FileReadErr _ _ -> crash "FileReadErr: asd"
            )
        |> Task.await

    result =
        content
        |> Str.split "\n"
        |> List.keepIf (\x -> x != "")
        |> List.map Str.graphemes
        |> ListExtra.chunk 3
        |> List.map getRepeatChar
        |> List.map rank
        |> List.sum

    result
    |> Encode.toBytes Json.toUtf8
    |> Str.fromUtf8
    |> Result.withDefault "err"
    |> Stdout.line
