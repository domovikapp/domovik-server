defmodule Domovik.SyncTest do
  use Domovik.DataCase

  alias Domovik.Sync
  alias Domovik.Users.User

  describe "browsers" do
    alias Domovik.Sync.Browser

    @password "12345678"

    @valid_attrs %{name: "MyTestBrowser"}
    @update_attrs %{name: "MyRenamedTestBrowser"}
    @invalid_attrs %{name: nil}

    def user_fixture() do
      {:ok, user} = %User{}
      |> User.changeset(%{email: "test@example.com", password: @password, password_confirmation: @password})
      |> Repo.insert()
      user
    end

    def browser_fixture(user) do
      {:ok, browser} = Sync.create_browser(user, @valid_attrs)
      browser
    end

    test "list_browsers/0 returns all browsers" do
      user = user_fixture()
      browser = browser_fixture(user)
      assert Sync.list_user_browsers(user) == [browser]
    end

    test "get_user_browser!/1 returns the browser with given UUID" do
      user = user_fixture()
      browser = browser_fixture(user)
      assert Sync.get_user_browser!(browser.uuid, user.id) == browser
    end

    test "create_browser/1 with valid data creates a browser" do
      user = user_fixture()
      assert {:ok, %Browser{} = browser} = Sync.create_browser(user, @valid_attrs)
      assert browser.name == "MyTestBrowser"
    end

    test "create_browser/1 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Sync.create_browser(user, @invalid_attrs)
    end

    test "update_browser/2 with valid data updates the browser" do
      user = user_fixture()
      browser = browser_fixture(user)
      assert {:ok, %Browser{} = browser} = Sync.update_browser(browser, @update_attrs)
      assert browser.name == "MyRenamedTestBrowser"
    end

    test "update_browser/2 with invalid data returns error changeset" do
      user = user_fixture()
      browser = browser_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Sync.update_browser(browser, @invalid_attrs)
      assert browser == Sync.get_user_browser!(browser.uuid, user.id)
    end

    test "delete_browser/1 deletes the browser" do
      user = user_fixture()
      browser = browser_fixture(user)
      assert {:ok, %Browser{}} = Sync.delete_browser(browser)
      assert_raise Ecto.NoResultsError, fn -> Sync.get_user_browser!(browser.uuid, user.id) end
    end

    test "change_browser/1 returns a browser changeset" do
      user = user_fixture()
      browser = browser_fixture(user)
      assert %Ecto.Changeset{} = Sync.change_browser(browser)
    end
  end

  # defp assign_user(%{conn: conn}) do
  #   user = %User{}
  #   |> User.changeset(%{email: "test@example.com", password: @password, password_confirmation: @password})
  #   |> Repo.insert!()
  #   conn = Pow.Plug.assign_current_user(conn, user, otp_app: :domovik)
  #   {:ok, conn: conn}
  # end
end
