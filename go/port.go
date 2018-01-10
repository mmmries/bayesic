package main

import (
	"bayesic"
	"bytes"
	"fmt"
	port "github.com/goerlang/port"
	etf "github.com/jonas747/etf"
	"io"
	"os"
)

func main() {
	packetSize := 4
	port, err := port.Packet(os.Stdin, os.Stdout, packetSize)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to setup the port library %s\n", err)
		os.Exit(1)
	}

	matcher := bayesic.New()
	context := &etf.Context{}

	for {
		if data, err := port.ReadOne(); err == io.EOF {
			//fmt.Fprintf(os.Stderr, "Got EOF - Port Closed\n")
			break
		} else if err != nil {
			fmt.Fprintf(os.Stderr, "Read Error %s\n", err)
		} else {
			//fmt.Fprintf(os.Stderr, "Got %v\n", data)
			reader := bytes.NewReader(data[1:len(data)])
			term, err := context.Read(reader)
			if err != nil {
				fmt.Fprintf(os.Stderr, "Failed to parse term %s\n", err)
				sendResponse(context, port, etf.Tuple{etf.Atom("error"), "failed to parse request"})
			} else {
				handleRequest(context, port, matcher, term)
			}
		}
	}
}

func handleRequest(context *etf.Context, port port.Port, matcher *bayesic.Matcher, term interface{}) {
	v := term.(etf.Tuple)
	if len(v) == 3 && v[0] == etf.Atom("train") {
		class_bytes := v[2].([]byte)
		classification := string(class_bytes[:len(class_bytes)])
		tokens := convertListToStrings(v[1].(etf.List))
		matcher.Train(tokens, classification)
		sendResponse(context, port, etf.Atom("ok"))
	} else if len(v) == 2 && v[0] == etf.Atom("classify") {
		tokens := convertListToStrings(v[1].(etf.List))
		classifications := matcher.Classify(tokens)
		sendResponse(context, port, classifications)
	} else {
		sendResponse(context, port, etf.Tuple{etf.Atom("error"), "unexpected message - incorrect format"})
	}
}

func sendResponse(context *etf.Context, port port.Port, term interface{}) {
	response := bytes.NewBuffer([]byte{131})
	err := context.Write(response, term)
	if err == nil {
		response_bytes := response.Bytes()
		size, err := port.Write(response_bytes)
		if err != nil || size != len(response_bytes) {
			fmt.Fprintf(os.Stderr, "Error writing response to stdout, %s\n", err)
		}
	} else {
		fmt.Fprintf(os.Stderr, "Error serializing response %s\n", err)
	}
}

func convertListToStrings(data etf.List) []string {
	s := make([]string, len(data))
	for row := range data {
		s[row] = string(data[row].([]byte))
	}
	return s
}
