package features

import (
	"bytes"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"testing"
	"time"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
)

type Tester struct {
	*testing.T
	Db *sqlx.DB

	Http   *http.Client
	Bearer string
}

func NewTester(t *testing.T) *Tester {
	return &Tester{
		T:    t,
		Db:   initDb(t),
		Http: initHttpClient(),
	}
}

func initDb(t *testing.T) *sqlx.DB {
	psqlInfo := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s sslmode=disable",
		DbHost, DbPort, DbUser, DbPass, DbName)

	db, err := sqlx.Open("postgres", psqlInfo)
	if err != nil {
		t.Fatalf("Database connection failed: %s", err.Error())
	}

	t.Cleanup(func() { db.Close() })

	err = db.Ping()
	if err != nil {
		t.Fatalf("Database ping failed: %s", err.Error())
	}

	return db
}

func initHttpClient() *http.Client {
	return &http.Client{
		Timeout: 5 * time.Second,
	}
}

func (t *Tester) SetBearerAuth(token string) {
	t.Bearer = token
}

func (t *Tester) DoReq(method, path string, body []byte) HttpResponse {
	remote, err := url.JoinPath(BaseUrl, path)
	if err != nil {
		t.Fatalf("Invalid url: %s", err.Error())
	}

	var r io.Reader
	if body != nil {
		r = bytes.NewReader(body)
	}

	req, err := http.NewRequest(method, remote, r)
	if err != nil {
		t.Fatalf("Invalid request: %s", err.Error())
	}

	if len(t.Bearer) > 0 {
		req.Header.Set("Authentication", fmt.Sprintf("Bearer %s", t.Bearer))
	}

	res, err := t.Http.Do(req)
	if err != nil {
		t.Fatalf("Cannot perform request: %s", err.Error())
	}

	return HttpResponse{T: t.T, Response: res}
}

func (t *Tester) GetWithUrlValues(path string, values url.Values) HttpResponse {
	remote, err := url.JoinPath(BaseUrl, path)
	if err != nil {
		t.Fatalf("Invalid url: %s", err.Error())
	}

	req, err := http.NewRequest(http.MethodGet, remote, nil)
	if err != nil {
		t.Fatalf("Invalid request: %s", err.Error())
	}

	if len(t.Bearer) > 0 {
		req.Header.Set("Authentication", fmt.Sprintf("Bearer %s", t.Bearer))
	}

	req.URL.RawQuery = values.Encode()

	res, err := t.Http.Do(req)
	if err != nil {
		t.Fatalf("Cannot perform request: %s", err.Error())
	}

	return HttpResponse{T: t.T, Response: res}
}

func (t *Tester) PostWithJsonPayload(path string, body []byte) HttpResponse {
	remote, err := url.JoinPath(BaseUrl, path)
	if err != nil {
		t.Fatalf("Invalid url: %s", err.Error())
	}

	var r io.Reader
	if body != nil {
		r = bytes.NewReader(body)
	}

	req, err := http.NewRequest(http.MethodPost, remote, r)
	if err != nil {
		t.Fatalf("Invalid request: %s", err.Error())
	}

	req.Header.Set("Content-Type", "application/json")
	if len(t.Bearer) > 0 {
		req.Header.Set("Authentication", fmt.Sprintf("Bearer %s", t.Bearer))
	}

	res, err := t.Http.Do(req)
	if err != nil {
		t.Fatalf("Cannot perform request: %s", err.Error())
	}

	return HttpResponse{T: t.T, Response: res}
}

type HttpResponse struct {
	*testing.T
	*http.Response
}

func (r HttpResponse) AssertStatus(status int, msg string) {
	if r.StatusCode != status {
		r.T.Log(string(r.Contents()))
		r.T.Fatal(msg)
	}
}

func (r HttpResponse) Contents() []byte {
	contents, err := io.ReadAll(r.Body)
	if err != nil {
		r.T.Fatalf("Cannot read response body: %s", err.Error())
	}

	return contents
}
