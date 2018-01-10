[training_csv, matching_csv] = System.argv()

tokenizer = fn(str) ->
  str |> String.downcase |> String.split(~r/\b/) |> Enum.map(fn(word) ->
    String.replace(word, ~r/[^\w ]/, "")
  end) |> Enum.reject(fn(word) -> String.length(word) < 2 end)
end

trainer = fn(training_data) ->
  matcher = Bayesic.new()
  Enum.reduce(training_data, matcher, fn(row, matcher) ->
    Bayesic.train(matcher, row.tokens, row.id)
  end)
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
(1..10) |> Enum.each(fn(_) -> trainer.(training_data) end)
(1..10) |> Enum.each(fn(_) -> classifier.(matcher, matching_data) end)

:timer.tc(fn ->
  (1..10) |> Enum.each(fn(_) -> trainer.(training_data) end)
end) |> IO.inspect
:timer.tc(fn ->
  (1..10) |> Enum.each(fn(_) -> classifier.(matcher, matching_data) end)
end) |> IO.inspect

#Benchee.run(%{
#  "training" => fn -> trainer.(training_data) end,
#  "match #{Enum.count(matching_data)} rows" => fn -> classifier.(matcher, matching_data) end,
#}, time: 10, console: [comparison: false])
