defmodule KV.ProcessManagement do
  import Map

  def start_manager() do
    data = %{lastWorkId: 0, workersNum: 0, workersMax: 3, workQueue: []}
    spawn(fn -> loop(data) end)
  end

  defp loop(data) do
    printData(data)

    %{
      workersNum: workersNum,
      workersMax: workersMax,
      workQueue: workQueue
    } = data

    receive do
      {:new, workWeight} when workersNum >= workersMax ->
        addingWorkToQueue(data, workWeight) |> loop

      {:new, workWeight} when workersNum < workersMax ->
        createNewWork(data, workWeight) |> loop

      :start ->
        increaseWorkerNum(data) |> loop

      :end when workQueue == [] ->
        decreaseWorkerNum(data) |> loop

      :end when length(workQueue) > 0 ->
        [{_, workWeight} | rest] = workQueue

        %{data | workQueue: rest}
        |> decreaseWorkerNum
        |> createNewWork(workWeight)
        |> loop
    after
      10_000 ->
        if workersNum > 0 do
          IO.puts("stil waiting all workers to finish")
          loop(data)
        else
          IO.puts("10 s idle end waiting")
        end
    end
  end

  defp addingWorkToQueue(data, workWeight) do
    data
    |> get_and_update(:workQueue, &{&1, &1 ++ [{:new, workWeight}]})
    |> elem(1)
  end

  defp createNewWork(data, workWeight) do
    spawn(__MODULE__, :work, [data[:lastWorkId] + 1, self(), workWeight])

    data
    |> get_and_update(:lastWorkId, &{&1, &1 + 1})
    |> elem(1)
  end

  defp increaseWorkerNum(data) do
    data
    |> get_and_update(:workersNum, &{&1, &1 + 1})
    |> elem(1)
  end

  defp decreaseWorkerNum(data) do
    data
    |> get_and_update(:workersNum, &{&1, &1 - 1})
    |> elem(1)
  end

  defp printData(data) do
    %{workersNum: num, workersMax: max, workQueue: que} = data

    IO.puts(
      "number of workers " <>
        to_string(num) <> " max: " <> to_string(max) <> " and queue: " <> to_string(length(que))
    )
  end

  def work(workId, parentPid, workWeight) do
    sWorkId = to_string(workId)
    IO.puts("Start work: " <> sWorkId)
    send(parentPid, :start)
    :timer.sleep(workWeight * 1000)
    IO.puts("End work: " <> sWorkId)
    send(parentPid, :end)
  end
end
