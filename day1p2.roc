app "day1p2"
    packages { pf: "basic-cli/src/main.roc" }
    imports [pf.Stdout, pf.File, pf.Task, pf.Path, Json]
    provides [main] to pf

splitListOn : List a, a -> List (List a) | a has Eq
splitListOn = \list, delim ->
    result = List.walk list {cur: [], acc: []} (\{cur, acc}, elem ->
        if elem == delim then
            {cur: [], acc: List.append acc cur}
        else
            {cur: List.append cur elem, acc: acc}
    )
    result.acc

yolo : Result ok err -> ok
yolo = \r ->
    when r is
        Ok value -> value
        Err _ -> crash "yolo"

main =
    content <- "./aoc22/day1.txt"
        |> Path.fromStr
        |> File.readUtf8
        |> Task.onFail (\err ->
            when err is
                FileReadUtf8Err _path _fileErr -> crash "FileReadUtf8Err"
                FileReadErr _ _ -> crash "FileReadErr: asd"
        )
        |> Task.await

    split = content
        |> Str.split "\n"
        |> splitListOn ""
        |> List.map (\list -> List.map list (\x -> x |> Str.toU32 |> yolo))
        |> List.map List.sum
        |> List.sortDesc
        |> List.takeFirst 3
        |> List.sum

    split
        |> Encode.toBytes Json.toUtf8
        |> Str.fromUtf8
        |> Result.withDefault "err"
        |> Stdout.line

