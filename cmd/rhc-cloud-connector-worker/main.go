package main

import (
	"context"
	"net"
	"os"
	"time"
	"path/filepath"
	"flag"

	"git.sr.ht/~spc/go-log"

	"github.com/peterbourgon/ff/v3"
	"github.com/peterbourgon/ff/v3/fftoml"
	"google.golang.org/grpc"
	"github.com/sgreben/flagvar"
	"github.com/redhatinsights/yggdrasil"
	protocol "github.com/redhatinsights/yggdrasil/protocol"

	internal "github.com/theforeman/rhc-cloud-connector-worker/internal"
)

func main() {
	fs := flag.NewFlagSet(filepath.Base(os.Args[0]), flag.ExitOnError)

	var (
		socketAddr = ""
		serverURL = flagvar.URL{}
		username = ""
		password = ""
	)

	fs.StringVar(&socketAddr, "socket-addr", "", "dispatcher socket address")
	fs.Var(&serverURL, "server-url", "Target server URL to send API requests")
	fs.StringVar(&username, "username", "", "Username to authenticate to server URL with")
	fs.StringVar(&password, "password", "", "Password to authenticate to server URL with")

	_ = fs.String("config", filepath.Join(yggdrasil.SysconfDir, yggdrasil.LongName, "workers", fs.Name()+".toml"), "path to `file` containing configuration values (optional)")

	if err := ff.Parse(fs, os.Args[1:], ff.WithEnvVarPrefix("YGG"), ff.WithConfigFileFlag("config"), ff.WithConfigFileParser(fftoml.Parser)); err != nil {
		log.Fatal(err)
	}

	// Dial the dispatcher on its well-known address.
	conn, err := grpc.Dial(socketAddr, grpc.WithInsecure())
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	// Create a dispatcher client
	c := protocol.NewDispatcherClient(conn)
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()

	// Register as a handler of the "package-manager" type.
	r, err := c.Register(ctx, &protocol.RegistrationRequest{Handler: "cloud-connector", Pid: int64(os.Getpid())})
	if err != nil {
		log.Fatal(err)
	}
	if !r.GetRegistered() {
		log.Fatalf("handler registration failed: %v", err)
	}

	// Listen on the provided socket address.
	l, err := net.Listen("unix", r.GetAddress())
	if err != nil {
		log.Fatal(err)
	}

	// Register as a Worker service with gRPC and start accepting connections.
	s := grpc.NewServer()
	protocol.RegisterWorkerServer(s, &internal.Server{Username: username, Password: password, ServerURL: serverURL})
	if err := s.Serve(l); err != nil {
		log.Fatal(err)
	}
}
