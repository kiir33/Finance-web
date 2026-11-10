require "test_helper"

class LoansControllerTest < ActionDispatch::IntegrationTest
  setup do
    post session_url, params: { email: "admin@example.com", password: "password123" }
  end

  test "index renders for a signed-in admin" do
    get loans_url
    assert_response :success
  end

  test "new renders a form" do
    get new_loan_url
    assert_response :success
  end

  test "create adds a loan and redirects" do
    client = clients(:one)
    assert_difference -> { Loan.count }, 1 do
      post loans_url, params: { loan: { client_id: client.id } }
    end
    assert_redirected_to loan_path(Loan.last)
  end

  test "index redirects to login when not signed in" do
    delete destroy_session_url
    get loans_url
    assert_redirected_to new_session_url
  end

  test "member only sees loans linked to their own clients" do
    delete destroy_session_url
    post session_url, params: { email: "member@example.com", password: "password123" }

    get loans_url
    assert_response :success
    assert_includes response.body, loans(:one).id.to_s
    assert_not_includes response.body, loans(:two).id.to_s
  end

  test "member cannot view a loan linked to another client" do
    delete destroy_session_url
    post session_url, params: { email: "member@example.com", password: "password123" }

    get loan_url(loans(:two))
    assert_response :not_found
  end

  test "edit renders form for admin" do
    get edit_loan_url(loans(:one))
    assert_response :success
  end

  test "update modifies loan and redirects" do
    patch loan_url(loans(:one)), params: { loan: { client_id: clients(:two).id } }
    assert_redirected_to loan_path(loans(:one))
  end

  test "destroy soft-deletes loan and redirects" do
    loan = loans(:one)
    delete loan_url(loan)
    assert_redirected_to loans_url
    loan.reload
    assert_not_nil loan.deleted_at
  end
end