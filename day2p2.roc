app "day2p2"
    packages { pf: "basic-cli/src/main.roc" }
    imports [pf.Stdout, pf.File, pf.Task, pf.Path, Json]
    provides [main] to pf

yolo : Result ok err -> ok
yolo = \r ->
    when r is
        Ok value -> value
        Err _ -> crash "yolo"

Play : [Rock, Paper, Scissor]
Round : {other: Play, me: Play}

Outcome : [Win, Draw, Lose]

outcome : Round -> Outcome
outcome = \round ->
    when round is
        {other: Rock, me: Rock} -> Draw
        {other: Scissor, me: Scissor} -> Draw
        {other: Paper, me: Paper} -> Draw
        {other: Rock, me: Paper} -> Win
        {other: Scissor, me: Rock} -> Win
        {other: Paper, me: Scissor} -> Win
        {other: Rock, me: Scissor} -> Lose
        {other: Scissor, me: Paper} -> Lose
        {other: Paper, me: Rock} -> Lose

playVal : Play -> U32
playVal = \play ->
    when play is
        Rock -> 1
        Paper -> 2
        Scissor -> 3

roundVal : Round -> U32
roundVal = \round ->
    hand = (playVal (round.me))
    when outcome round is
        Win -> 6 + hand
        Draw -> 3 + hand
        Lose -> 0 + hand

parseRound : Str -> Round
parseRound = \str ->
    {after, before} = str |> Str.splitFirst " " |> yolo
    other = when before is
        "A" -> Rock
        "B" -> Paper
        "C" -> Scissor
        x -> crash "invalid play from opponent: \(x)"
    me = when after is
        "X" ->
            # Lose
            when other is
                Rock -> Scissor
                Paper -> Rock
                Scissor -> Paper
        "Y" ->
            # Draw
            when other is
                Rock -> Rock
                Paper -> Paper
                Scissor -> Scissor
        "Z" ->
            # Win
            when other is
                Rock -> Paper
                Paper -> Scissor
                Scissor -> Rock
        x -> crash "invalid play from self: \(x)"
    {other: other, me: me}

main =
    content <- "./aoc22/day2.txt"
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
        |> List.keepIf (\x -> x != "")
        |> List.map parseRound
        |> List.map roundVal
        |> List.sum

    split
        |> Encode.toBytes Json.toUtf8
        |> Str.fromUtf8
        |> Result.withDefault "err"
        |> Stdout.line

