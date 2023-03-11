package features

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"testing"
	"time"

	"github.com/brianvoe/gofakeit/v6"
	"github.com/cucumber/godog"
)

const (
	// API Constants
	BaseUrl = "http://localhost:4000/api"

	// Database Constants
	DbUser = "racquet"
	DbPass = "racquet"
	DbHost = "localhost"
	DbPort = 5432
	DbName = "racquet"
)

func TestFeatures(t *testing.T) {
	ts := NewTestSuite(t)
	ts.Run()
}

type TestSuite struct {
	*Tester

	emailAddress string
	password     string

	userId       string
	activationId string
}

func NewTestSuite(t *testing.T) *TestSuite {
	return &TestSuite{
		Tester: NewTester(t),
	}
}

func (t *TestSuite) Run() {
	suite := godog.TestSuite{
		ScenarioInitializer: func(ctx *godog.ScenarioContext) {
			ctx.Step(`^a new user is signed up$`, t.aNewUserIsSignedUp)
			ctx.Step(`^the user waits for the welcome email$`, t.theUserWaitsForTheWelcomeEmail)
			ctx.Step(`^activates its recently created account$`, t.activatesItsRecentlyCreatedAccount)
			ctx.Step(`^the user should be able to sign in$`, t.theUserShouldBeAbleToSignIn)
			ctx.Step(`^should be able to fetch its profile$`, t.shouldBeAbleToFetchItsProfile)
		},
		Options: &godog.Options{
			Format:   "pretty",
			Paths:    []string{"features"},
			TestingT: t.T,
		},
	}

	if suite.Run() != 0 {
		t.Fatal("Non-zero status returned, failed to run feature tests")
	}
}

func (t *TestSuite) aNewUserIsSignedUp() error {
	t.emailAddress = gofakeit.Email()
	t.password = gofakeit.Password(true, true, true, true, true, 10)

	body := []byte(fmt.Sprintf(`{
  "email": "%s",
  "password": "%s",
  "name": "%s",
  "surname": "%s"
}`, t.emailAddress, t.password, gofakeit.FirstName(), gofakeit.LastName()))

	res := t.PostWithJsonPayload("/auth/sign-up", body)
	res.AssertStatus(http.StatusAccepted, "User sign up request failed")

	return nil
}

func (t *TestSuite) theUserWaitsForTheWelcomeEmail() error {
	time.Sleep(2 * time.Second)
	return nil
}

func (t *TestSuite) activatesItsRecentlyCreatedAccount() error {
	t._fetchUserId()
	t._fetchActivationId()

	v := make(url.Values)
	v.Set("user_id", t.userId)
	v.Set("activation_id", t.activationId)

	res := t.GetWithUrlValues("/auth/activate", v)
	res.AssertStatus(http.StatusOK, "User activation request failed")

	return nil
}

func (t *TestSuite) theUserShouldBeAbleToSignIn() error {
	t._userSignIn()
	return nil
}

func (t *TestSuite) shouldBeAbleToFetchItsProfile() error {
	v := make(url.Values)
	v.Set("user_id", t.userId)

	res := t.GetWithUrlValues("/player/profile", v)
	res.AssertStatus(http.StatusOK, "Player profile request failed")

	var resBody struct {
		Status string
		Data   struct {
			Id      string
			Email   string
			Name    string
			Surname string
			UserId  string `json:"user_id"`
		}
	}

	err := json.Unmarshal(res.Contents(), &resBody)
	if err != nil {
		t.Fatalf("Could not fetch player profile: %s", err)
	}

	if resBody.Data.Email != t.emailAddress ||
		resBody.Data.UserId != t.userId {
		t.Fatalf("Player profile fetched is invalid: %+v", resBody)
	}

	return nil

}
