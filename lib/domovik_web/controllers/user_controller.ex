defmodule DomovikWeb.UserController do
  use DomovikWeb, :controller

  require Logger

  import Pow.Plug

  alias Domovik.Repo
  alias Domovik.Users
  alias Domovik.Sync
  alias Domovik.Bookmarks
  alias Domovik.ReadingList


  defp sync_user(conn, user), do: Pow.Plug.create(conn, user)

  # Called by Stripe after the subscription has been validated
  def subscription_success(conn, _params) do
    user = current_user(conn)
    case Users.subscribe(user, "premium") do
      {:ok, new_user} ->
        conn
        |> sync_user(new_user)
        |> put_flash(:info, "Subscription successsful. Welcome to Domovik Premium!")
        |> redirect(to: Routes.browser_path(conn, :index))
      {:error, e} ->
        Logger.error "While subscribing #{user.email}: #{inspect(e)}"
        conn
        |> put_flash(:error, "An error happened during the subscription process; please contact support")
        |> redirect(to: Routes.browser_path(conn, :index))
    end
  end

  # Called if the user cancel the subscription in the Stripe popup.
  def subscription_cancel(conn, _params) do
    conn
    |> put_flash(:error, "The subscription process has been aborted")
    |> redirect(to: Routes.user_path(conn, :settings))
  end

  # AJAX-ed from the subscription page.
  # Returns the Stripe Session corresponding to the chosen plan.
  def get_subscription(conn, %{"type" => type}) do
    price = case type do
              "monthly" -> Application.get_env(:domovik, :monthly_price)
              "yearly" -> Application.get_env(:domovik, :yearly_price)
            end

    with {:ok, session} <- Stripe.Session.create(
           %{payment_method_types: ["card"],
             allow_promotion_codes: "true",
             customer: current_user(conn).customer_id,
             mode: "subscription",
             line_items: [%{price: price, quantity: 1}],
             subscription_data: %{trial_from_plan: true},
             success_url: Routes.user_url(conn, :subscription_success),
             cancel_url: Routes.user_url(conn, :subscription_cancel)}) do
      json(conn, %{id: session.id})
    end
  end

  def settings(conn, _params) do
    render conn, "settings.html", user: current_user(conn)
  end

  def convert!("true"), do: true
  def convert!("false"), do: false
  def convert!(num), do: String.to_integer(num)

  def news(conn, _params) do
    user = current_user(conn)
    user = Ecto.Changeset.change user, want_emails: !user.want_emails
    user = Domovik.Repo.update!(user)
    conn |> sync_user(user) |> redirect(to: Routes.user_path(conn, :settings))
  end

  def stripe_portal(conn, _params) do
    user = current_user(conn)
    with {:ok, _} <- Stripe.Customer.update(user.customer_id, %{email: user.email}),
         {:ok, portal} <- Stripe.BillingPortal.Session.create(%{
               customer: user.customer_id,
               return_url: Routes.user_url(conn, :settings)}) do
      redirect(conn, external: portal.url)
    else {:error, e} ->
        Logger.error "while #{user.email} accessed their portal: #{inspect(e)}"
        conn
        |> put_flash(:error, "An error occured while loading your billing portal.")
        |> redirect(to: Routes.user_path(conn, :settings))
    end
  end

  def download_bookmarks(conn, _params) do
    bookmarks = conn |> current_user |> Bookmarks.user_bookmarks

    conn
    |> put_resp_content_type("application/json")
    |> put_resp_header("content-disposition", "attachment; filename=\"bookmarks.json\"")
    |> render(DomovikWeb.Api.V1.BookmarksView, "bookmarks.json", bookmarks: bookmarks)
  end

  def download_reading_lists(conn, _params) do
    lists = conn |> current_user |> ReadingList.user_lists |> Repo.preload([:links])

    conn
    |> put_resp_content_type("application/json")
    |> put_resp_header("content-disposition", "attachment; filename=\"reading_lists.json\"")
    |> render(DomovikWeb.Api.V1.ListView, "pretty_index.json", lists: lists)
  end

  def download_tabs(conn, _params) do
    browsers = Sync.list_user_browsers(current_user(conn)) |> Repo.preload(:tabs)

    conn
    |> put_resp_content_type("application/json")
    |> put_resp_header("content-disposition", "attachment; filename=\"tabs.json\"")
    |> render(DomovikWeb.Api.V1.BrowserView, "index.json", browsers: browsers)
  end
end
