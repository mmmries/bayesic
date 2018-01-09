package main

import (
  //"bayesic"
  port "github.com/goerlang/port"
  etf "github.com/goerlang/etf"
  "bytes"
  "fmt"
  "io"
  "os"
)

func main() {
  var p port.Port
  packetSize := 4
  p, err := port.Packet(os.Stdin, os.Stdout, packetSize)
  if err != nil {
    fmt.Fprintf(os.Stderr, "Failed to setup the port library %s\n", err)
    os.Exit(1)
  }

  //matcher := bayesic.New()
  context := etf.Context{}

  for {
    if data, err := p.ReadOne(); err == io.EOF {
      fmt.Fprintf(os.Stderr, "Got EOF - Port Closed\n")
      break
    } else if err != nil {
      fmt.Fprintf(os.Stderr, "Read Error %s\n", err)
    } else {
      fmt.Fprintf(os.Stderr, "Got %v\n", data)
      reader := bytes.NewReader(data[1:len(data)])
      term, err := context.Read(reader)
      if err != nil {
        fmt.Fprintf(os.Stderr, "Failed to parse term %s\n", err)
      } else {
        fmt.Fprintf(os.Stderr, "Parsed %v\n", term)
      }

      response := bytes.NewBuffer([]byte{131})
      err = context.Write(response, "ok")
      if err == nil {
        response_bytes := response.Bytes()
        size, err := p.Write(response_bytes)
        if err != nil || size != len(response_bytes) {
          fmt.Fprintf(os.Stderr, "Error writing response to stdout, %s\n", err)
        }
      } else {
        fmt.Fprintf(os.Stderr, "Error serializing response %s\n", err)
      }
    }
  }
}
