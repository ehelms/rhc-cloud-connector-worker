package internal

import (
  "context"
  "net/http"
  "fmt"
	"time"

  "git.sr.ht/~spc/go-log"

	"github.com/sgreben/flagvar"
  protocol "github.com/redhatinsights/yggdrasil/protocol"
)

type Server struct {
  protocol.UnimplementedWorkerServer

  ServerURL flagvar.URL
  Username string
  Password string
}

// Send implements the "Send" method of the Worker gRPC service.
func (server *Server) Send(ctx context.Context, data *protocol.Data) (*protocol.Receipt, error) {
  go server.dispatchMessage(data)

  return &protocol.Receipt{}, nil
}

func (server *Server) dispatchMessage(data *protocol.Data) error {
  client := &http.Client{
		Timeout: time.Second * 10,
	}

  req, err := http.NewRequest("POST", server.ServerURL.Text, nil)
	if err != nil {
    log.Fatal(err.Error())
		return fmt.Errorf("Got error %s", err.Error())
	}

	req.SetBasicAuth(server.Username, server.Password)

	response, err := client.Do(req)
	if err != nil {
		return fmt.Errorf("Got error %s", err.Error())
	}

	defer response.Body.Close()

	return nil
}
