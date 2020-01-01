[training_csv, matching_csv] = System.argv()

tokenizer = fn(str) ->
  str |> String.downcase |> String.split(~r/\b/) |> Enum.map(fn(word) ->
    String.replace(word, ~r/[^\w ]/, "")
  end) |> Enum.reject(fn(word) -> String.length(word) < 2 end)
end

trainer = fn(training_data) ->
  matcher = Bayesic.Trainer.new()
  Enum.reduce(training_data, matcher, fn(row, matcher) ->
    Bayesic.train(matcher, row.tokens, row.id)
  end) |> Bayesic.finalize
end

classifier = fn(matcher, matching_data) ->
  Enum.each(matching_data, fn(row) ->
    Bayesic.classify(matcher, row.tokens)
  end)
end

training_data = training_csv |> File.stream! |> CSV.decode!(headers: true) |> Enum.map(fn(row) ->
  %{string: row["source_string"], id: row["source_id"], tokens: tokenizer.(row["source_string"])}
end)

matching_data = matching_csv |> File.stream! |> CSV.decode!(headers: true) |> Enum.map(fn(row) ->
  %{string: row["match_string"], source_id: row["source_id"], tokens: tokenizer.(row["match_string"])}
end)

matcher = trainer.(training_data)

Benchee.run(%{
  "training" => fn -> trainer.(training_data) end,
  "match #{Enum.count(matching_data)} rows" => fn -> classifier.(matcher, matching_data) end,
}, time: 10)

stats = Enum.reduce(matching_data, %{correct: 0, incorrect: 0, unmatched: 0}, fn(row, stats) ->
  expected_class = row.source_id
  probabilities = Bayesic.classify(matcher, row.tokens)
  best_guess = probabilities |> Enum.reject(fn({_class, probability}) -> probability < 0.85 end) |> Enum.sort_by(fn({_class, probability}) -> probability end) |> List.last
  case best_guess do
    nil -> %{stats | unmatched: stats.unmatched + 1}
    {^expected_class, _probability} -> %{stats | correct: stats.correct + 1}
    {class, probability} ->
      IO.puts "expected #{expected_class}, but got #{class} for #{inspect row.tokens} (#{probability} confidence)"
      %{stats | incorrect: stats.incorrect + 1}
  end
end)
IO.inspect(stats)
