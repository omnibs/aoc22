app "day1"
    packages { pf: "basic-cli/src/main.roc" }
    imports [pf.Stdout, pf.File, pf.Task, pf.Path, Json]
    provides [main] to pf

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
    
    split
        |> Encode.toBytes Json.toUtf8
        |> Str.fromUtf8
        |> Result.withDefault "err"
        |> Stdout.line
    
