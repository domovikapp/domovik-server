defmodule DomovikWeb.StripeController do
  use DomovikWeb, :controller
  require Logger

  alias Domovik.Users

  def webhooks(%Plug.Conn{assigns: %{stripe_event: stripe_event}} = conn, _params) do
    case handle_webhook(stripe_event) do
      {:ok, _} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(:ok, "ok")
      {:notfound, _} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(:not_found, "")
      {:unimplemented, _} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(:accepted, "ok")
      {:error, error} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(:unprocessable_entity, error)
      _ ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(:unprocessable_entity, "error")
    end
  end

  defp handle_webhook(%{type: "customer.subscription.updated"} = event) do
    # Possible values are active, past_due, unpaid, canceled, incomplete, incomplete_expired, trialing
    status = event.data.object.status
    customer = event.data.object.customer
    Logger.info "#{customer} is now #{status}"
    case Users.get_by_customer_id(customer) do
      nil ->
        Logger.error "STRIPE: no user linked to Stripe ID #{customer}"
        {:notfound, ""}
      user ->
        case status do
          x when x in ["active", "trialing"] -> Users.subscribe(user, "premium")
          _ -> Users.unsubscribe(user)
        end
        {:ok, "success"}
    end
  end


  defp handle_webhook(%{type: "customer.subscription.deleted"} = event) do
    customer = event.data.object.customer
    status = event.data.object.status
    Logger.info "STRIPE: #{customer} is now #{status}"
    case Users.get_by_customer_id(customer) do
      nil ->
        Logger.error "no user linked to Stripe ID #{customer}"
        {:notfound, ""}
      user ->
        Users.unsubscribe(user)
        {:ok, "success"}
    end
  end


  defp handle_webhook(%{type: "invoice.payment_failed"} = event) do
    customer = event.data.object.customer
    status = event.data.object.status
    Logger.info "STRIPE: #{customer} is now #{status}"
    case Users.get_by_customer_id(customer) do
      nil ->
        Logger.error "no user linked to Stripe ID #{customer}"
        {:notfound, ""}
      user ->
        Users.payment_failed(user)
        {:ok, "success"}
    end
  end


  defp handle_webhook(%{type: "customer.subscription.trial_will_end"} = event) do
    customer = event.data.object.customer
    status = event.data.object.status
    Logger.info "STRIPE: trial will soon end for #{customer} is now #{status}"
    case Users.get_by_customer_id(customer) do
      nil ->
        Logger.error "STRIPE: no user linked to Stripe ID #{customer}"
        {:notfound, ""}
      user ->
        case Users.end_trial(user) do
          {:ok, _} ->
            Logger.info "end trial email sent to #{user.email}"
            {:ok, "success"}
          {:error, e} ->
            Logger.error "while sending end trial email to #{user.email}: #{e}"
            {:error, ""}
        end
    end
  end

  defp handle_webhook(_) do
    {:unimplemented, 0}
  end
end
