defmodule IrchubWeb.CookieConsentController do
  use IrchubWeb, :controller
  @cookie_consent_key "cookie_consent"
  def cookie_consent_key_str do
    @cookie_consent_key
  end
  def cookie_consent_val_str do
    "yes"
  end
  def agree(conn, _params) do
    next = Map.get(conn.params, "next", "/")
    next = if String.starts_with?(next, "/") do
      next
    else
      "/" <> next
    end
    conn
    |> put_resp_cookie(@cookie_consent_key, cookie_consent_val_str(), same_site: "Lax", path: "/")
    |> put_session(@cookie_consent_key, true)
    |> put_flash(:info, "You've consented to our use of cookies!")
    |> redirect(to: next)

  end

end
