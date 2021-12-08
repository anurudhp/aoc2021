open System
open System.IO

let flip (c : char) : char = if c = '0' then '1' else '0'
let stoi (x : string) : int = Convert.ToInt32(x, 2)
let atoi (x : char[]) : int = stoi(System.String x)

let maj (def : char) (ns : char[])  : char =
  let f0 = ns |> Array.filter (fun x -> x = '0') |> Array.length
  let f1 = ns |> Array.filter (fun x -> x = '1') |> Array.length
  if f0 = f1 then def else (if f0 > f1 then '0' else '1')

let rec compute (f : char[] -> char) (ix : int) (ns : string[]) : string = 
  if ns.Length = 1
  then
    ns.[0]
  else
    let c = ns |> Array.map (fun s -> s.[ix]) |> f
    compute f (ix + 1) (ns |> Array.filter (fun s -> s.[ix] = c))

[<EntryPoint>]
let main argv =
  let input = File.ReadAllText(argv.[0]).Split '\n'
  let input = input |> Array.filter (fun s -> s.Length <> 0)

  // part 1
  let b = (String.length input.[0])
  let gamma = [| for i in 0..(b-1) -> (input |> Array.map (fun s -> s.[i]) |> maj '_') |]
  let eps = Array.map flip gamma
  let power = atoi(gamma) * atoi(eps)
  printfn "%d" power

  // part 2
  let oxy = compute (maj '1') 0 input
  let co2 = compute (maj '1' >> flip) 0 input
  let lifesup = stoi(oxy) * stoi(co2)
  printfn "%d" lifesup

  0
