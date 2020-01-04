tokenizer = fn(str) ->
  str |> String.downcase |> String.split(~r/\b/u) |> Enum.map(fn(word) ->
    String.replace(word, ~r/[^\w ]/u, "")
  end) |> Enum.reject(fn(word) -> String.length(word) < 2 end)
end

IO.puts "loading in training data..."

training_data = "benchmarks/imdb_titles.csv" |> File.stream! |> CSV.decode!(headers: true) |> Enum.map(fn(row) ->
  %{string: row["name"], id: row["id"], tokens: tokenizer.(row["name"])}
end)

trainer = fn(training_data) ->
  matcher = Bayesic.init()
  Enum.reduce(training_data, matcher, fn(row, matcher) ->
    Bayesic.train(matcher, row.tokens, row.id)
  end) |> Bayesic.finalize(pruning_threshold: 0.1)
end

IO.puts "training a classifier for reference..."

matcher = trainer.(training_data)

IO.puts "running benchmarks..."

Benchee.run(%{
  "training" => fn -> trainer.(training_data) end,
  "match 1 word" => fn -> Bayesic.classify(matcher, ["silver"]) end,
  "match 3 words" => fn -> Bayesic.classify(matcher, ["the", "silver", "screen"]) end,
}, time: 10)
