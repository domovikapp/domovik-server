defmodule Domovik.Users do
  @moduledoc """
  This module contains functions linked to the handling of users
  """

  require Logger

  @free_instance Application.compile_env(:domovik, :free_instance)

  use Pow.Ecto.Context,
    repo: Domovik.Repo,
    user: Domovik.Users.User

  def create(params) do
    with {:ok, user} <- pow_create(params),
         {:ok, _} <- Domovik.ReadingList.create_list(user, %{name: "To read", user_id: user.id}) do
      register(user, @free_instance)
    end
  end

  def register(user, true), do: {:ok, user}
  def register(user, false) do
    with {:ok, customer} <- Stripe.Customer.create(%{email: user.email }),
         {:ok, _subscription} <- Stripe.Subscription.create(%{
               customer: customer,
               items: [%{price: Application.get_env(:domovik, :monthly_price), quantity: 1}],
               trial_period_days: Application.get_env(:domovik, :trial_length) }),
    {:ok, user} <- Ecto.Changeset.change(user, customer_id: customer.id) |> Domovik.Repo.update
      do
      {:ok, user}
    else
      {:error, e} ->
        Logger.error "Unable to register #{user.email} -- #{e}"
      Domovik.Repo.delete(user)
      {:error, "Unable to create a Stripe customer"}
    end
  end

  def can_access?(user) do
    user.subscription != "unsubscribed"
  end

  def subscribe(user, status) do
    Logger.info "#{user.email} is now #{status}"
    Ecto.Changeset.change(user, subscription: status)
    |> Domovik.Repo.update
  end

  def unsubscribe(user) do
    # free_browsers_count = Application.get_env(:domovik, :free_browsers)
    # browsers = Domovik.Sync.list_user_browsers(user)
    # if length(browsers) > free_browsers_count do
    #   browsers
    #   |> Enum.drop(-free_browsers_count)
    #   |> Domovik.Repo.delete_all()
    # end

    Logger.info "#{user.email} is now unsubscribed"
    Ecto.Changeset.change(user, subscription: "unsubscribed")
    |> Domovik.Repo.update
  end

  def get_by_customer_id(customer_id) do
    Domovik.Repo.get_by(Domovik.Users.User, customer_id: customer_id)
  end
end
