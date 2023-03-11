package features

import (
	"encoding/json"
	"fmt"
	"net/http"
)

func (t *TestSuite) _fetchUserId() {
	if len(t.userId) > 0 {
		return
	}

	r := t.Db.QueryRowx("SELECT id FROM users WHERE email = $1", t.emailAddress)

	rm := make(map[string]interface{})
	if err := r.MapScan(rm); err != nil {
		t.Fatalf("Could not fetch user id from database: %s", err.Error())
	}

	userId, ok := rm["id"]
	if !ok {
		t.Fatal("Could not fetch user id from database")
	}

	t.userId, ok = userId.(string)
	if !ok {
		t.Fatalf("Invalid user id type: %s", userId)
	}
}

func (t *TestSuite) _fetchActivationId() {
	if len(t.activationId) > 0 {
		return
	}

	r := t.Db.QueryRowx("SELECT id FROM activation_ids WHERE user_id = $1", t.userId)

	rm := make(map[string]interface{})
	if err := r.MapScan(rm); err != nil {
		t.Fatalf("Could not fetch activation id from database: %s", err.Error())
	}

	activationId, ok := rm["id"]
	if !ok {
		t.Fatal("Could not fetch activation id from database")
	}

	t.activationId, ok = activationId.(string)
	if !ok {
		t.Fatalf("Invalid activation id type: %s", activationId)
	}
}

func (t *TestSuite) _userSignIn() {
	if len(t.Bearer) > 0 {
		return
	}

	body := []byte(fmt.Sprintf(`{
  "email": "%s",
  "password": "%s"
}`, t.emailAddress, t.password))

	res := t.PostWithJsonPayload("/auth/sign-in", body)
	res.AssertStatus(http.StatusOK, "User sign in request failed")

	var resBody struct {
		Status string
		Data   struct {
			Token string
		}
	}

	err := json.Unmarshal(res.Contents(), &resBody)
	if err != nil || len(resBody.Data.Token) == 0 {
		t.Fatalf("Could not fetch user token: %s", err)
	}

	t.Bearer = resBody.Data.Token
}
