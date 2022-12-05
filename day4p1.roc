app "day2p2"
    packages { pf: "basic-cli/src/main.roc" }
    imports [pf.Stdout, pf.File, pf.Task, pf.Path, Json, Parser.{ Parser }]
    provides [main] to pf

main =
    content <- "./aoc22/day4.txt"
        |> Path.fromStr
        |> File.readBytes
        |> Task.onFail
            (\err ->
                when err is
                    FileReadUtf8Err _path _fileErr -> crash "FileReadUtf8Err"
                    FileReadErr _ _ -> crash "FileReadErr: asd"
            )
        |> Task.await

    content
    |> parseInput
    |> Result.onErr \Msg s -> crash "oh no: \(s)"
    |> yolo
    |> List.keepIf fullyContained
    |> List.len
    |> Num.toStr
    |> Stdout.line

yolo : Result ok err -> ok
yolo = \r ->
    when r is
        Ok value -> value
        Err _ -> crash "yolo"

Range : { first : Nat, last : Nat }

parseInput : List U8 -> Result (List (List Range)) _
parseInput = \input ->
    line : Parser (List U8) (List Range)
    line =
        Parser.const (\f1 -> \_ -> \l1 -> \_ -> \f2 -> \_ -> \l2 -> [{ first: f1, last: l1 }, { first: f2, last: l2 }])
        |> Parser.apply Parser.digits
        |> Parser.apply (Parser.codeunit '-')
        |> Parser.apply Parser.digits
        |> Parser.apply (Parser.codeunit ',')
        |> Parser.apply Parser.digits
        |> Parser.apply (Parser.codeunit '-')
        |> Parser.apply Parser.digits
        |> Parser.dropAfter Parser.newline

    parser = Parser.many line

    Parser.parseBytes parser input

fullyContained = \list ->
    when list is
        [a, b] ->
            a.first <= b.first && a.last >= b.last || b.first <= a.first && b.last >= a.last

        _ -> crash "cant happen"

expect fullyContained [{ first: 1, last: 2 }, { first: 1, last: 2 }]
expect fullyContained [{ first: 1, last: 10 }, { first: 9, last: 10 }]
expect fullyContained [{ first: 2, last: 2 }, { first: 1, last: 10 }]
